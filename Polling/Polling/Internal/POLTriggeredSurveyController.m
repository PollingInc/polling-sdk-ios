/*
*  POLTriggeredSurveyController.m
*  Polling
*
*  Copyright © 2024 Polling.com. All rights reserved
*/

#import "POLTriggeredSurveyController.h"
#import "POLPolling+Private.h"
#import "POLStorage.h"

#import "POLTriggeredSurvey.h"
#import "POLSurvey.h"

@interface POLTriggeredSurveyController ()

- (void)scheduleTriggerSurvey:(POLTriggeredSurvey *)survey withDelay:(NSUInteger)delay;
- (void)triggerSurvey:(NSTimer *)timer;

@end

@implementation POLTriggeredSurveyController {
	POLStorage *_storage;
	NSMutableDictionary<NSString *, NSTimer *> *_timers;
}

- init
{
	if (!(self = super.init))
		return nil;

	_storage = POLStorage.storage;
	_timers = [NSMutableDictionary<NSString *, NSTimer *> new];

	return self;
}

- (void)checkForAvailableTriggeredSurveys
{
	if (POLPolling.polling.isSurveyVisible)
		return;

	[POLStorage.storage read];
	NSArray<POLTriggeredSurvey *> *triggeredSurveys = POLStorage.storage.triggeredSurveys;
	if (triggeredSurveys.count == 0) {
		NSLog(@"No triggered surveys available.");
		return;
	}

	NSLog(@"Triggered surveys available.");
	NSDate *now = NSDate.date;

	for (POLTriggeredSurvey *triggeredSurvey in triggeredSurveys) {

		NSLog(@"API delay in seconds: %@", @(triggeredSurvey.delaySeconds));
		NSLog(@"API delayed timestamp: %@", triggeredSurvey.delayedTimestamp);
		NSLog(@"Delayed timestamp (UTC): %@", triggeredSurvey.delayedDate);
		NSLog(@"Current time (UTC): %@", now);

		NSUInteger delayInSeconds = 0;
		if ([triggeredSurvey.delayedDate compare:now] == NSOrderedAscending)
			delayInSeconds = 0;
		else
			delayInSeconds = triggeredSurvey.delaySeconds;
		NSLog(@"Final delay is %@", @(triggeredSurvey.delaySeconds));

		if (triggeredSurvey.isInUse)
			continue;

		[self scheduleTriggerSurvey:triggeredSurvey withDelay:delayInSeconds];
	}
}

- (void)scheduleTriggerSurvey:(POLTriggeredSurvey *)triggeredSurvey withDelay:(NSUInteger)delay
{
	NSString *uuid = triggeredSurvey.survey.UUID;
	NSTimer *timer = _timers[uuid];
	if (timer && timer.isValid)
		return;

	NSTimeInterval timeInterval = delay;
	NSLog(@"scheduled %@ to show in %@ seconds", triggeredSurvey, @(timeInterval));
	_timers[uuid] = [NSTimer scheduledTimerWithTimeInterval:timeInterval
													   target:self
													 selector:@selector(triggerSurvey:)
													 userInfo:triggeredSurvey
													  repeats:NO];
}

- (void)triggerSurvey:(NSTimer *)timer
{
	POLTriggeredSurvey *triggeredSurvey = (POLTriggeredSurvey *)timer.userInfo;
	[timer invalidate];
	[_timers removeObjectForKey:triggeredSurvey.survey.UUID];

	NSArray<POLTriggeredSurvey *> *savedSurveys = POLStorage.storage.triggeredSurveys;
	if ([savedSurveys containsObject:triggeredSurvey]) {
		triggeredSurvey.inUse = YES;
		NSLog(@"mark in use %@", triggeredSurvey);
		[POLStorage.storage modifiedTriggeredSurvey:triggeredSurvey];
	}

	[POLPolling.polling getSurveyDetailsForTriggeredSurvey:triggeredSurvey];
}

