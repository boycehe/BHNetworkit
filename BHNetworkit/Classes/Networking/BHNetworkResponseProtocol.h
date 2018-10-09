//
//  BHNetworkResponseProtocol.h
//  AFNetworking
//
//  Created by heboyce on 2018/1/31.
//

#import <Foundation/Foundation.h>

@protocol BHNetworkResponseProtocol <NSObject>
@optional
  
- (_Nullable id)resolveResponseObject:(_Nullable id)responseObject class:(_Nullable Class)class error:(NSError * _Nullable __autoreleasing * _Nullable)error;
  
- (NSError * _Nullable )vaildReponse:(NSURLResponse * _Nonnull )response responseObject:(_Nullable id)responseObject;
  
@end
