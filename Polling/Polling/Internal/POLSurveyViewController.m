/*
 *  POLSurveyViewController.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLSurveyViewController.h"
#import "POLPolling+Private.h"
#import "POLLog.h"
#import "POLError.h"
#import "POLSurvey.h"
#import "POLSurvey+Private.h"
#import "POLUserScript.h"

#import <WebKit/WebKit.h>

static const void *POLWebViewContentSizeChangedContext = &POLWebViewContentSizeChangedContext;

/** Survey view size class */
typedef NS_ENUM(NSUInteger, POLSurveyViewSizeClass) {
	/** Height is 50% of safe area for bottom view or some default for dialog */
	POLSurveyViewSizeClassDefault = 0,

	/** Height is equal to content size */
	POLSurveyViewSizeClassMatchContent = 1,

	/** Height is set to the maximum safe area - closeable area */
	POLSurveyViewSizeClassMaximum = 2,
};

static NSString * const POLSurveyViewSizeClassDefaultDescription = @"Default";
static NSString * const POLSurveyViewSizeClassMatchContentDescription = @"MatchContent";
static NSString * const POLSurveyViewSizeClassMaximumDescription = @"Maximum";

static NSString * const POLSurveyViewSizeClassDescriptions[] = {
	[POLSurveyViewSizeClassDefault] = POLSurveyViewSizeClassDefaultDescription,
	[POLSurveyViewSizeClassMatchContent] = POLSurveyViewSizeClassMatchContentDescription,
	[POLSurveyViewSizeClassMaximum] = POLSurveyViewSizeClassMaximumDescription,
};

static NSString * const POLSurveyViewSizeClassDescription(POLSurveyViewSizeClass sizeClass)
{
	if (sizeClass > POL_ARRAY_SIZE(POLSurveyViewSizeClassDescriptions) - 1)
		return @"Unknown";
	return POLSurveyViewSizeClassDescriptions[sizeClass];
}

static const CGFloat POLSurveyViewCloseableAreaHeight = 44;
static const NSTimeInterval POLSurveyViewLayoutChangeAnimationDuration = .5;

#pragma mark - View

@implementation POLBackgroundView
@end

@implementation POLContainerView
@end

#pragma mark - View Controller

@interface POLSurveyViewController () <WKUIDelegate, WKNavigationDelegate,
	WKScriptMessageHandler, UIGestureRecognizerDelegate>

- (void)tap:(id)sender;

- (void)beginObservingContentSizeChanges;
- (void)stopObservingContentSizeChanges;
- (void)resizeToFitContentHeight:(CGFloat)contentHeight;
- (void)resizeToFitContentHeight:(CGFloat)newContentHeight force:(BOOL)force;

@end

@implementation POLSurveyViewController {
	WKWebViewConfiguration *_config;
	POLSurveyViewSizeClass _currentSizeClass;
	BOOL _observingContentSizeChanges;
	NSTimeInterval _timeSinceLastContentSizeChange;
	NSDate *_lastContentSizeChange;
}

- initWithSurvey:(POLSurvey *)survey viewType:(POLViewType)viewType
{
	POLLogTrace("%s survey=%@, viewType=%@", __func__, survey, POLViewTypeDescription(viewType));

	NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.polling.Polling"];
	NSString *nibName = @"POLSurveyDialogViewController";
	if (viewType == POLViewTypeBottom)
		nibName = @"POLSurveyBottomViewController";

	if (!(self = [super initWithNibName:nibName bundle:bundle]))
		return nil;

	_viewType = viewType;
	self.survey = survey;

	return self;
}

- (void)viewDidLoad {
	POLLogTrace("%s", __func__);
	[super viewDidLoad];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
	tap.delegate = self;
	[self.view addGestureRecognizer:tap];

	_backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];

	self.webView = [[WKWebView alloc] initWithFrame:_containerView.bounds
								  configuration:self.webViewConfiguration];
	self.webView.UIDelegate = self;
	self.webView.navigationDelegate = self;

#if DEBUG
	if (@available(macOS 13.3, iOS 16.4, tvOS 16.4, *))
		self.webView.inspectable = YES;
