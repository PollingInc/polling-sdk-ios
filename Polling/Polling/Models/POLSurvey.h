/*
 *  POLSurvey.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class POLReward;

@interface POLSurvey : NSObject

@property (readonly) NSString *UUID;
@property (readonly) NSString *name;
@property (nullable, readonly) POLReward *reward;
@property (readonly) NSUInteger questionCount;

@property (readonly) NSURL *URL;
@property (readonly) NSURL *embedViewURL;
@property (readonly) NSURL *completionURL;

@property (readonly) NSString *userSurveyStatus;

@property (readonly,getter=isAvailable) BOOL available;
@property (readonly,getter=isCompleted) BOOL completed;

@property (readonly) NSDate *completedAt;

- (BOOL)isEqualToSurvey:(POLSurvey *)otherSurvey;

@end

NS_ASSUME_NONNULL_END
