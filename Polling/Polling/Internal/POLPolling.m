/*
 *  POLPolling.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLPolling.h"
#import "POLPolling+Private.h"
#import "POLNetworkSession.h"
#import "POLModernSurveyViewController.h"
#import "POLCompatibleSurveyViewController.h"
#import "POLPresentationController.h"
#import "POLSurveyDialogAnimateInController.h"
#import "POLSurveyBottomAnimateInController.h"
#import "POLTriggeredSurveyController.h"


#import "POLSurvey.h"
#import "POLSurvey+Private.h"
#import "POLReward.h"
#import "POLTriggeredSurvey.h"

//#if DEBUG
//static const NSTimeInterval POLPollingPollRateInterval = 5;       // 5 seconds
//#else
static const NSTimeInterval POLPollingPollRateInterval = 60;      // 1 minute
//#endif

static BOOL POLSDKInitialized = NO;
static BOOL POLSDKShutdown = NO;

void POLSetSDKInitialized(BOOL initialized)
{
	POLSDKInitialized = initialized;
}

BOOL POLIsSDKInitialized(void)
{
	return POLSDKInitialized;
}

void POLShutdownSDK(void)
{
	POLSDKShutdown = YES;
}

BOOL POLIsSDKShutdown(void)
{
	return POLSDKShutdown;
}

BOOL POLIsSDKDisabled(void)
{
	return !POLSDKInitialized || POLSDKShutdown;
}

NSString * const POLViewTypeNoneDescription = @"None";
NSString * const POLViewTypeDialogDescription = @"Dialog";
NSString * const POLViewTypeBottomDescription = @"Bottom";

NSString * const POLViewTypeDescriptions[] = {
	[POLViewTypeNone] = POLViewTypeNoneDescription,
	[POLViewTypeDialog] = POLViewTypeDialogDescription,
	[POLViewTypeBottom] = POLViewTypeBottomDescription,
};

NSString * const POLViewTypeDescription(POLViewType viewType)
{
	if (viewType > POL_ARRAY_SIZE(POLViewTypeDescriptions) - 1)
		return @"Unknown";
	return POLViewTypeDescriptions[viewType];
}

static NSUncaughtExceptionHandler *POLPreviousUncaughtExceptionHandler;
void POLUncaughtExceptionHandler(NSException *exception)
{
	POLLogError("%s exception=\"%@\", reason=\"%@\"", __func__, exception.name, exception.reason);
	POLLogTrace("%s callStackSymbols=%@", __func__, exception.callStackSymbols);
	POLLogTrace("%s callStackReturnAddresses=%@", __func__, exception.callStackReturnAddresses);

	// TODO: write to file and potentially send to a logging server on next launch

	POLShutdownSDK();

	// allow other frameworks or the app to handle uncaught exceptions
	if (POLPreviousUncaughtExceptionHandler)
		POLPreviousUncaughtExceptionHandler(exception);
}

NS_INLINE BOOL POLIsObviouslyInvalidString(NSString *str)
{
	if (!str)
		return YES;
	if ([str isEqualToString:@""])
		return YES;
	return NO;
}

@interface POLPolling () <POLNetworkSessionDelegate, POLSurveyViewControllerDelegate, UIViewControllerTransitioningDelegate>

- (void)beginSurveyChecks;
- (void)stopSurveyChecks;

- (void)performRemoteSurveyChecks;

- (UIViewController *)visibleViewController;

@end

@implementation POLPolling {
	NSString *_customerID;
	NSString *_apiKey;
	NSTimer *_pollTimer;
	NSTimer *_postponeTimer;
	POLNetworkSession *_networkSession;
	POLSurveyViewController *_surveyViewController;
	NSArray<POLSurvey *> *_cachedSurveys;
	POLTriggeredSurveyController *_triggeredSurveyController;
	POLTriggeredSurvey *_inboundTriggeredSurvey;
	POLSurvey *_currentSurvey;
}

- init
{
	if (!(self = [super init]))
		return nil;

	_networkSession = POLNetworkSession.new;
	_networkSession.delegate = self;
	_viewType = POLViewTypeDialog;
	_triggeredSurveyController = POLTriggeredSurveyController.new;
	_surveyVisible = NO;
	_inboundTriggeredSurvey = nil;

	return self;
}

- (NSString *)customerID
{
	return _customerID;
}

- (void)setCustomerID:(NSString *)customerID
{
	_customerID = customerID;
	if (POLIsObviouslyInvalidString(_customerID)) {
		POLSetSDKInitialized(NO);
		return;
	}
	if (POLIsObviouslyInvalidString(_apiKey)) {
		POLSetSDKInitialized(NO);
		return;
	}
	POLSetSDKInitialized(YES);
	[self beginSurveyChecks];
}

- (NSString *)apiKey
{
	return _apiKey;
}

- (void)setApiKey:(NSString *)apiKey
{
	_apiKey = apiKey;
	if (POLIsObviouslyInvalidString(_customerID)) {
		POLSetSDKInitialized(NO);
		return;
	}
	if (POLIsObviouslyInvalidString(_apiKey)) {
		POLSetSDKInitialized(NO);
		return;
	}
	POLSetSDKInitialized(YES);
	[self beginSurveyChecks];
}

#pragma mark - Public API

+ (instancetype)polling
{
	static POLPolling *pol;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		POLPreviousUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
		NSSetUncaughtExceptionHandler(POLUncaughtExceptionHandler);
		POLLogTrace("Create singleton=%@, method=%s", self, __func__);
		pol = POLPolling.new;
	});
	return pol;
}

- (void)logEvent:(NSString *)eventName value:(NSString *)eventValue
{
	POLGuardPublicAPI();
	POLLogTrace("%s %@:%@", __func__, eventName, eventValue);
	[_networkSession postEvent:eventName withValue:eventValue];
}

- (void)logPurchase:(int)integerCents
{
	POLGuardPublicAPI();
	[self logEvent:@"Purchase" value:[NSString stringWithFormat:@"%@", @(integerCents)]];
}

- (void)logSession
{
	POLGuardPublicAPI();
	[self logEvent:@"Session" value:@""];
}

- (void)showEmbedView
{
	POLGuardPublicAPI();
	[self presentEmbed];
}

- (void)showSurvey:(NSString *)surveyUuid
{
	POLGuardPublicAPI();
	[self presentSurveyInternal:[POLSurvey surveyWithUUID:surveyUuid]];
}

#pragma mark - Internal

- (void)dealloc
{
	[self stopSurveyChecks];
}

- (void)beginSurveyChecks
{
	if (_pollTimer && _pollTimer.isValid)
		return;

	_pollTimer = [NSTimer scheduledTimerWithTimeInterval:POLPollingPollRateInterval
												  target:self
												selector:@selector(performRemoteSurveyChecks)
												userInfo:nil
												 repeats:YES];
}

- (void)stopSurveyChecks
{
	[_pollTimer invalidate];
	_pollTimer = nil;
}

- (void)performRemoteSurveyChecks
{
	if (POLIsSDKDisabled()) {
		[self stopSurveyChecks];
		return;
	}

	if (!_disableCheckingForAvailableSurveys)
		[_networkSession fetchAvailableSurveys];

	[_triggeredSurveyController checkForAvailableTriggeredSurveys];
}

- (void)getSurveyDetailsForTriggeredSurvey:(POLTriggeredSurvey *)triggeredSurvey
{
	POLLogTrace("%s", __func__);
	_inboundTriggeredSurvey = triggeredSurvey;
	[_networkSession fetchSurveyWithUUID:triggeredSurvey.survey.UUID];
}

- (void)postponeSurvey:(POLSurvey *)survey
{
	[_triggeredSurveyController postponeSurvey:survey];
}

#pragma mark - Network Session Delegate

- (void)networkSessionDidFetchAvailableSurveys:(NSArray<POLSurvey *> *)surveys
{
	POLLogTrace("%s %@", __func__, surveys);

	_cachedSurveys = surveys;
	if (_cachedSurveys.count == 0)
		return;

	if ([self.delegate respondsToSelector:@selector(pollingOnSurveyAvailable)])
		[(id<POLPollingDelegate>)self.delegate pollingOnSurveyAvailable];
}

- (void)networkSessionDidUpdateTriggeredSurveys:(NSArray<POLTriggeredSurvey *> *)triggeredSurvey
{
	POLLogTrace("%s %@", __func__, triggeredSurvey);
	[_triggeredSurveyController triggeredSurveysDidUpdate:triggeredSurvey];
}

- (void)networkSessionDidFetchSurvey:(POLSurvey *)survey
{
	POLLogTrace("%s %@", __func__, survey);
	if (_inboundTriggeredSurvey) {
		[_triggeredSurveyController triggeredSurvey:_inboundTriggeredSurvey didLoadSurvey:survey];
		_inboundTriggeredSurvey = nil;
	}
}

- (void)networkSessionDidCompleteSurvey:(POLSurvey *)survey
{
	POLLogTrace("%s %@", __func__, survey);

	if (!survey.isCompleted) {
		[_triggeredSurveyController postponeSurvey:survey];
		return;
	}

	// success
	if ([self.delegate respondsToSelector:@selector(pollingOnSuccess:)])
		[self.delegate pollingOnSuccess:survey.JSONRepresentation];

	// reward
	if ([self.delegate respondsToSelector:@selector(pollingOnReward:)])
		[self.delegate pollingOnReward:survey.reward];

	// completion
	if (!survey.isAvailable)
		[_triggeredSurveyController removeSurvey:survey];
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
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
#pragma GCC diagnostic pop
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

- (void)presentSurveyInternal:(POLSurvey *)survey
{
	_currentSurvey = survey;

	/*
	 * NOTE:
	 * iPhone does not have a "dialog" like view controller
	 * presentation. Additionally iPadOS does have a "dialog' like
	 * view controller presentation style, but its behavior is
	 * inconsistent in a Mac Catalyst app. We use a custom view
	 * controller for consistency across all target platforms.
	 *
	 * iOS 15+ can use the UISheetPresentationController and detents
	 * to display a half-sheet, but anything below requires trickery
	 * to and so we use a custom view controller too.
	 */

	/* TODO: logic for picking the best view controller and
	 * presentation style */

	[self presentCompatibleSurvey:survey];
}

