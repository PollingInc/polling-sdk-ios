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

@end
