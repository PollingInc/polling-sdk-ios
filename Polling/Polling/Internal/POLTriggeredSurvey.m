/*
*  POLTriggeredSurvey.m
*  Polling
*
*  Copyright © 2024 Polling.com. All rights reserved
*/

#import "POLTriggeredSurvey.h"
#import "POLSurvey.h"
#import "POLSurvey+Private.h"
#import "NSDictionary+Additions.h"

static const NSTimeInterval POLTriggeredSurveyPostponeInterval = 60 * 30; // 30 minutes

@implementation POLTriggeredSurvey

- initWithDictionary:(NSDictionary *)dict
{
	if (!(self = super.init))
		return nil;

	NSDictionary *surveyDict = [dict pol_dictionaryValueForKey:@"survey" undefinedValue:@{
		@"UUID": @"00000000-0000-0000-0000-000000000000",
		@"name": @"Invalid triggered survey"
	}];
	_survey = [POLSurvey surveyFromDictionary:@{
		@"UUID": [surveyDict pol_stringValueForKey:@"UUID" undefinedValue:@"D0000000-0000-0000-0000-000000000000"],
		@"name": [surveyDict pol_stringValueForKey:@"name" undefinedValue:@"D Invalid triggered survey"],
		@"userSurveyStatus": [surveyDict pol_stringValueForKey:@"userSurveyStatus" undefinedValue:@""],
	}];
	_delaySeconds = [dict[@"delaySeconds"] unsignedIntegerValue];
	_delayedDate = [dict pol_dateValueForKey:@"delayedDate"
							  undefinedValue:[NSDate.date dateByAddingTimeInterval:(NSTimeInterval)_delaySeconds]];
	_inUse = [dict[@"inUse"] boolValue];

	return self;
}

/*
 * triggered survey: {
 *     "delay_seconds" = 42;
 *     survey = {
 *         name = "survey for event";
 *         "survey_uuid" = "FCF84939-2D89-4592-9D12-7169D1C6C433";
 *     };
 * }
 */
- initWithJSONDictionary:(NSDictionary *)dict
{
	if (!(self = super.init))
		return nil;

	NSDictionary *surveyDict = [dict pol_dictionaryValueForKey:@"survey" undefinedValue:@{
		@"survey_uuid": @"00000000-0000-0000-0000-000000000000",
		@"name": @"Invalid triggered survey"
	}];
	_survey = [POLSurvey surveyFromJSONDictionary:@{
		@"survey_uuid": [surveyDict pol_stringValueForKey:@"survey_uuid" undefinedValue:@"J0000000-0000-0000-0000-000000000000"],
		@"name": [surveyDict pol_stringValueForKey:@"name" undefinedValue:@"J Invalid triggered survey"],
		@"user_survey_status": [surveyDict pol_stringValueForKey:@"user_survey_status" undefinedValue:@""],
	}];
	_delaySeconds = [dict[@"delay_seconds"] unsignedIntegerValue];
	_delayedDate = [NSDate.date dateByAddingTimeInterval:(NSTimeInterval)_delaySeconds];

	return self;
}

+ (instancetype)triggeredSurveyFromJSONDictionary:(NSDictionary *)dict
{
	return [[self alloc] initWithJSONDictionary:dict];
}

+ (instancetype)triggeredSurveyFromDictionary:(NSDictionary *)dict
{
	return [[self alloc] initWithDictionary:dict];
}

- (NSString *)delayedTimestamp
{
	// https://datatracker.ietf.org/doc/html/rfc3339
	NSDateFormatter *RFC3339DateFormatter = NSDateFormatter.new;
	RFC3339DateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	RFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
	RFC3339DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	return [RFC3339DateFormatter stringFromDate:self.delayedDate];
}

- (void)postpone
{
	NSTimeInterval delay = (NSTimeInterval)_delaySeconds + POLTriggeredSurveyPostponeInterval;
	NSLog(@"previous delay seconds=%@, date=%@", @(_delaySeconds), _delayedDate);
	_delaySeconds = delay;
	_delayedDate = [_delayedDate dateByAddingTimeInterval:delay];
	NSLog(@"new delay seconds=%@, date=%@", @(_delaySeconds), _delayedDate);
}

- (BOOL)isEqual:(id)object
{
	if (self == object)
		return YES;
	if (![object isKindOfClass:self.class])
		return NO;
	return [self isEqualToTriggeredSurvey:object];
}

- (BOOL)isEqualToTriggeredSurvey:(POLTriggeredSurvey *)otherTriggeredSurvey
{
	return [self.survey.UUID isEqualToString:otherTriggeredSurvey.survey.UUID];
}

- (NSDictionary<NSString *,id> *)dictionaryRepresentation
{
	NSDictionary *dict = self.survey.dictionaryRepresentation;
	return @{
		@"survey": dict,
		@"delaySeconds": @(self.delaySeconds),
		@"delayDate": self.delayedDate,
		@"inUse": @(self.inUse),
	};
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p survey=%@, delaySeconds=%@, delayDate=%@, inUse=%@>",
			NSStringFromClass(self.class),
			self,
			self.survey,
			@(self.delaySeconds),
			self.delayedDate,
			@(self.inUse)
	];
}

@end
