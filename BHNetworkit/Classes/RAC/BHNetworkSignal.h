//
//  BHNetworkSignal.h
//  AFNetworking
//
//  Created by heboyce on 2018/1/30.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/RACDynamicSignal.h>


@interface BHNetworkSignal : RACSignal
  
+ (instancetype)createSignalWithIdentifier:(NSString *)identifier subscribe:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe;
+ (instancetype)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe;
+ (instancetype)subject;
//belongTo会对signal进行强引用，生命周期为belongTo的生命周期，即belongTo被销毁时，signal才会被销毁,如果不想这么做请使用 + (instancetype)subject;
+ (instancetype)subjectBelong:(id)belongTo;
 
/**
 * 发起网络请求，并且订阅，会将返回的json包装成model
 如果不需要对JSON出来可以调用，RACSignal的相关方法
 */
- (RACDisposable *)subscriberWithClass:(Class)class model:(void (^)(id x))model error:(void (^)(NSError *error))error completed:(void (^)(void))completed;
/**
 * 这里只是订阅，并不会主动发起网络请求，返回的json会被包装成model
 */
- (RACDisposable *)subscriberIdentifier:(NSString *)identifier model:(void (^)(id x))model error:(void (^)(NSError *error))error completed:(void (^)(void))completed;

/*
 * 这里只是订阅，并不会主动发起网络请求,不会对JSON做额外处理
 */
- (RACDisposable *)subscriberIdentifier:(NSString *)identifier next:(void (^)(id x))next error:(void (^)(NSError *error))error completed:(void (^)(void))completed;

@end
