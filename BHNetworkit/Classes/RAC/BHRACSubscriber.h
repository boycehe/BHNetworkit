//
//  BHRACSubscriber.h
//  Pods
//
//  Created by heboyce on 2018/2/7.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/RACSubscriber.h>

@interface BHRACSubscriber : NSObject<RACSubscriber>

+ (instancetype)subscriberWithNext:(void (^)(id x))next error:(void (^)(NSError *error))error completed:(void (^)(void))completed;

@end
