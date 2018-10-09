//
//  BHRACSubscriber.m
//  Pods
//
//  Created by heboyce on 2018/2/7.
//

#import "BHRACSubscriber.h"
#import <ReactiveObjC/RACEXTScope.h>
#import <ReactiveObjC/RACCompoundDisposable.h>


@interface BHRACSubscriber ()

// These callbacks should only be accessed while synchronized on self.
@property (nonatomic, copy) void (^next)(id value);
@property (nonatomic, copy) void (^error)(NSError *error);
@property (nonatomic, copy) void (^completed)(void);

@property (nonatomic, strong, readonly) RACCompoundDisposable *disposable;

@end

@implementation BHRACSubscriber


#pragma mark Lifecycle

+ (instancetype)subscriberWithNext:(void (^)(id x))next error:(void (^)(NSError *error))error completed:(void (^)(void))completed {
  BHRACSubscriber *subscriber = [[self alloc] init];
  
  subscriber->_next = [next copy];
  subscriber->_error = [error copy];
  subscriber->_completed = [completed copy];
  
  return subscriber;
}

- (instancetype)init {
  self = [super init];
  
  @unsafeify(self);
  
  RACDisposable *selfDisposable = [RACDisposable disposableWithBlock:^{
    @strongify(self);
    
    @synchronized (self) {
      self.next = nil;
      self.error = nil;
      self.completed = nil;
    }
  }];
  
  _disposable = [RACCompoundDisposable compoundDisposable];
  [_disposable addDisposable:selfDisposable];
  
  return self;
}

- (void)dealloc {
  [self.disposable dispose];
}

#pragma mark RACSubscriber

- (void)sendNext:(id)value {
  @synchronized (self) {
    void (^nextBlock)(id) = [self.next copy];
    if (nextBlock == nil) return;
    
    nextBlock(value);
  }
}

- (void)sendError:(NSError *)e {
  @synchronized (self) {
    void (^errorBlock)(NSError *) = [self.error copy];
    [self.disposable dispose];
    
    if (errorBlock == nil) return;
    errorBlock(e);
  }
}

- (void)sendCompleted {
  @synchronized (self) {
    void (^completedBlock)(void) = [self.completed copy];
    [self.disposable dispose];
    
    if (completedBlock == nil) return;
    completedBlock();
  }
}

- (void)didSubscribeWithDisposable:(RACCompoundDisposable *)otherDisposable {
  if (otherDisposable.disposed) return;
  
  RACCompoundDisposable *selfDisposable = self.disposable;
  [selfDisposable addDisposable:otherDisposable];
  
  @unsafeify(otherDisposable);
  
  // If this subscription terminates, purge its disposable to avoid unbounded
  // memory growth.
  [otherDisposable addDisposable:[RACDisposable disposableWithBlock:^{
    @strongify(otherDisposable);
    [selfDisposable removeDisposable:otherDisposable];
  }]];
}

@end
