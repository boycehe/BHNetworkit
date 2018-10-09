//
//  BHNetworkManager.m
//  BHNetworking
//
//  Created by heboyce on 2018/1/18.
//

#import "BHNetworkManager.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "BHNetworkConfig.h"
#import "BHSubjectPool.h"
#import "BHNetworkSignal.h"
#import <pthread/pthread.h>
#import "BHRACSubscriber.h"

#define BHNetworkLock()    pthread_mutex_lock(&_lock)
#define BHNetworkUnlock()  pthread_mutex_unlock(&_lock)

@interface BHNetworkManager() {
  
    NSMutableDictionary <NSNumber *, BHRequest *> *_requestRecords;
    dispatch_queue_t _requestQueue;
    pthread_mutex_t _lock;
  
}
@property (nonatomic,strong) AFHTTPSessionManager         *sessionManager;

@end

@implementation BHNetworkManager

+ (instancetype)manager{
  
  static dispatch_once_t predicate;
  static BHNetworkManager * sharedManager;
  
  dispatch_once(&predicate, ^{
    sharedManager = [[BHNetworkManager alloc] init];
  });
  
  return sharedManager;

}

- (instancetype)init{
  
  self = [super init];
  
  _sessionManager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
  
  _requestRecords = [NSMutableDictionary dictionary];
  pthread_mutex_init(&_lock, NULL);
  _requestQueue = dispatch_queue_create("com.BH.networking.request", DISPATCH_QUEUE_CONCURRENT);
  _sessionManager.completionQueue =  _requestQueue;
  
  return self;
  
}


- (nullable BHNetworkSignal *)rac_Request:(nullable BHRequest *)requestObj{
  
  @weakify(self);
  BHNetworkSignal *singal =  [BHNetworkSignal createSignalWithIdentifier:requestObj.identifier subscribe:^RACDisposable *(id<RACSubscriber> subscriber) {
    
    @strongify(self);
    
    NSURLSessionDataTask *task = [self createDataTask:requestObj subscriber:subscriber];
    
    if (!task) {
      
      return [RACDisposable disposableWithBlock:^{
        
      }];
      
    }
    
    [task resume];
    
    return [RACDisposable disposableWithBlock:^{
      [task cancel];
    }];
    
  }];
  
  return singal;

  
}



- (BHNetworkSignal *)rac_requestMethod:(NSString *)method path:(NSString *)path requestObj:(nullable BHRequest *)requestObj identifier:(nullable NSString *)identifier{
  

  @weakify(self);
  BHNetworkSignal *singal =  [BHNetworkSignal createSignalWithIdentifier:identifier subscribe:^RACDisposable *(id<RACSubscriber> subscriber) {
     
    @strongify(self);

    NSURLSessionDataTask *task = [self createDataTask:requestObj subscriber:subscriber];
    
    if (!task) {
      
      return [RACDisposable disposableWithBlock:^{
       
      }];
      
    }
    
    [task resume];
    
     return [RACDisposable disposableWithBlock:^{
          [task cancel];
     }];
   
  }];
  
  return singal;

}

- (NSURLSessionDataTask *)createDataTask:(nullable BHRequest *)requestObj subscriber:(id<RACSubscriber> )subscriber{
  
  
  NSError *requestError = nil;
  
  NSMutableURLRequest *request = [requestObj requestWithPath:requestObj.path error:&requestError];
  
  if(requestError){
    
    [subscriber sendError:requestError];
   
    return nil;
    
  }
  
  self.sessionManager.securityPolicy = [BHNetworkConfig sharedConfig].securityPolicy;
  __block NSURLSessionDataTask *task = nil;
   @weakify(self);
  task = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
    
    @strongify(self);
    
    if(error){
      [self subscriber:subscriber sendError:error idnetifier:requestObj.identifier];
      return;
    }
    
    NSError *responseError = [requestObj vaildReponse:response responseObject:responseObject];
    
    if(responseError){
      [self subscriber:subscriber sendError:responseError idnetifier:requestObj.identifier];
      return;
    }
    
    NSString *identifier = @"";
    
    if (requestObj.identifier == nil) {
      identifier = [NSString stringWithFormat:@"%@%f",requestObj.path,[[NSDate date] timeIntervalSince1970]];
    }else{
      identifier = requestObj.identifier;
    }
    
    [[BHSubjectPool sharedPool] addSubject:subscriber identifier:identifier];
    
    [self handleResultDataTask:task responseObject:responseObject identifier:identifier];

  }];
  requestObj.dataTask = task;
  //设置请求优先级
  
  if(requestObj.priority == BHRequestPriorityLow){
    task.priority = NSURLSessionTaskPriorityLow;
  }else if (requestObj.priority == BHRequestPriorityHigh){
    task.priority = NSURLSessionTaskPriorityHigh;
  }else{
    task.priority = NSURLSessionTaskPriorityDefault;
  }
  
  task.priority = requestObj.priority;
  
  _requestRecords[@(task.taskIdentifier)] = requestObj;
  
  return task;
}


- (void)handleResultDataTask:(NSURLSessionDataTask *)dataTask responseObject:(id  _Nullable)responseObject identifier:(NSString * _Nullable)identifier{
  
  
  BHNetworkLock();
  
  BHRequest *requestObj = _requestRecords[@(dataTask.taskIdentifier)];
  
  BHNetworkUnlock();
  
  __block id model  = nil;
  
  NSArray *arr = [[BHSubjectPool sharedPool] allSubjects:identifier];
  
  NSLog(@"count:%zd",arr.count);
  
  [arr enumerateObjectsUsingBlock:^(id<RACSubscriber>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    BHRACSubscriber *subscriber = (BHRACSubscriber*)obj;
    
    if(requestObj.responseType == BHResponseSerializerTypeMODEL){
      
      NSError *resolveError  = nil;
      model = (model != nil)?model:[requestObj resolveResponseObject:responseObject class:requestObj.responseSerializeClass error:&resolveError];
      if(resolveError){
        [subscriber sendError:resolveError];
      }else{
        requestObj.responseObject = model;
        [subscriber sendNext:RACTuplePack(model, dataTask.response)];
      }
      
    }else{
      requestObj.responseObject = responseObject;
      [subscriber sendNext:RACTuplePack(responseObject, dataTask.response)];
      
    }
    
  }];
  
}

- (void)subscriber:(id<RACSubscriber>)subscriber sendError:(NSError *)error idnetifier:(NSString *)identifier{
  
  [subscriber sendError:error];
  
  [[[BHSubjectPool sharedPool] allSubjects:identifier] enumerateObjectsUsingBlock:^(id<RACSubscriber>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    [obj sendError:error];
  }];
  
}




  
@end
