/*
 *  NSDictionary+Additions.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "NSDictionary+Additions.h"
#import "NSMutableDictionary+Additions.h"

@implementation NSDictionary (POLDictionaryAdditions)

- (NSString *)pol_stringValueForKey:(NSString *)key
					 undefinedValue:(NSString *)undefinedValue
{
	NSString *ret = self[key];
	if (!ret)
		return undefinedValue;
	return ret;
}

- (NSDictionary *)pol_dictionaryValueForKey:(NSString *)key
							 undefinedValue:(NSDictionary *)undefinedValue
{
	NSDictionary *ret = self[key];
	if (!ret)
		return undefinedValue;
	return ret;
}

- (NSDate *)pol_dateValueForKey:(NSString *)key
				 undefinedValue:(NSDate *)undefinedValue
{
	NSDate *ret = self[key];
	if (!ret)
		return undefinedValue;
	return ret;
}

- (CGSize)pol_sizeValueForKey:(NSString *)key
			   undefinedValue:(CGSize)size
{
	NSValue *ret = self[key];
	if (!ret)
		return size;
	return [ret CGSizeValue];
}

- (NSDictionary *)copyAddingEntriesFromDictionary:(NSDictionary *)other
{
	NSMutableDictionary *mutDict = self.mutableCopy;
	[mutDict addEntriesFromDictionary:other];
	return mutDict;
}

@end
