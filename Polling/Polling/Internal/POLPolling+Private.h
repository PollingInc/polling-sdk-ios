/*
 *  POLPolling+Private.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */


#import "POLPolling.h"
#import "POLError.h"
#import "POLLog.h"

NS_ASSUME_NONNULL_BEGIN

@class POLTriggeredSurvey;

@interface POLPolling ()

@property (readonly,getter=isSurveyVisible) BOOL surveyVisible;

@property NSMutableArray<POLSurvey *> *openedSurveys;

- (void)getSurveyDetailsForTriggeredSurvey:(POLTriggeredSurvey *)triggeredSurvey;
- (void)postponeSurvey:(POLSurvey *)survey;

- (void)presentSurveyInternal:(POLSurvey *)survey;

@end

NS_ASSUME_NONNULL_END
