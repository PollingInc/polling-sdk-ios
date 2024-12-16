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

@property (readonly) NSURL *URL;
@property (readonly) NSURL *completionURL;
@property (readonly) NSString *surveyUUID;

@property (readonly) NSString *UUID;
@property (readonly) NSString *name;
@property (nullable, readonly) POLReward *reward;
@property (readonly) NSUInteger questionCount;
@property (readonly) NSString *userSurveyStatus;
@property (readonly) NSDate *completedAt;

@end

NS_ASSUME_NONNULL_END
