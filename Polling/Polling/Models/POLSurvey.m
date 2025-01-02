/*
 *  POLSurvey.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLSurvey.h"
#import "POLSurvey+Private.h"
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

NSString * const POLSurveyStatusActive = @"active";
NSString * const POLSurveyStatusCompleted = @"completed";

@implementation POLSurvey

- initWithDictionary:(NSDictionary *)dict
{
	if (!(self = super.init))
		return nil;

	_name = dict[@"name"];
	_questionCount = [dict[@"questionCount"] unsignedIntegerValue];
	_reward = nil;
	_UUID = dict[@"UUID"];

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
	_reward = nil;
	_UUID = dict[@"uuid"];
	_userSurveyStatus = dict[@"user_survey_status"];

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
	if (!_userSurveyStatus)
		return NO;
	return [_userSurveyStatus isEqual:POLSurveyStatusActive];
}

- (BOOL)isCompleted
{
	if (!_userSurveyStatus)
		return NO;
	return [_userSurveyStatus isEqual:POLSurveyStatusCompleted];
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
		/*@"userSurveyStatus": self.userSurveyStatus ? self.userSurveyStatus : @"",*/
	};
}

- (NSString *)JSONRepresentation
{
	/* TODO: save the remote response and return it here or serialize
	 * the current state and return */
	return @"{}";
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p name='%@', questions=%@>",
			NSStringFromClass(self.class),
			self,
			self.name,
			@(self.questionCount)
	];
}

@end
