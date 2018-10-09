//
//  BHBatchRequest.m
//  AFNetworking
//
//  Created by heboyce on 2018/2/6.
//

#import "BHBatchRequest.h"
#import "BHNetworkManager.h"
#import "BHSubjectPool.h"
#import "BHRACSubscriber.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface BHBatchRequest()
@property (nonatomic,assign) NSInteger              requestingCount;
@end

@implementation BHBatchRequest

- (instancetype)init{
  
  self = [super init];
  
  _requestArr = [NSMutableArray new];
 
  
  return self;
  
}

- (void)addRequest:(BHRequest *)request{
  
  if (request) {
     [_requestArr addObject:request];
  }
  
}

- (nullable BHNetworkSignal *)rac_Singal{
  
   @weakify(self);
  
  BHNetworkSignal *interalSingal = [BHNetworkSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    
    @strongify(self);
    
    BHRACSubscriber *sub = [BHRACSubscriber subscriberWithNext:^(id x) {
      
        _requestingCount--;
      
      if (_requestingCount == 0) {
     
        [subscriber sendNext:self];
        [subscriber sendCompleted];
        
      }
  
    } error:^(NSError *error) {
    
      [self cancelAll];
      [subscriber sendError:error];
      [subscriber sendCompleted];
      
    } completed:^{
      
      
    }];
    

    NSMutableArray *dataTaskArr = [NSMutableArray array];
    
    _requestingCount = self.requestArr.count;
    
    for (BHRequest *requestObj in self.requestArr) {
      
      
      NSURLSessionDataTask *dataTask = [[BHNetworkManager manager] createDataTask:requestObj subscriber:sub];
      
      [[BHSubjectPool sharedPool] addSubject:sub identifier:requestObj.identifier];
      [dataTaskArr addObject:dataTask];
      
      [dataTask resume];
      
    }
  
     return [RACDisposable disposableWithBlock:^{
      
       for (NSURLSessionDataTask *task in dataTaskArr) {
          [task cancel];
       }
      
    }];
    
  }];
  

  return interalSingal;
}

- (void)addRequestsFromArray:(NSArray *)reqeusts{
  
  if (reqeusts) {
      [_requestArr addObjectsFromArray:reqeusts];
  }

}


- (void)cancelAll{
  
   for (BHRequest *requestObj in self.requestArr) {
          [requestObj cancel];
   }

}

@end
