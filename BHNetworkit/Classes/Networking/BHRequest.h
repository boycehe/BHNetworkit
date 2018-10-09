//
//  BHRequest.h
//  BHNetworking
//
//  Created by heboyce on 2018/1/18.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFSecurityPolicy.h>
#import "BHNetworkResponseProtocol.h"
#import "BHNetworkSignal.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, BHRequestPriority) {
  
  BHRequestPriorityDefault          = 0,
  BHRequestPriorityLow              = 1,
  BHRequestPriorityHigh             = 2,
  
};

typedef NS_ENUM(NSInteger, BHRequestHTTPMethod) {
  BHRequestMethodGET = 0,
  BHRequestMethodPOST,
  BHRequestMethodHEAD,
  BHRequestMethodPUT,
  BHRequestMethodDELETE,
  BHRequestMethodPATCH,
};

typedef NS_ENUM(NSInteger, BHResponseSerializerType) {
  
  BHResponseSerializerTypeJSON               = 0,
  BHResponseSerializerTypeMODEL              = 1,
  
};

@protocol AFMultipartFormData;
typedef void (^BHConstructingBlock)(id<AFMultipartFormData> formData);

@interface BHRequest : NSObject<BHNetworkResponseProtocol>
@property (nonatomic,strong,readonly) NSMutableDictionary         *requestParameters;
@property (nonatomic,strong,readonly) NSMutableDictionary         *headerField;
@property (nonatomic,copy) NSString                               *contentType;

/**
 The timeout interval, in seconds, for created requests. The default timeout interval is 15 seconds.
*/
@property (nonatomic,assign) NSTimeInterval                         timeoutInterval;
/*
 NSURLRequestUseProtocolCachePolicy` by default.
 */
@property (nonatomic, assign) NSURLRequestCachePolicy               cachePolicy;

@property (nonatomic, copy) NSSet <NSString *>                      *acceptableContentTypes;
/**
 * 优先级
*/
@property (nonatomic,assign) BHRequestPriority                       priority;

@property (nonatomic,copy) NSString                                   *path;
@property (nonatomic,assign) BHRequestHTTPMethod                      method;
@property (nonatomic,copy) NSString                                   *identifier;


@property (nonatomic,strong) Class                                    responseSerializeClass;
@property (nonatomic,strong)  id                                      responseObject;
@property (nonatomic,assign) BHResponseSerializerType                responseType;
@property (nonatomic,strong) NSURLSessionDataTask                     *dataTask;
@property (nonatomic,copy) BHConstructingBlock                       constructingBlock;


  

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
  
- (void)setValue:(nullable id)value forKey:(NSString *)key;
  
- (NSMutableURLRequest *)requestWithPath:(NSString *)path error:(NSError * _Nullable __autoreleasing *)error;

- (void)cancel;

- (nullable BHNetworkSignal *)rac_Singal;

@end
NS_ASSUME_NONNULL_END
