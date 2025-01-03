/*
 *  POLStorage.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class POLTriggeredSurvey;

@interface POLStorage : NSObject

+ (instancetype)storage;

- (id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;

- (void)read;
- (void)write;

@property NSArray<POLTriggeredSurvey *> *triggeredSurveys;
- (void)removeTriggeredSurvey:(POLTriggeredSurvey *)triggeredSurvey;
- (void)modifiedTriggeredSurvey:(POLTriggeredSurvey *)triggeredSurvey;

@end

NS_ASSUME_NONNULL_END