#endif

	self.webView.translatesAutoresizingMaskIntoConstraints = NO;
	[_containerView addSubview:self.webView];

	[NSLayoutConstraint
		constraintWithItem:self.webView
		attribute:NSLayoutAttributeLeading
		relatedBy:NSLayoutRelationEqual
		toItem:self.webView.superview
		attribute:NSLayoutAttributeLeading
		multiplier:1.0
		constant:0
	].active = YES;
	[NSLayoutConstraint
		constraintWithItem:self.webView.superview
		attribute:NSLayoutAttributeTrailing
		relatedBy:NSLayoutRelationEqual
		toItem:self.webView
		attribute:NSLayoutAttributeTrailing
		multiplier:1.0
		constant:0
	].active = YES;
	[NSLayoutConstraint
		constraintWithItem:self.webView
		attribute:NSLayoutAttributeTop
		relatedBy:NSLayoutRelationEqual
		toItem:self.webView.superview
		attribute:NSLayoutAttributeTop
		multiplier:1.0
		constant:0
	].active = YES;
	[NSLayoutConstraint
		constraintWithItem:self.webView.superview
		attribute:NSLayoutAttributeBottom
		relatedBy:NSLayoutRelationEqual
		toItem:self.webView
		attribute:NSLayoutAttributeBottom
		multiplier:1.0
		constant:0
	].active = YES;

	_timeSinceLastContentSizeChange = DBL_MAX;
	_lastContentSizeChange = NSDate.date;
	_currentSizeClass = POLSurveyViewSizeClassDefault;
	[self beginObservingContentSizeChanges];

	[self.delegate surveyViewControllerDidOpen:self];
	[self loadWebRequest];
}

- (void)dealloc
{
	[self stopObservingContentSizeChanges];
	[self.webView.configuration.userContentController removeAllUserScripts];
	if (@available(macOS 11, iOS 14, *)) {
		[self.webView.configuration.userContentController removeAllScriptMessageHandlers];
	} else {
		// explicitly list all message handlers by name
		[self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"ContentSizeDidChange"];
	}
}

- (WKUserScript *)userScriptPreventTextInputZoom
{
	return [[WKUserScript alloc] initWithSource:POLUserScriptPreventTextInputZoomSource
								  injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
							   forMainFrameOnly:YES];
}

- (WKUserScript *)userScriptResizeObserver
{
	return [[WKUserScript alloc] initWithSource:POLUserScriptResizeObserverSource
								  injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
							   forMainFrameOnly:YES];
}

- (WKWebViewConfiguration *)webViewConfiguration
{
	if (_config)
		return _config;

	_config = WKWebViewConfiguration.new;
	_config.applicationNameForUserAgent = @"Polling SDK for iOS";

	[_config.userContentController addUserScript:self.userScriptPreventTextInputZoom];

#if 0
	if (@available(macOS 10.15, iOS 13, *)) {
		[_config.userContentController addUserScript:self.userScriptResizeObserver];
	}
#endif

	WKPreferences *preferences = WKPreferences.new;
	preferences.minimumFontSize = 16; // does not seem to work
	_config.preferences = preferences;

	return _config;
}

- (void)loadWebRequest
{
	POLLogInfo("Loading URL=%@ for survey=%@ in webView=%@", _survey.URL, _survey, _webView);

#if DEBUG && defined(POL_SURVEY_URL)
	NSURL *url = [NSURL URLWithString:POL_NSSTR(POL_SURVEY_URL)];
	NSURLRequest *req = [NSURLRequest requestWithURL:url];
#else
	NSURLRequest *req = [NSURLRequest requestWithURL:_survey.URL];
#endif
	[_webView loadRequest:req];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
	shouldReceiveTouch:(UITouch *)touch
{
	CGPoint loc = [touch locationInView:self.webView];
	if ([self.webView pointInside:loc withEvent:nil]) {
		POLLogTrace("Touch in web view");
		return NO;
	}

	POLLogTrace("Touch outside of web view");
	return YES;
}

- (void)tap:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:^{
		[self.delegate surveyViewControllerDidDismiss:self];
	}];
}

#pragma mark - Observer

