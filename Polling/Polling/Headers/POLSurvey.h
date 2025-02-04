/*
 *  POLSurvey.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class POLReward;

/**
 * An object representing a survey
 *
 * @discussion
 * A model object that encapsulates information specific to a survey.
 */
NS_SWIFT_NAME(Polling.Survey)
@interface POLSurvey : NSObject

/** The survey's UUID */
@property (readonly) NSString *UUID;

/** Name of the survey  */
@property (readonly) NSString *name;

/** Reward associated with the survey or `nil` */
@property (nullable, readonly) POLReward *reward;

/** Number of questions the survey contains  */
@property (readonly) NSUInteger questionCount;

/** `YES` if the survey is available */
@property (readonly,getter=isAvailable) BOOL available;

/** `YES` if the survey has been opened but not completed */
@property (readonly,getter=isStarted) BOOL started;

/** `YES` when the survey is completed */
@property (readonly,getter=isCompleted) BOOL completed;

/**
 * Indicates whether a given survey is equal to the receiver
 *
 * @discussion
 * Surveys are considered the same if they have matching `UUID`
 * properties.
 *
 * @param otherSurvey The survey with which to compare to the receiver
 * survey.
 *
 * @return `YES` if otherSurvey is the same as the receiver, otherwise
 * NO.
 */
- (BOOL)isEqualToSurvey:(POLSurvey *)otherSurvey;

@end

NS_ASSUME_NONNULL_END
