/*
 *  POLReward.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Polling.Reward)
@interface POLReward : NSObject
@property (readonly) NSString *name;
@property (readonly) NSString *amount;
@property (readonly) NSString *completeExtraJSON;
@end

NS_ASSUME_NONNULL_END