- (void)beginObservingContentSizeChanges
{
#if 0
	if (@available(macOS 10.15, iOS 13, *)) {
		/* use a user script for content size changes */
		[self.webView.configuration.userContentController
			addScriptMessageHandler:self
			name:@"ContentSizeDidChange"
		];
	} else {
#endif
		if (!_observingContentSizeChanges) {
			_observingContentSizeChanges = YES;
			[self.webView addObserver:self
				forKeyPath:@"scrollView.contentSize"
				options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
				context:(void *)POLWebViewContentSizeChangedContext
			];
		}
#if 0
	}
#endif
}

- (void)stopObservingContentSizeChanges
{
#if 0
	if (@available(macOS 10.15, iOS 13, *)) {}
	else {
#endif
		if (_observingContentSizeChanges) {
			_observingContentSizeChanges = NO;
			[self.webView removeObserver:self forKeyPath:@"scrollView.contentSize"];
		}
#if 0
	}
#endif
}

- (void)observeValueForKeyPath:(NSString *)keyPath
	ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	static int contentSizeChangeCount = 0;

	if (context == POLWebViewContentSizeChangedContext) {
		// leaving these for serious debugging
		//POLLogTrace("%s object=%@, keyPath=%@, change=%@", __func__, object, keyPath, change);
		//POLLogTrace("contentSizeChange[%d] keyPath=%@, change=%@", contentSizeChangeCount++, keyPath, change);

		// assume change kind == NSKeyValueChangeSetting

		CGSize old = [change pol_sizeValueForKey:NSKeyValueChangeOldKey undefinedValue:CGSizeZero];
		CGSize new = [change pol_sizeValueForKey:NSKeyValueChangeNewKey undefinedValue:CGSizeZero];

		// ignore vacuous changes
		if (old.height == new.height) {
			//POLLogTrace("Skip old.height == new.height == %G", old.height);
			return;
		}

		POLLogTrace("contentSizeChange[%d] keyPath=%@, change=%@", contentSizeChangeCount++, keyPath, change);

		if (CGSizeEqualToSize(new, CGSizeZero)) {
			POLLogTrace("Skip new size set to zero");
			return;
		}

		/* Before the webview loads any content the content size is
		 * initialized to some default size XXX × YYYY. This is
		 * not a real content size change and the size is devices
		 * dependant.
		 *
		 * This should be ignored:
		 *
		 *		change={
		 *			kind = 1;
		 *			new = "NSSize: {XXX, YYYY}";
		 *			old = "NSSize: {0, 0}";
		 *		}
		 */
		if (CGSizeEqualToSize(old, CGSizeZero)) {
			POLLogTrace("Skip size change before webiview has content");
			return;
		}

		NSDate *now = NSDate.date;
		_timeSinceLastContentSizeChange = [now timeIntervalSinceDate:_lastContentSizeChange];
		_lastContentSizeChange = now;

		// skip minor changes within short time frame
		if (_timeSinceLastContentSizeChange < POLSurveyViewLayoutChangeAnimationDuration) {
			CGFloat dh = fabs(old.height - new.height);
			POLLogTrace("Change within short time frame and delta=%G", dh);
			if (dh < 8) {
				POLLogTrace("Skip delta: %G < 8", dh);
				return;
			}
		}

		[self resizeToFitContentHeight:new.height];
		return;
	}

	[super observeValueForKeyPath:keyPath
		ofObject:object
		change:change
		context:context
	];
}


#pragma mark - Resize Handling

- (void)resizeToFitContentHeight:(CGFloat)newContentHeight
{
	[self resizeToFitContentHeight:newContentHeight force:NO];
}