- (void)presentEmbed
{
	if (_currentSurvey)
		_currentSurvey.embedViewRequested = YES;
	else {
		_currentSurvey = POLSurvey.new;
		_currentSurvey.embedViewRequested = YES;
	}

	[self presentSurveyInternal:_currentSurvey];
}

- (void)presentSurvey:(POLSurvey *)survey
{
	if (_surveyViewController)
		return;

	UIViewController *visVC = self.visibleViewController;

	_surveyViewController = [[POLModernSurveyViewController alloc] initWithSurvey:survey];
	_surveyViewController.delegate = self;

	if (_viewType == POLViewTypeDialog) {
		_surveyViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
			_surveyViewController.modalPresentationStyle = UIModalPresentationCustom;
			_surveyViewController.transitioningDelegate = self;
		} else {
			_surveyViewController.modalPresentationStyle = UIModalPresentationFormSheet;

		}
	} else if (_viewType == POLViewTypeBottom) {
		_surveyViewController.modalPresentationStyle = UIModalPresentationPageSheet;
		_surveyViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	}

	_surveyVisible = YES;
	[visVC presentViewController:_surveyViewController animated:YES completion:nil];
}

- (void)presentCompatibleSurvey:(POLSurvey *)survey
{
	if (_surveyViewController)
		return;

	UIViewController *visVC = self.visibleViewController;

	_surveyViewController = [[POLCompatibleSurveyViewController alloc] initWithSurvey:survey viewType:_viewType];
	_surveyViewController.delegate = self;
	_surveyViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
	_surveyViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	_surveyViewController.transitioningDelegate = self;

	_surveyVisible = YES;
	[visVC presentViewController:_surveyViewController animated:YES completion:nil];
}

