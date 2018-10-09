//
//  BHBatchRequest.h
//  AFNetworking
//
//  Created by heboyce on 2018/2/6.
//

#import <Foundation/Foundation.h>
#import "BHRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface BHBatchRequest : NSObject
@property (nonatomic,strong,readonly) NSMutableArray         *requestArr;

- (void)addRequest:(BHRequest *)request;

- (void)addRequestsFromArray:(NSArray *)reqeusts;

- (nullable BHNetworkSignal *)rac_Singal;

@end
NS_ASSUME_NONNULL_END
