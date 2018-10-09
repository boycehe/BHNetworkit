//
//  BHNetworkConfig.h
//  AFNetworking
//
//  Created by heboyce on 2018/1/24.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFSecurityPolicy.h>

@interface BHNetworkConfig : NSObject
@property (nonatomic,strong,readonly) NSString                              *baseUrl;
@property (nonatomic,strong) AFSecurityPolicy                               *securityPolicy;
@property (nonatomic,strong,readonly) NSMutableDictionary                   *headerField;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)sharedConfig;

- (void)setupBaseUrl:(NSString*)baseUrl;
//作为设置请求头的补充方法，这里设置的请求头的参数会覆盖request里边相同参数的value
- (void)setExtraValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

@end
