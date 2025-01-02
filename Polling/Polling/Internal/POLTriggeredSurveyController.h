/*
*  POLTriggeredSurveyController.h
*  Polling
*
*  Copyright © 2024 Polling.com. All rights reserved
*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class POLTriggeredSurvey, POLSurvey;

@interface POLTriggeredSurveyController : NSObject

- (void)checkForAvailableTriggeredSurveys;
- (void)triggeredSurvey:(POLTriggeredSurvey *)triggeredSurvey didLoadSurvey:(POLSurvey *)survey;
- (void)triggeredSurveysDidUpdate:(NSArray<POLTriggeredSurvey *> *)triggeredSurveys;

- (void)removeSurvey:(POLSurvey *)survey;
- (void)postponeSurvey:(POLSurvey *)survey;

@end

NS_ASSUME_NONNULL_END
