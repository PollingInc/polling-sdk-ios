/*
 *  POLSurvey+Private.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLSurvey.h"

NS_ASSUME_NONNULL_BEGIN

@interface POLSurvey ()

@property (readwrite) NSString *URL;
@property (readwrite) NSString *completionURL;
@property (readwrite) NSString *surveyUUID;

+ (instancetype)surveyFromDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