#pragma mark - View Controller Trasitioning Delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
	presentingController:(UIViewController *)presenting
	sourceController:(UIViewController *)source
{
	POLLogTrace("%s presented=%@, presenting=%@, source=%@", __func__, presented, presenting, source);

	if ([presented isKindOfClass:POLCompatibleSurveyViewController.class]) {
		POLCompatibleSurveyViewController *vc = (POLCompatibleSurveyViewController *)presented;
		if (vc.viewType == POLViewTypeDialog)
			return [POLSurveyDialogAnimateInController animateInWithViewController:vc];
		else if (vc.viewType == POLViewTypeBottom)
			return POLSurveyBottomAnimateInController.new;
	}

	return nil;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
	presentingViewController:(UIViewController *)presenting
	sourceViewController:(UIViewController *)source
{
	POLLogTrace("%s presented=%@, presenting=%@, source=%@", __func__, presented, presenting, source);
	return nil;
//	return [[POLPresentationController alloc] initWithPresentedViewController:presented
//													 presentingViewController:presenting];
}

#pragma mark - View Controller Transistion Coordinator

- (BOOL)animateAlongsideTransition:(void (^)(id<UIViewControllerTransitionCoordinatorContext> context))animation
	completion:(void (^)(id<UIViewControllerTransitionCoordinatorContext> context))completion
{
	POLLogTrace("%s", __func__);
	return NO;
}

#pragma mark - Survey View Controller Delegate

- (void)surveyViewControllerDidOpen:(POLSurveyViewController *)surveyViewController
{
	[_networkSession startSurvey:surveyViewController.survey];
}

- (void)surveyViewControllerDidDismiss:(POLSurveyViewController *)surveyViewController
{
	_surveyVisible = NO;
	[_networkSession completeSurvey:surveyViewController.survey];

//	if (_currentSurvey)
//		_currentSurvey.embedViewRequested = NO;

	_surveyViewController = nil;
}

@end
