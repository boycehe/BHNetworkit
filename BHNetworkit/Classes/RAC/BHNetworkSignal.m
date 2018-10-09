//
//  BHNetworkSignal.m
//  AFNetworking
//
//  Created by heboyce on 2018/1/30.
//

#import "BHNetworkSignal.h"
#import <ReactiveObjC/RACCompoundDisposable.h>
#import <ReactiveObjC/RACEXTScope.h>
#import <ReactiveObjC/RACCompoundDisposable.h>
#import <ReactiveObjC/RACPassthroughSubscriber.h>
#import <ReactiveObjC/RACScheduler+Private.h>
#import <ReactiveObjC/RACSubscriber.h>
#import <libkern/OSAtomic.h>
#import "BHSubjectPool.h"
#import "BHRACSubscriber.h"
#import <objc/message.h>


@interface BHNetworkSignal ()
  
// The block to invoke for each subscriber.
@property (nonatomic, copy, readonly) RACDisposable  *(^didSubscribe)(id<RACSubscriber> subscriber);
@property (nonatomic,copy,readonly) NSString         *singalIdentifier;
@property (nonatomic,strong) BHRACSubscriber           *subscriber;
  
@end

@implementation BHNetworkSignal
  
+ (instancetype)createSignalWithIdentifier:(NSString *)identifier subscribe:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe{
  
  BHNetworkSignal *signal  = [[self alloc] init];
  signal->_didSubscribe     = [didSubscribe copy];
  signal->_singalIdentifier = [identifier copy];
  return [signal setNameWithFormat:@"+createNetworkSignal:"];
  
}
  
+ (instancetype)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe{
  
  return [self createSignalWithIdentifier:nil subscribe:didSubscribe];
  
}

+ (instancetype)subjectBelong:(id)belongTo{
  
  BHNetworkSignal *signal = [[self alloc] init];
  
  NSString *keyStr = [NSString stringWithFormat:@"%@%zd_Singal",NSStringFromClass([belongTo class]),arc4random()];
  
  objc_setAssociatedObject(belongTo, [keyStr UTF8String], signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  
  return signal;
}

+ (instancetype)subject{
    return [[self alloc] init];
}
- (RACDisposable *)subscriberWithClass:(Class)class model:(void (^)(id x))model error:(void (^)(NSError *error))error completed:(void (^)(void))completed{
  
  BHRACSubscriber *sub = [BHRACSubscriber subscriberWithNext:model error:error completed:completed];

  return [self subscribe:sub];
  
}
  
- (RACDisposable *)subscriberIdentifier:(NSString *)identifier model:(void (^)(id x))model error:(void (^)(NSError *error))error completed:(void (^)(void))completed{
  
  BHRACSubscriber *sub = [BHRACSubscriber subscriberWithNext:model error:error completed:completed];

  _singalIdentifier  = [identifier copy];
  return [self subscribe:sub];
  
}
  
- (RACDisposable *)subscriberIdentifier:(NSString *)identifier next:(void (^)(id x))next error:(void (^)(NSError *error))error completed:(void (^)(void))completed{
  
  BHRACSubscriber *sub = [BHRACSubscriber subscriberWithNext:next error:error completed:completed];

  _singalIdentifier  = [identifier copy];
  self.subscriber = sub;
  return [self subscribe:sub];
  
}
  
- (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
  NSCParameterAssert(subscriber != nil);
  
  RACCompoundDisposable *disposable = [RACCompoundDisposable compoundDisposable];

  [[BHSubjectPool sharedPool] addSubject:subscriber identifier:self.singalIdentifier];
  
  if (self.didSubscribe != NULL) {
    RACDisposable *schedulingDisposable = [RACScheduler.subscriptionScheduler schedule:^{
      RACDisposable *innerDisposable = self.didSubscribe(subscriber);
      [disposable addDisposable:innerDisposable];
    }];
    
    [disposable addDisposable:schedulingDisposable];
  }
  
  return disposable;
}
  
- (void)dealloc{
  
  NSLog(@"dealloc-----");
  
}
  
@end
