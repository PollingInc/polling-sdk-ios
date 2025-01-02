/*
*  POLSurveyResponse.h
*  Polling
*
*  Copyright © 2024 Polling.com. All rights reserved
*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class POLTriggeredSurvey;

@interface POLSurveyResponse : NSObject
@property NSString *message;
@property NSArray<POLTriggeredSurvey *> *triggeredSurveys;
@end

NS_ASSUME_NONNULL_END