- (void)resizeToFitContentHeight:(CGFloat)newContentHeight force:(BOOL)force
{
	CGFloat containerHeight = self.containerView.frame.size.height;
	POLLogTrace("%s containerHeight=%G, newContentHeight=%G, force=%{BOOL}d", __func__, containerHeight, newContentHeight, force);

	POLSurveyViewSizeClass newSizeClass = POLSurveyViewSizeClassDefault;

	UIEdgeInsets safeAreaInsets = self.backgroundView.safeAreaInsets;
	CGFloat fullHeight = self.backgroundView.frame.size.height;

	CGFloat maxSafeHeight = fullHeight - safeAreaInsets.top - safeAreaInsets.bottom;
	CGFloat minHeight = fullHeight - safeAreaInsets.top - safeAreaInsets.bottom;

	const CGFloat topConstantDefault = 120;
	const CGFloat topConstantHeightCompactWidthCompact = 30;
	const CGFloat topConstantHeightCompactWidthRegular = 60;
	const CGFloat topConstantHeightRegularWidthRegular = 200;
	const CGFloat topConstantIdiomMacHeightRegularWidthRegular = 100;

	const CGFloat bottomConstantDefault = 120;
	const CGFloat bottomConstantHeightCompactWidthCompact = 30;
	const CGFloat bottomConstantHeightCompactWidthRegular = 60;
	const CGFloat bottomConstantHeightRegularWidthRegular = 200;
	const CGFloat bottomConstantIdiomMacHeightRegularWidthRegular = 100;

	UIUserInterfaceSizeClass heightClass = self.traitCollection.verticalSizeClass;
	UIUserInterfaceSizeClass widthClass = self.traitCollection.horizontalSizeClass;
	UIUserInterfaceIdiom idiom = self.traitCollection.userInterfaceIdiom;

	UIUserInterfaceIdiom Mac = 5;
	if (@available(iOS 14, tvOS 14, *)) {
		Mac = UIUserInterfaceIdiomMac;
	}

	if (_viewType == POLViewTypeDialog) {
		/* maxSafeHeight = fullHeight - safeAreaInsets.top - safeAreaInsets.bottom - POLSurveyViewCloseableAreaHeight; */
		maxSafeHeight = fullHeight - safeAreaInsets.top - safeAreaInsets.bottom;
		CGFloat margins = topConstantDefault + bottomConstantDefault;
		if (heightClass == UIUserInterfaceSizeClassCompact && widthClass == UIUserInterfaceSizeClassCompact)
			margins = topConstantHeightCompactWidthCompact + bottomConstantHeightCompactWidthCompact;
		else if (heightClass == UIUserInterfaceSizeClassCompact && widthClass == UIUserInterfaceSizeClassRegular)
			margins = topConstantHeightCompactWidthRegular + bottomConstantHeightCompactWidthRegular;
		else if (idiom == Mac && heightClass == UIUserInterfaceSizeClassRegular && widthClass == UIUserInterfaceSizeClassRegular)
			margins = topConstantIdiomMacHeightRegularWidthRegular + bottomConstantIdiomMacHeightRegularWidthRegular;
		else if (heightClass == UIUserInterfaceSizeClassRegular && widthClass == UIUserInterfaceSizeClassRegular)
			margins = topConstantHeightRegularWidthRegular + bottomConstantHeightRegularWidthRegular;
		minHeight = fullHeight - safeAreaInsets.top - safeAreaInsets.bottom - margins;
	} else if (_viewType == POLViewTypeBottom) {
		maxSafeHeight = fullHeight - safeAreaInsets.top - POLSurveyViewCloseableAreaHeight;
		minHeight = (fullHeight - safeAreaInsets.top - safeAreaInsets.bottom) / 2;
	}

	POLLogTrace("safeAreaInsets=%@", NSStringFromUIEdgeInsets(safeAreaInsets));
	POLLogTrace("Maximum safe height for containerView is %G", maxSafeHeight);
	POLLogTrace("Minimum height for containerView is %G", minHeight);

	POLLogTrace("CUR size class = %@", POLSurveyViewSizeClassDescription(_currentSizeClass));

	// best size class for content height
	if (newContentHeight <= minHeight)
		newSizeClass = POLSurveyViewSizeClassDefault;
	else if (newContentHeight < maxSafeHeight)
		newSizeClass = POLSurveyViewSizeClassMatchContent;
	else
		newSizeClass = POLSurveyViewSizeClassMaximum;

	POLLogTrace("NEW size class = %@", POLSurveyViewSizeClassDescription(newSizeClass));

	// skip vacuous changes
	if (!force) {
		if (_currentSizeClass == newSizeClass && newSizeClass == POLSurveyViewSizeClassDefault) {
			POLLogTrace("SKIP vacuous changes");
			return;
		}
		if (_currentSizeClass == newSizeClass && newSizeClass == POLSurveyViewSizeClassMaximum) {
			POLLogTrace("SKIP vacuous changes");
			return;
		}

		/* Don't skip cur == new && new == MatchContent because the
		 * size may have actually changed. */
	}

	// update constraints

	/* Order matters when setting constraints' `active` property. NO
	 * must come first. If "unable to simultaneously satisfy
	 * constraints" message appear in the Console, check activation
	 * order first. */
	if (_viewType == POLViewTypeDialog) {
		if (newSizeClass == POLSurveyViewSizeClassDefault) {
			if (heightClass == UIUserInterfaceSizeClassCompact && widthClass == UIUserInterfaceSizeClassCompact) {
				self.dialogTopConstraint2.constant = topConstantHeightCompactWidthCompact;
				self.dialogBottomConstraint2.constant = bottomConstantHeightCompactWidthCompact;
			} else if (heightClass == UIUserInterfaceSizeClassCompact && widthClass == UIUserInterfaceSizeClassRegular) {
				self.dialogTopConstraint2.constant = topConstantHeightCompactWidthRegular;
				self.dialogBottomConstraint2.constant = bottomConstantHeightCompactWidthRegular;
			} else if (idiom == Mac && heightClass == UIUserInterfaceSizeClassRegular && widthClass == UIUserInterfaceSizeClassRegular) {
				self.dialogTopConstraint2.constant = topConstantIdiomMacHeightRegularWidthRegular;
				self.dialogBottomConstraint2.constant = bottomConstantIdiomMacHeightRegularWidthRegular;
			} else if (heightClass == UIUserInterfaceSizeClassRegular && widthClass == UIUserInterfaceSizeClassRegular) {
				self.dialogTopConstraint2.constant = topConstantHeightRegularWidthRegular;
				self.dialogBottomConstraint2.constant = bottomConstantHeightRegularWidthRegular;
			}
		} else {
			if (newSizeClass == POLSurveyViewSizeClassMatchContent) {
				/* CGFloat h = (maxSafeHeight - (newContentHeight - POLSurveyViewCloseableAreaHeight)) / 2; */
				/* self.dialogTopConstraint2.constant = h + POLSurveyViewCloseableAreaHeight; */
				/* self.dialogBottomConstraint2.constant = h; */
				CGFloat h = (maxSafeHeight - newContentHeight) / 2;
				self.dialogTopConstraint2.constant = h;
				self.dialogBottomConstraint2.constant = h;
			} else if (newSizeClass == POLSurveyViewSizeClassMaximum) {
				/* self.dialogTopConstraint2.constant = POLSurveyViewCloseableAreaHeight; */
				self.dialogTopConstraint2.constant = 16;
				self.dialogBottomConstraint2.constant = 16;
			}
			POLLogTrace("TOP CONSTANT=%G", self.dialogTopConstraint2.constant);
			POLLogTrace("BOTTOM CONSTANT=%G", self.dialogBottomConstraint2.constant);
		}
	} else if (_viewType == POLViewTypeBottom) {
		if (newSizeClass == POLSurveyViewSizeClassDefault) {
			self.bottomTopOffsetConstraint.active = NO;
			self.bottomHalfHeightConstraint.active = YES;
		} else {
			self.bottomHalfHeightConstraint.active = NO;
			self.bottomTopOffsetConstraint.active = YES;
			if (newSizeClass == POLSurveyViewSizeClassMatchContent)
				self.bottomTopOffsetConstraint.constant =
					maxSafeHeight - newContentHeight + safeAreaInsets.bottom;
			else if (newSizeClass == POLSurveyViewSizeClassMaximum)
				self.bottomTopOffsetConstraint.constant = POLSurveyViewCloseableAreaHeight;
			POLLogTrace("CONSTANT=%G", self.bottomTopOffsetConstraint.constant);
		}
	}

	static int resizeID = -1;
	resizeID++;

	// perform animate view resize
	[UIView animateWithDuration:POLSurveyViewLayoutChangeAnimationDuration animations:^{
		int rID = resizeID;
		return ^{
			POLLogTrace("BEGIN[%D] CONSTRAINT ANIMATION", rID);
			[self.backgroundView layoutIfNeeded];
		};
	}() completion:^{
		int rID = resizeID;
		return ^(BOOL finished) {
			POLLogTrace("END[%d] CONSTRAINT ANIMATION finished=%{BOOL}d", rID, finished);
			if (finished)
				self->_currentSizeClass = newSizeClass;
		};
	}()];
}

