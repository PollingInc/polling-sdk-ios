/*
 *  POLSurvey.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLSurvey.h"
#import "POLSurvey+Private.h"

@implementation POLSurvey

- initWithDictionary:(NSDictionary *)dict
{
	if (!(self = super.init))
		return nil;
	_URL = @"blank-url";
	_completionURL = @"fake-completion-url";
	_surveyUUID = @"survey-uuid";
	return self;
}

+ (instancetype)surveyFromDictionary:(NSDictionary *)dict
{
	return [[self alloc] initWithDictionary:dict];
}

@end

//@implementation POLSurvey
//
//@end
