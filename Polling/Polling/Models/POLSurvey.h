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

@property (readonly) NSString *URL;
@property (readonly) NSString *completionURL;
@property (readonly) NSString *surveyUUID;

@property (readonly) NSString *UUID;
@property (readonly) NSString *name;
@property (readonly) POLReward *reward;
@property (readonly) NSUInteger questionCount;
@property (readonly) NSString *userSurveyStatus;
@property (readonly) NSDate *completedAt;

@end

NS_ASSUME_NONNULL_END
