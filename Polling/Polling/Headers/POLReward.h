/*
 *  POLReward.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * An object representing a reward
 *
 * @discussion
 * A model object encapsulating a reward.
 */
NS_SWIFT_NAME(Polling.Reward)
@interface POLReward : NSObject

/** Name identifying the reward */
@property (readonly) NSString *name;

/** The reward amount */
@property (readonly) NSString *amount;

/** Additional information */
@property (readonly) NSString *completeExtraJSON;

@end

NS_ASSUME_NONNULL_END
