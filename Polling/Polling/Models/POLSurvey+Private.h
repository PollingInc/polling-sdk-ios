/*
 *  POLSurvey+Private.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLSurvey.h"

NS_ASSUME_NONNULL_BEGIN

@interface POLSurvey ()

@property (readwrite) NSString *UUID;
@property (readwrite) NSString *name;
@property (nullable, readwrite) POLReward *reward;
@property (readwrite) NSUInteger questionCount;

+ (instancetype)surveyFromDictionary:(NSDictionary *)dict;
+ (instancetype)surveyFromJSONDictionary:(NSDictionary *)dict;

+ (instancetype)surveyWithUUID:(NSString *)uuid;

- (NSDictionary<NSString *,id> *)dictionaryRepresentation;
- (NSString *)JSONRepresentation;

@end

NS_ASSUME_NONNULL_END
