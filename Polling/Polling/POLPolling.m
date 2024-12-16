/*
 *  POLPolling.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLPolling.h"
#import "POLNetworkSession.h"
#import "POLSurveyViewController.h"

#import "Models/POLSurvey.h"
#import "Models/POLReward.h"

#if DEBUG
static const NSTimeInterval POLPollingPollRateInterval = 5;      // 1 seconds
#else
static const NSTimeInterval POLPollingPollRateInterval = 60;      // 1 minute
#endif
static const NSTimeInterval POLPollingPostponeInterval = 60 * 30; // 30 minutes

@interface POLPolling () <POLNetworkSessionDelegate, POLSurveyViewControllerDelegate>

- (void)beginCheckingForSurveys;
- (void)stopCheckingForSurveys;

- (void)loadAvailableSurveys;

@end

@implementation POLPolling {
	NSString *_customerID;
	NSString *_apiKey;
	NSTimer *_pollTimer;
	NSTimer *_postponeTimer;
	POLNetworkSession *_networkSession;
	POLSurveyViewController *_surveyViewController;
}

- initWithCustomerID:(NSString *)customerID APIKey:(NSString *)apiKey
{
	if (!(self = [super init]))
		return nil;

	_customerID = customerID;
	_apiKey = apiKey;
	_networkSession = POLNetworkSession.new;
	_networkSession.delegate = self;
	[self beginCheckingForSurveys];

	return self;
}

- (void)dealloc
{
	[self stopCheckingForSurveys];
}

- (void)beginCheckingForSurveys
{
	if (_pollTimer && _pollTimer.isValid)
		return;

	_pollTimer = [NSTimer scheduledTimerWithTimeInterval:POLPollingPollRateInterval
												  target:self
												selector:@selector(loadAvailableSurveys)
												userInfo:nil
												 repeats:YES];
}

- (void)stopCheckingForSurveys
{
	[_pollTimer invalidate];
	_pollTimer = nil;
}

- (void)loadAvailableSurveys
{
	NSLog(@"%s", __func__);
	[_networkSession fetchSurveysWithCustomerID:_customerID APIKey:_apiKey];
	(void)POLPollingPostponeInterval;
}

#pragma mark - Network Session Delegate

- (void)networkSessionDidFetchSurveys:(NSArray<POLSurvey *> *)surveys
{
	NSLog(@"%s %@", __func__, surveys);
	[self stopCheckingForSurveys];

	if ([self.delegate respondsToSelector:@selector(pollingSurveyDidBecomeAvailable)])
		[(id<POLPollingDelegate>)self.delegate pollingSurveyDidBecomeAvailable];
}

#pragma mark - Showing Surveys

- (UIViewController *)visibleViewController
{
	UIViewController *rootVC, *visVC;

	if (@available(iOS 13.0, *)) {
		NSArray<__kindof UIWindow *> *windows = UIApplication.sharedApplication.windows;
		if (windows.count == 1) {
			rootVC = windows.firstObject.rootViewController;
		} else {
			// TODO: needs to look for the active scene too
			for (UIWindow *window in windows)
				if (window.isKeyWindow)
					rootVC = window.rootViewController;
		}
	} else {
		rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
	}

	visVC = rootVC;

	if ([visVC isKindOfClass:[UINavigationController class]])
		return ((UINavigationController *)visVC).visibleViewController;

	if ([visVC isKindOfClass:[UITabBarController class]]) {
		UIViewController *selectedTVC = ((UITabBarController*)visVC).selectedViewController;
		if (selectedTVC)
			return selectedTVC;
	}

	if (visVC.presentedViewController)
		return visVC.presentedViewController;

	return visVC;
}

- (void)presentSurvey:(POLSurvey *)survey
{
	if (_surveyViewController)
		return;

	UIViewController *visVC = self.visibleViewController;
	_surveyViewController = [[POLSurveyViewController alloc] initWithSurvey:survey];
	_surveyViewController.delegate = self;
	[visVC presentViewController:_surveyViewController animated:YES completion:nil];
}

#pragma mark - Survey View Controller Delegate

- (void)surveyViewControllerDidDismiss
{
	//SEL dismissSel = @selector(surveyDidDismiss:);
	//SEL completeSel = @selector(surveyDidComplete:);
	//SEL succeedSel = @selector(surveyDidSucceed:);
	//SEL failSel = @selector(surveyDidFail:);

	POLSurvey *survey = _surveyViewController.survey;

	if ([self.delegate respondsToSelector:@selector(surveyDidSucceed:)])
		[(id<POLPollingDelegate>)self.delegate surveyDidSucceed:survey];

	_surveyViewController = nil;
}

@end
