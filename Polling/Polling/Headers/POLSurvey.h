/*
 *  POLSurvey.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class POLReward;

NS_SWIFT_NAME(Polling.Survey)
@interface POLSurvey : NSObject

@property (readonly) NSString *UUID;
@property (readonly) NSString *name;
@property (nullable, readonly) POLReward *reward;
@property (readonly) NSUInteger questionCount;

@property (readonly) NSURL *URL;
@property (readonly) NSURL *completionURL;

@property (readonly) NSString *userSurveyStatus;

@property (readonly,getter=isAvailable) BOOL available;
@property (readonly,getter=isStarted) BOOL started;
@property (readonly,getter=isCompleted) BOOL completed;

@property (readonly) NSString *completedAt;
@property (readonly) NSDate *completedDate;

- (BOOL)isEqualToSurvey:(POLSurvey *)otherSurvey;

@end

NS_ASSUME_NONNULL_END
