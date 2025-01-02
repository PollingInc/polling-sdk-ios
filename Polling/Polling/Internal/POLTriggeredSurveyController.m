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

- (void)triggerSurvey:(POLTriggeredSurvey *)survey withDelay:(NSUInteger)delay;
- (void)triggerSurvey:(NSTimer *)timer;

@end

@implementation POLTriggeredSurveyController {
	POLStorage *_storage;
	NSMutableDictionary<NSString *, NSTimer *> *_timers;
}

- (instancetype)init
{
	if (!(self = [super init]))
		return nil;

	_storage = POLStorage.storage;
	_timers = [NSMutableDictionary<NSString *, NSTimer *> new];

	return self;
}

- (void)checkForAvailableTriggeredSurveys
{
	if (POLPolling.polling.isSurveyVisible)
		return;

	NSArray<POLTriggeredSurvey *> *triggeredSurveys = POLStorage.storage.triggeredSurveys;
	if (triggeredSurveys.count == 0) {
		NSLog(@"No triggered surveys available.");
		return;
	}

	NSLog(@"Triggered surveys available.");
	NSDate *now = NSDate.date;
	NSUInteger delayInSeconds = 0;

	for (POLTriggeredSurvey *triggeredSurvey in triggeredSurveys) {
		if ([triggeredSurvey.delayedDate compare:now] == NSOrderedAscending)
			delayInSeconds = 0;
		else
			delayInSeconds = triggeredSurvey.delaySeconds;
		NSLog(@"Final delay is %@", @(triggeredSurvey.delaySeconds));

		if (triggeredSurvey.isInUse)
			continue;

		[self triggerSurvey:triggeredSurvey withDelay:delayInSeconds];
	}
}

- (void)triggerSurvey:(POLTriggeredSurvey *)triggeredSurvey withDelay:(NSUInteger)delay
{
	NSLog(@"%s timers=%@", __func__, _timers);
	NSString *uuid = triggeredSurvey.survey.UUID;
	NSTimer *timer = _timers[uuid];
	if (timer && timer.isValid)
		return;

	NSTimeInterval timeInterval = delay;
	NSLog(@"%@ scheduled to show in %@ seconds", triggeredSurvey, @(timeInterval));
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
		NSLog(@"%s %@", __func__, triggeredSurvey);
		POLStorage.storage.triggeredSurveys = savedSurveys;
	}

	[POLPolling.polling getSurveyDetailsForTriggeredSurvey:triggeredSurvey];
}

- (void)triggeredSurvey:(POLTriggeredSurvey *)triggeredSurvey didLoadSurvey:(POLSurvey *)survey
{
	NSLog(@"%s triggeredSurvey=%@, survey=%@", __func__, triggeredSurvey, survey);
	if (!survey.isAvailable) {
		[self triggeredSurveyUnavailable:triggeredSurvey];
		return;
	}

	NSLog(@"Found survey in available status. Requesting showSurvey");
	//[POLPolling.polling showSurvey:survey.UUID];
	[POLPolling.polling presentSurveyInternal:survey];

	NSArray<POLTriggeredSurvey *> *savedSurveys = POLStorage.storage.triggeredSurveys;
	if ([savedSurveys containsObject:triggeredSurvey]) {
		triggeredSurvey.inUse = NO;
		POLStorage.storage.triggeredSurveys = savedSurveys;
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

	NSLog(@"Keep checking for available triggered surveys.");
	[self checkForAvailableTriggeredSurveys];
}

- (void)removeSurvey:(POLSurvey *)survey
{
	NSLog(@"%s %@", __func__, survey);
	NSArray<POLTriggeredSurvey *> *triggeredSurveys = POLStorage.storage.triggeredSurveys;
	NSString *uuid = survey.UUID;
	NSUInteger idx = [triggeredSurveys indexOfObjectPassingTest:^BOOL(POLTriggeredSurvey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		return [obj.survey.UUID isEqualToString:uuid];
	}];
	if (idx == NSNotFound) {
		NSLog(@"Attempt to remove survey not in stored triggered surveys.");
		return;
	}
	POLTriggeredSurvey *triggeredSurvey = triggeredSurveys[idx];
	[self removeTriggeredSurvey:triggeredSurvey];
}

- (void)removeTriggeredSurvey:(POLTriggeredSurvey *)triggeredSurvey
{
	/* TODO: verify this works */
	NSArray<POLTriggeredSurvey *> *triggeredSurveys = POLStorage.storage.triggeredSurveys;
	NSString *uuid = triggeredSurvey.survey.UUID;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"survey.UUID != %@", uuid];
	triggeredSurveys = [triggeredSurveys filteredArrayUsingPredicate:predicate];
	POLStorage.storage.triggeredSurveys = triggeredSurveys;
}

- (void)triggeredSurveysDidUpdate:(NSArray<POLTriggeredSurvey *> *)triggeredSurveys
{
	NSArray<POLTriggeredSurvey *> *savedSurveys = POLStorage.storage.triggeredSurveys;
	if (savedSurveys.count == 0) {
		POLStorage.storage.triggeredSurveys = triggeredSurveys;
		return;
	}

	NSMutableSet<POLTriggeredSurvey *> *savedSurveysSet = [NSMutableSet<POLTriggeredSurvey *> setWithArray:savedSurveys];
	NSSet<POLTriggeredSurvey *> *triggeredSurveysSet = [NSSet<POLTriggeredSurvey *> setWithArray:triggeredSurveys];

	[savedSurveysSet unionSet:triggeredSurveysSet];

	POLStorage.storage.triggeredSurveys = savedSurveysSet.allObjects;

	NSLog(@"checkForAvailableTriggeredSurveys after update");
	[self checkForAvailableTriggeredSurveys];
}

- (void)postponeSurvey:(POLSurvey *)survey
{
	NSLog(@"%s %@", __func__, survey);
	NSArray<POLTriggeredSurvey *> *triggeredSurveys = POLStorage.storage.triggeredSurveys;
	NSString *uuid = survey.UUID;
	NSUInteger idx = [triggeredSurveys indexOfObjectPassingTest:^BOOL(POLTriggeredSurvey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		return [obj.survey.UUID isEqualToString:uuid];
	}];
	if (idx == NSNotFound) {
		NSLog(@"Attempt to postpone survey not in stored triggered surveys.");
		return;
	}
	POLTriggeredSurvey *triggeredSurvey = triggeredSurveys[idx];
	[triggeredSurvey postpone];
	POLStorage.storage.triggeredSurveys = triggeredSurveys;
}

@end