- (void)triggeredSurvey:(POLTriggeredSurvey *)triggeredSurvey didLoadSurvey:(POLSurvey *)survey
{
	//NSLog(@"%s triggeredSurvey=%@, survey=%@", __func__, triggeredSurvey, survey);
	NSLog(@"%s", __func__);

	//if (survey.isAvailable || survey.isStarted) {
	if (survey.isAvailable) {
		triggeredSurvey.survey = survey;
		[POLStorage.storage modifiedTriggeredSurvey:triggeredSurvey];

		NSLog(@"Found survey in available status. Requesting showSurvey");
		[POLPolling.polling presentSurveyInternal:survey];

		NSArray<POLTriggeredSurvey *> *savedSurveys = POLStorage.storage.triggeredSurveys;
		if ([savedSurveys containsObject:triggeredSurvey]) {
			triggeredSurvey.inUse = NO;
			NSLog(@"unmark in use %@", triggeredSurvey);
			[POLStorage.storage modifiedTriggeredSurvey:triggeredSurvey];
		}
	} else {
		[self triggeredSurveyUnavailable:triggeredSurvey];
		return;
	}
}

- (void)triggeredSurveyFailedToLoadSurvey:(POLTriggeredSurvey *)triggeredSurvey
{
	[self triggeredSurveyUnavailable:triggeredSurvey];
}

- (void)triggeredSurveyUnavailable:(POLTriggeredSurvey *)triggeredSurvey
{
	NSLog(@"None of the present surveys are in available status.");
	[self removeTriggeredSurvey:triggeredSurvey];
	[POLStorage.storage write];

	NSLog(@"Keep checking for available triggered surveys.");
	[self checkForAvailableTriggeredSurveys];
}

- (void)removeSurvey:(POLSurvey *)survey
{
	NSLog(@"%s %@", __func__, survey);
	NSArray<POLTriggeredSurvey *> *triggeredSurveys = POLStorage.storage.triggeredSurveys;
	NSString *uuid = survey.UUID;

	// use predicate & filter
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"survey.UUID == %@", uuid];
	triggeredSurveys = [triggeredSurveys filteredArrayUsingPredicate:predicate];
	if (triggeredSurveys.count == 0) {
		NSLog(@"Attempt to remove survey not in storage.");
		return;
	}
	POLTriggeredSurvey *triggeredSurvey = triggeredSurveys.firstObject;

	[self removeTriggeredSurvey:triggeredSurvey];
}

- (void)removeTriggeredSurvey:(POLTriggeredSurvey *)triggeredSurvey
{
	[POLStorage.storage removeTriggeredSurvey:triggeredSurvey];
}

- (void)triggeredSurveysDidUpdate:(NSArray<POLTriggeredSurvey *> *)triggeredSurveys
{
	NSArray<POLTriggeredSurvey *> *savedSurveys = POLStorage.storage.triggeredSurveys;
	if (savedSurveys.count == 0) {
		POLStorage.storage.triggeredSurveys = triggeredSurveys;
	} else {
		/* remove duplicates */
		NSMutableSet<POLTriggeredSurvey *> *savedSurveysSet = [NSMutableSet<POLTriggeredSurvey *> setWithArray:savedSurveys];
		NSSet<POLTriggeredSurvey *> *triggeredSurveysSet = [NSSet<POLTriggeredSurvey *> setWithArray:triggeredSurveys];
		[savedSurveysSet unionSet:triggeredSurveysSet];
		POLStorage.storage.triggeredSurveys = savedSurveysSet.allObjects;
	}
	[POLStorage.storage write];

	NSLog(@"checkForAvailableTriggeredSurveys after update");
	[self checkForAvailableTriggeredSurveys];
}

- (void)postponeSurvey:(POLSurvey *)survey
{
	NSLog(@"%s %@", __func__, survey);
	NSArray<POLTriggeredSurvey *> *triggeredSurveys = POLStorage.storage.triggeredSurveys;
	NSString *uuid = survey.UUID;

	// use predicate & filter
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"survey.UUID == %@", uuid];
	triggeredSurveys = [triggeredSurveys filteredArrayUsingPredicate:predicate];
	if (triggeredSurveys.count == 0) {
		NSLog(@"Attempt to remove survey not in storage.");
		return;
	}
	POLTriggeredSurvey *triggeredSurvey = triggeredSurveys.firstObject;
	
	[triggeredSurvey postpone];
	[POLStorage.storage modifiedTriggeredSurvey:triggeredSurvey];
	[POLStorage.storage write];
}

@end
