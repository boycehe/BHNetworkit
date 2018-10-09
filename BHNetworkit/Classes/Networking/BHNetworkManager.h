//
//  BHNetworkManager.h
//  BHNetworking
//
//  Created by heboyce on 2018/1/18.
//

#import <Foundation/Foundation.h>
#import "BHRequest.h"
#import <AFNetworking/AFURLRequestSerialization.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "BHNetworkSignal.h"

NS_ASSUME_NONNULL_BEGIN

@interface BHNetworkManager : NSObject
  
+ (nonnull instancetype)manager;

- (nullable BHNetworkSignal *)rac_Request:(nullable BHRequest *)requestObj;

- (NSURLSessionDataTask *)createDataTask:(nullable BHRequest *)requestObj subscriber:(id<RACSubscriber> )subscriber;



@end
NS_ASSUME_NONNULL_END

