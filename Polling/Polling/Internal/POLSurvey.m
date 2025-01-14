/*
 *  POLSurvey.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLSurvey.h"
#import "POLSurvey+Private.h"
#import "POLReward.h"
#import "POLReward+Private.h"
#import "POLNetworkSession.h"
#import "POLPolling.h"
#import "NSDictionary+Additions.h"

#if USE_LOCAL_SERVER
NSString * const POLSurveyViewEndpoint = @"http://localhost:8080/sdk/survey";
NSString * const POLSurveyDefaultEmbedViewEndpoint = @"http://localhost:8080/embed/";
#else
NSString * const POLSurveyViewEndpoint = @"https://app.polling.com/sdk/survey";
NSString * const POLSurveyDefaultEmbedViewEndpoint = @"https://app.polling.com/embed/";
#endif

NSString * const POLSurveyStatusAvailable = @"available";
NSString * const POLSurveyStatusStarted = @"started";
NSString * const POLSurveyStatusCompleted = @"completed";

@implementation POLSurvey

- initWithDictionary:(NSDictionary *)dict
{
	if (!(self = super.init))
		return nil;

	_name = dict[@"name"];
	_questionCount = [dict[@"questionCount"] unsignedIntegerValue];
	_UUID = dict[@"UUID"];
	_userSurveyStatus = dict[@"userSurveyStatus"];
	_completedAt = dict[@"completedAt"];

	NSDictionary *rewardDict = dict[@"reward"];
	if (rewardDict)
		_reward = [POLReward rewardFromDictionary:rewardDict];

	return self;
}

/*
 *	survey: {
 *		name = "Survey Test SDK 1";
 *		"question_count" = 1;
 *		reward =     {
 *			"reward_amount" = "<null>";
 *			"reward_name" = "<null>";
 *		};
 *		uuid = "dcaca06d-5ed5-4235-90fb-e2d7efc2a5b6";
 *	}
 */
- initWithJSONDictionary:(NSDictionary *)dict
{
	if (!(self = super.init))
		return nil;

	_name = dict[@"name"];
	_questionCount = [dict[@"question_count"] unsignedIntegerValue];

	/* depending on context the UUID is either `uuid` or `survery_uuid` */
	_UUID = [dict pol_stringValueForKey:@"uuid" undefinedValue:
			 [dict pol_stringValueForKey:@"survey_uuid" undefinedValue:@""]];

	_userSurveyStatus = dict[@"user_survey_status"];
	_completedAt = dict[@"completed_at"];

	NSDictionary *rewardDict = dict[@"reward"];
	if (rewardDict)
		_reward = [POLReward rewardFromJSONDictionary:rewardDict];

	return self;
}

+ (instancetype)surveyFromJSONDictionary:(NSDictionary *)dict
{
	return [[self alloc] initWithJSONDictionary:dict];;
}

+ (instancetype)surveyFromDictionary:(NSDictionary *)dict
{
	return [[self alloc] initWithDictionary:dict];
}

+ (instancetype)surveyWithUUID:(NSString *)uuid
{
	return [self surveyFromDictionary:@{ @"UUID": uuid }];
}

- (NSURL *)URL
{
	NSURL *url = [NSURL URLWithString:POLSurveyViewEndpoint];
	url = [url URLByAppendingPathComponent:_UUID];
	url = [POLNetworkSession URLForEndpoint:url.absoluteString
							 withCustomerID:POLPolling.polling.customerID
									 APIKey:POLPolling.polling.apiKey];
	return url;
}

- (NSURL *)embedViewURL
{
	NSURL *url = [NSURL URLWithString:POLSurveyDefaultEmbedViewEndpoint];
	url = [url URLByAppendingPathComponent:POLPolling.polling.apiKey];
	if (_UUID)
		url = [url URLByAppendingPathComponent:_UUID];
	url = [POLNetworkSession URLForEndpoint:url.absoluteString
							 withCustomerID:POLPolling.polling.customerID
									 APIKey:nil];
	return url;
}

/* completionURL = baseApiUrl + /api/sdk/surverys/:uuid */
- (NSURL *)completionURL
{
	NSURL *url = [NSURL URLWithString:POLNetworkSessionSurveyAPIEndpoint];
	url = [url URLByAppendingPathComponent:_UUID];
	url = [POLNetworkSession URLForEndpoint:url.absoluteString
							 withCustomerID:POLPolling.polling.customerID
									 APIKey:POLPolling.polling.apiKey];
	return url;
}

- (BOOL)isAvailable
{
	return [_userSurveyStatus isEqualToString:POLSurveyStatusAvailable];
}

- (BOOL)isStarted
{
	return [_userSurveyStatus isEqualToString:POLSurveyStatusStarted];
}

- (BOOL)isCompleted
{
	return [_userSurveyStatus isEqualToString:POLSurveyStatusCompleted];
}

- (BOOL)isEqual:(id)object
{
	if (self == object)
		return YES;
	if (![object isKindOfClass:self.class])
		return NO;
	return [self isEqualToSurvey:object];
}

- (BOOL)isEqualToSurvey:(POLSurvey *)otherSurvey
{
	return [self.UUID isEqualToString:otherSurvey.UUID];
}

- (NSDictionary<NSString *,id> *)dictionaryRepresentation
{
	return @{
		@"UUID": self.UUID,
		@"name": self.name,
		@"userSurveyStatus": self.userSurveyStatus ? self.userSurveyStatus : @"",
	};
}

- (NSString *)JSONRepresentation
{
	NSDictionary *dict = @{
		@"uuid": self.UUID,
		@"name": self.name,
		@"reward": @{
			@"reward_name": self.reward.name,
			@"reward_amount": self.reward.amount,
		},
		@"question_count": @(self.questionCount),
		@"user_survey_status": self.userSurveyStatus,
		@"completed_at": self.completedAt,

	};
	NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
	return [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p name='%@', UUID=%@ status=%@>",
			NSStringFromClass(self.class),
			self,
			self.name,
			self.UUID,
			self.userSurveyStatus
	];
}

@end
