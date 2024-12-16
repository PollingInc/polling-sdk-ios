/*
 *  POLSurvey.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLSurvey.h"
#import "POLSurvey+Private.h"

@implementation POLSurvey

//	survey: {
//		name = "Survey Test SDK 1";
//		"question_count" = 1;
//		reward =     {
//			"reward_amount" = "<null>";
//			"reward_name" = "<null>";
//		};
//		uuid = "dcaca06d-5ed5-4235-90fb-e2d7efc2a5b6";
//	}
- initWithDictionary:(NSDictionary *)dict
{
	if (!(self = super.init))
		return nil;

	_URL = @"";
	_completionURL = @"";
	_surveyUUID = @"survey-uuid";

	_name = dict[@"name"];
	_questionCount = [dict[@"question_count"] unsignedIntegerValue];
	_reward = nil;
	_UUID = dict[@"uuid"];

	return self;
}

+ (instancetype)surveyFromDictionary:(NSDictionary *)dict
{
	return [[self alloc] initWithDictionary:dict];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: name='%@', questions=%@>",
			self.className,
			self.name,
			@(self.questionCount)
	];
}

@end

//@implementation POLSurvey
//
//@end
