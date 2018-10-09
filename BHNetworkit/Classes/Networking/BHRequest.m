//
//  BHRequest.m
//  BHNetworking
//
//  Created by heboyce on 2018/1/18.
//

#import "BHRequest.h"
#import <AFNetworking/AFURLRequestSerialization.h>
#import "BHNetworkConfig.h"
#import <YYModel/YYModel.h>
#import "BHNetworkManager.h"


@implementation BHRequest

- (instancetype)init{
  
  self = [super init];
  
  _headerField       = [NSMutableDictionary dictionary];
  _requestParameters = [NSMutableDictionary dictionary];
  _timeoutInterval   = 15.0f;
  _cachePolicy       = NSURLRequestReloadIgnoringLocalCacheData;
  _acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"text/plain", nil];
  
  return self;
  
}


- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field{
 
   [_headerField setValue:value forKey:field];
  
}

- (void)setValue:(id)value forKey:(NSString *)key{
  
  [_requestParameters setValue:value forKey:key];
  
}
  
 
- (_Nullable id)resolveResponseJSON:(_Nullable id)responseObject error:(NSError * _Nullable __autoreleasing * _Nullable)error{
  
  NSString *reason = [NSString stringWithFormat:@"%@ must be overridden by subclasses", NSStringFromSelector(_cmd)];
  @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
  return responseObject;
  
}
  
- (_Nullable id)resolveResponseObject:(_Nullable id)responseObject class:(_Nullable Class)class error:(NSError * _Nullable __autoreleasing * _Nullable)error{
  
  if(!responseObject || !class){
    *error = [NSError errorWithDomain:@"responseObject or class shouldn't nil" code:-1 userInfo:nil];
    return nil;
  }
  
  id responseData = [self resolveResponseJSON:responseObject error:error];
  
    if(*error){
      return nil;
    }
  id responseModel = nil;
  
  if ([responseData isKindOfClass:NSArray.class]) {
    responseModel = [NSArray yy_modelArrayWithClass:class json:responseData];
  } else {
    responseModel = [class yy_modelWithJSON:responseData];
  }
  
  if(!responseModel){
    *error = [NSError errorWithDomain:[NSString stringWithFormat:@"responseObject is not vaild data,please check %@'s mapping ",NSStringFromClass(class)] code:-1 userInfo:nil];
    return nil;
  }

  
  return responseModel;
  
}
  
- (NSError * _Nullable )vaildReponse:(NSURLResponse * _Nonnull )response responseObject:(_Nullable id)responseObject{

    return nil;
  
}

- (void)requestWillStart{
  
  
}

- (NSMutableURLRequest *)requestWithPath:(NSString *)path error:(NSError * _Nullable __autoreleasing *)error{
  
  NSString *urlString = nil;
  
  if ([path hasPrefix:@"http"]) {
    urlString = [path copy];
  }else{
    urlString = [[NSURL URLWithString:path relativeToURL:[NSURL URLWithString:[BHNetworkConfig sharedConfig].baseUrl]] absoluteString];
  }
  
  if (!urlString) {
    return nil;
  }
  
   [self requestWillStart];
  
  AFHTTPRequestSerializer *requestSerializer = nil;
  
  if([self.contentType isEqualToString:@"application/x-plist"]){
    requestSerializer = [AFPropertyListRequestSerializer serializer];
  }else if ([self.contentType isEqualToString:@"application/json"]){
    requestSerializer = [AFJSONRequestSerializer serializer];
  }else{
    requestSerializer = [AFHTTPRequestSerializer serializer];
  }
  
  requestSerializer.timeoutInterval = self.timeoutInterval;
  requestSerializer.cachePolicy     = self.cachePolicy;
  
  [_headerField addEntriesFromDictionary:[[BHNetworkConfig sharedConfig] headerField]];
  
 
  
  NSArray *allFieldKey = [self.headerField allKeys];
  
  for (NSString *key in allFieldKey){
    [requestSerializer setValue:[self.headerField objectForKey:key] forHTTPHeaderField:key];
  }
  
  NSMutableURLRequest *request = nil;
  
  if (self.constructingBlock) {
    request = [requestSerializer multipartFormRequestWithMethod:[self HTTPMethod] URLString:urlString parameters:self.requestParameters constructingBodyWithBlock:self.constructingBlock error:error];
  }else{
     request = [requestSerializer requestWithMethod:[self HTTPMethod] URLString:urlString parameters:self.requestParameters error:error];
  }

  
  return request;
  
}

- (nullable BHNetworkSignal *)rac_Singal{
  
  BHNetworkSignal *singal = nil;
  
  singal = [[BHNetworkManager manager] rac_Request:self];
  
  return  singal;
  
  
}

- (nullable BHNetworkSignal *)rac_Singal:(NSString*)identifier{

  self.identifier = identifier;
  
  return [self rac_Singal];

}

- (void)cancel{
  
  [self.dataTask cancel];
  
}

- (NSString *)HTTPMethod{
  
  switch (self.method) {
    case BHRequestMethodGET:
      return  @"GET";
      break;
    case BHRequestMethodPOST:
      return  @"POST";
    case BHRequestMethodHEAD:
      return  @"HEAD";
    case BHRequestMethodPUT:
      return  @"PUT";
    case BHRequestMethodDELETE:
      return @"DELETE";
    case BHRequestMethodPATCH:
      return @"PATCH";
    default:
      return @"GET";
      break;
  }
  
}


@end
