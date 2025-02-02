/*
 *  POLError.m
 *  Polling
 *
 *  Copyright © 2025 Polling.com. All rights reserved.
 */

#import "POLError.h"

NSString * const POLPollingErrorDomain = @"com.polling.sdk.ios.error";

NSString * const POLErrorFileKey = @"file";
NSString * const POLErrorMethodKey = @"method";
NSString * const POLErrorLineNumberKey = @"lineNumber";

@interface POLError ()
@property NSError *underlyingError;
@end

@implementation POLError

+ (instancetype)errorWithCode:(NSInteger)code userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict
{
	return [self errorWithDomain:POLPollingErrorDomain code:code userInfo:dict];
}

+ (instancetype)errorWithCode:(NSInteger)code underlyingError:(NSError *)underlyingError
					 userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict
{
	POLError *err = [self errorWithDomain:POLPollingErrorDomain code:code userInfo:dict];
	err.underlyingError = underlyingError;
	return err;
}

- (NSArray<NSError *> *)underlyingErrors
{
	return @[ self.underlyingError ].copy;
}

- (NSString *)subsystem
{
	NSInteger code = self.code;
	if (code < 100)
		return @"General";
	else if (code >= 100 && code < 200)
		return @"SDK";
	else if (code >= 200 && code < 300)
		return @"Network";
	else if (code >= 300 && code < 400)
		return @"Survey";
	else if (code >= 400 && code < 500)
		return @"Reward";
	else if (code >= 500 && code < 600)
		return @"TriggeredSurvey";
	else if (code >= 600 && code < 700)
		return @"Storage";
	else if (code >= 700 && code < 800)
		return @"ViewController";
	else if (code >= 800 && code < 900)
		return @"WebView";
	else
		return @"Unknown";
}

- (NSString *)category
{
	NSInteger code = self.code;
	if (code >= 200 && code < 300) {
		if (code >= 201 && code < 210)
			return @"URL";
		else if (code >= 210 && code < 220)
			return @"Task";
		else if (code >= 220 && code < 230)
			return @"ResponseHeader";
		else if (code >= 230 && code < 240)
			return @"ResponseBody";
		else
			return @"Unknown";
	} else
		return @"None";
}

@end
