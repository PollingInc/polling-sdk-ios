/*
 *  NSDictionary+Additions.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (POLDictionaryAdditions)

- (NSString *)pol_stringValueForKey:(NSString *)key undefinedValue:(NSString *)undefinedValue;
- (NSDictionary *)pol_dictionaryValueForKey:(NSString *)key undefinedValue:(NSDictionary *)undefinedValue;
- (NSDate *)pol_dateValueForKey:(NSString *)key undefinedValue:(NSDate *)undefinedValue;

- (NSDictionary *)copyAddingEntriesFromDictionary:(NSDictionary *)other;

@end

NS_ASSUME_NONNULL_END
