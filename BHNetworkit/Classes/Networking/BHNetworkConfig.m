//
//  BHNetworkConfig.m
//  AFNetworking
//
//  Created by heboyce on 2018/1/24.
//

#import "BHNetworkConfig.h"


@implementation BHNetworkConfig

+ (instancetype )sharedConfig {
  static id sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}
  
- (instancetype)init{
  
  self = [super init];
  
  if (self){
    _securityPolicy = [AFSecurityPolicy defaultPolicy];
    _headerField    = [NSMutableDictionary dictionary];
  }
  
  return self;
  
}

- (void)setExtraValue:(NSString *)value forHTTPHeaderField:(NSString *)field{
  
  [_headerField setValue:value forKey:field];
  
}

- (void)setupBaseUrl:(NSString *)baseUrl{
  
  _baseUrl = [baseUrl copy];
  
}

@end
