//
//  BHSubjectPool.h
//  AFNetworking
//
//  Created by heboyce on 2018/1/26.
//

#import <Foundation/Foundation.h>
#import "BHNetworkSignal.h"

@interface BHSubjectPool : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)sharedPool;

- (void)addSubject:(id<RACSubscriber>)subject identifier:(NSString *)identifer;
- (NSArray<id<RACSubscriber>> *)allSubjects:(NSString *)identifier;


@end
