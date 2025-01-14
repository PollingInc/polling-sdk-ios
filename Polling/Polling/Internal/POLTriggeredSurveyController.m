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
		POLLogInfo("No triggered surveys available");
		return;
	}

	POLLogInfo("Triggered survey(s) available count=%@", @(triggeredSurveys.count));
	NSDate *now = NSDate.date;

	for (POLTriggeredSurvey *triggeredSurvey in triggeredSurveys) {
		POLLogInfo("Triggered survey: %@", triggeredSurvey);

		POLLogInfo("API delay in seconds: %@", @(triggeredSurvey.delaySeconds));
		POLLogInfo("API delayed timestamp: %@", triggeredSurvey.delayedTimestamp);
		POLLogInfo("Delayed timestamp (UTC): %@", triggeredSurvey.delayedDate);
		POLLogInfo("Current time (UTC): %@", now);

		NSUInteger delayInSeconds = 0;
		if ([triggeredSurvey.delayedDate compare:now] == NSOrderedAscending)
			delayInSeconds = 0;
		else
			delayInSeconds = triggeredSurvey.delaySeconds;
		POLLogInfo("Final delay is %@", @(triggeredSurvey.delaySeconds));

		if (triggeredSurvey.isInUse)
			continue;

		[self scheduleTriggerSurvey:triggeredSurvey withDelay:delayInSeconds];
	}
}

- (void)scheduleTriggerSurvey:(POLTriggeredSurvey *)triggeredSurvey withDelay:(NSUInteger)delay
{
	POLLogTrace("%s triggeredSurvey=%@, delay=%@", __func__, triggeredSurvey, @(delay));
	NSString *uuid = triggeredSurvey.survey.UUID;
	NSTimer *timer = _timers[uuid];
	if (timer && timer.isValid) {
		POLLogWarn("Survey already scheduled: %@", triggeredSurvey);
		return;
	}

	NSTimeInterval timeInterval = delay;
	_timers[uuid] = [NSTimer scheduledTimerWithTimeInterval:timeInterval
													   target:self
													 selector:@selector(triggerSurvey:)
													 userInfo:triggeredSurvey
													  repeats:NO];
	POLLogInfo("Scheduled %@ to show in %@ seconds", triggeredSurvey, @(timeInterval));
}

- (void)triggerSurvey:(NSTimer *)timer
{
	POLLogTrace("%s timer=%@", __func__, timer);
	POLTriggeredSurvey *triggeredSurvey = (POLTriggeredSurvey *)timer.userInfo;
	[timer invalidate];
	[_timers removeObjectForKey:triggeredSurvey.survey.UUID];

	NSArray<POLTriggeredSurvey *> *savedSurveys = POLStorage.storage.triggeredSurveys;
	if ([savedSurveys containsObject:triggeredSurvey]) {
		triggeredSurvey.inUse = YES;
		POLLogInfo("Marking survey in use %@", triggeredSurvey);
		[POLStorage.storage modifiedTriggeredSurvey:triggeredSurvey];
	}

	[POLPolling.polling getSurveyDetailsForTriggeredSurvey:triggeredSurvey];
}

- (void)triggeredSurvey:(POLTriggeredSurvey *)triggeredSurvey didLoadSurvey:(POLSurvey *)survey
{
	POLLogTrace("%s triggeredSurvey=%@, survey=%@", __func__, triggeredSurvey, survey);

	//if (survey.isAvailable || survey.isStarted) {
	if (survey.isAvailable) {
		triggeredSurvey.survey = survey;
		[POLStorage.storage modifiedTriggeredSurvey:triggeredSurvey];

		POLLogInfo("Found survey in available status. Requesting showSurvey");
		[POLPolling.polling presentSurveyInternal:survey];

		NSArray<POLTriggeredSurvey *> *savedSurveys = POLStorage.storage.triggeredSurveys;
		if ([savedSurveys containsObject:triggeredSurvey]) {
			triggeredSurvey.inUse = NO;
			POLLogInfo("Unmarking survey in use %@", triggeredSurvey);
			[POLStorage.storage modifiedTriggeredSurvey:triggeredSurvey];
		}
	} else {
		[self triggeredSurveyUnavailable:triggeredSurvey];
		return;
	}
}

- (void)triggeredSurveyFailedToLoadSurvey:(POLTriggeredSurvey *)triggeredSurvey
{
	POLLogTrace("%s triggeredSurvey=%@", __func__, triggeredSurvey);
	[self triggeredSurveyUnavailable:triggeredSurvey];
}

- (void)triggeredSurveyUnavailable:(POLTriggeredSurvey *)triggeredSurvey
{
	POLLogTrace("%s triggeredSurvey=%@", __func__, triggeredSurvey);

	POLLogInfo("None of the present surveys are in available status");
	[self removeTriggeredSurvey:triggeredSurvey];
	[POLStorage.storage write];

	POLLogInfo("Keep checking for available triggered surveys");
	[self checkForAvailableTriggeredSurveys];
}

- (void)removeSurvey:(POLSurvey *)survey
{
	POLLogTrace("%s survey=%@", __func__, survey);

	NSArray<POLTriggeredSurvey *> *triggeredSurveys = POLStorage.storage.triggeredSurveys;
	NSString *uuid = survey.UUID;

	// use predicate & filter
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"survey.UUID == %@", uuid];
	triggeredSurveys = [triggeredSurveys filteredArrayUsingPredicate:predicate];
	if (triggeredSurveys.count == 0) {
		POLLogWarn("Attempt to remove survey not in storage");
		return;
	}
	POLTriggeredSurvey *triggeredSurvey = triggeredSurveys.firstObject;

	[self removeTriggeredSurvey:triggeredSurvey];
}

- (void)removeTriggeredSurvey:(POLTriggeredSurvey *)triggeredSurvey
{
	POLLogTrace("%s triggeredSurvey=%@", __func__, triggeredSurvey);
	[POLStorage.storage removeTriggeredSurvey:triggeredSurvey];
}

- (void)triggeredSurveysDidUpdate:(NSArray<POLTriggeredSurvey *> *)triggeredSurveys
{
	POLLogTrace("%s triggeredSurveys=%@", __func__, triggeredSurveys);

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

	POLLogInfo("Keep checking for available triggered surveys");
	[self checkForAvailableTriggeredSurveys];
}

- (void)postponeSurvey:(POLSurvey *)survey
{
	POLLogTrace("%s survey=%@", __func__, survey);

	NSArray<POLTriggeredSurvey *> *triggeredSurveys = POLStorage.storage.triggeredSurveys;
	NSString *uuid = survey.UUID;

	// use predicate & filter
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"survey.UUID == %@", uuid];
	triggeredSurveys = [triggeredSurveys filteredArrayUsingPredicate:predicate];
	if (triggeredSurveys.count == 0) {
		POLLogWarn("Attempt to postpone survey not in storage");
		return;
	}
	POLTriggeredSurvey *triggeredSurvey = triggeredSurveys.firstObject;
	
	[triggeredSurvey postpone];
	[POLStorage.storage modifiedTriggeredSurvey:triggeredSurvey];
	[POLStorage.storage write];
}

@end
