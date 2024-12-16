/*
 *  POLSurvey+Private.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLSurvey.h"

NS_ASSUME_NONNULL_BEGIN

@interface POLSurvey ()

//@property (readwrite) NSURL *URL;
//@property (readwrite) NSURL *completionURL;
@property (readwrite) NSString *surveyUUID;

@property (readwrite) NSString *UUID;
@property (readwrite) NSString *name;
@property (nullable, readwrite) POLReward *reward;
@property (readwrite) NSUInteger questionCount;

@property NSString *customerID;
@property NSString *apiKey;

+ (instancetype)surveyFromDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
