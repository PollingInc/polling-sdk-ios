/*
*  POLTriggeredSurvey.h
*  Polling
*
*  Copyright © 2024 Polling.com. All rights reserved
*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class POLSurvey;

@interface POLTriggeredSurvey : NSObject

@property POLSurvey *survey;

@property NSUInteger delaySeconds;
@property (readonly) NSString *delayedTimestamp;
@property (readonly) NSDate *delayedDate;

@property (getter=isInUse) BOOL inUse;

+ (instancetype)triggeredSurveyFromDictionary:(NSDictionary *)dict;
+ (instancetype)triggeredSurveyFromJSONDictionary:(NSDictionary *)dict;

- (void)postpone;

- (BOOL)isEqualToTriggeredSurvey:(POLTriggeredSurvey *)otherTriggeredSurvey;

- (NSDictionary<NSString *,id> *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