- (void)forceResize
{
	[self resizeToFitContentHeight:self.webView.scrollView.contentSize.height force:YES];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
			  withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	POLLogTrace("%s newCollection=%@, coordinator=%@", __func__, newCollection, coordinator);
	[self performSelectorOnMainThread:@selector(forceResize) withObject:nil waitUntilDone:NO];
}

#pragma mark - Web View Script Message Handler

- (void)userContentController:(WKUserContentController *)userContentController
	didReceiveScriptMessage:(WKScriptMessage *)message;
{
	// @"ContentSizeDidChange"
	// CGFloat newHeight = 0;
	// [self resizeToFitContentHeight:newHeight];
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning
{
	POLLogTrace("%s", __func__);
#if 0
	POLShutdownSDK();
	[self.webView stopLoading];
	[self.webView removeFromSuperview];
	_webView = nil;
	[self dismissViewControllerAnimated:NO completion:^{
		POLError *error = POLErrorWithCode(POLViewControllerMemoryWarningError);
		[self.delegate surveyViewControllerDidDismiss:self withError:error];
	}];
#else
	POLError *error = POLErrorWithCode(POLViewControllerMemoryWarningError);
	/* Should be POLLogWarn, but Unity does not log
	 * OS_LOG_TYPE_DEFAULT so POLLogLevelWarn should be fixed */
	POLLogInfo("Received memory warning from iOS (%@)", error);
#endif
}

#pragma mark - Web View UI Delegate

#if 0
- (WKWebView *)webView:(WKWebView *)webView
	createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
	forNavigationAction:(WKNavigationAction *)navigationAction
	windowFeatures:(WKWindowFeatures *)windowFeatures
{

}
#endif

- (void)webViewDidClose:(WKWebView *)webView
{
	POLLogTrace("%s webView=%@", __func__, webView);
	// NOTE: this isn't an error, it could be a simple mechanism for self closing surveys
}

#pragma mark - Web View Navigation Delegate

- (void)webView:(WKWebView *)webView
	didFailNavigation:(WKNavigation *)navigation
	withError:(NSError *)error
{
	POLLogTrace("%s webView=%@, navigation=%@, error=%@", __func__, webView, navigation, error);
#if 0
	[self dismissViewControllerAnimated:YES completion:^{
		POLError *error = POLErrorWithCode(POLWebViewNavigationFailureError);
		[self.delegate surveyViewControllerDidDismiss:self withError:error];
	}];
#else
	POLError *pErr = POLErrorWithCode(POLWebViewNavigationFailureError);
	/* Should be POLLogWarn, but Unity does not log
	 * OS_LOG_TYPE_DEFAULT so POLLogLevelWarn should be fixed */
	POLLogInfo("WebView navigation failure (%@)", pErr);
#endif
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
	POLLogTrace("%s webView=%@", __func__, webView);
#if 0
	POLShutdownSDK();
	[self.webView stopLoading];
	[self.webView removeFromSuperview];
	_webView = nil;
	[self dismissViewControllerAnimated:NO completion:^{
		POLError *error = POLErrorWithCode(POLWebViewProcessTerminatedError);
		[self.delegate surveyViewControllerDidDismiss:self withError:error];
	}];
#else
	POLError *error = POLErrorWithCode(POLWebViewProcessTerminatedError);
	/* Should be POLLogWarn, but Unity does not log
	 * OS_LOG_TYPE_DEFAULT so POLLogLevelWarn should be fixed */
	POLLogInfo("WebView process terminated (%@)", error);
#endif
}

@end
