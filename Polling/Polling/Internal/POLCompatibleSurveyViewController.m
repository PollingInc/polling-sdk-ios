/*
 *  POLCompatibleSurveyViewController.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLCompatibleSurveyViewController.h"
#import "POLSurveyViewController.h"
#import "POLPolling+Private.h"
#import "POLLog.h"
#import "POLError.h"
#import "POLSurvey.h"
#import "POLSurvey+Private.h"

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

static const CGFloat POLSurveyViewCloseableAreaHeight = 44;

#pragma mark - View

@implementation POLBackgroundView
@end

@implementation POLContainerView
@end

#pragma mark - View Controller

@interface POLCompatibleSurveyViewController ()
	<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler,
	 UIGestureRecognizerDelegate>

- (void)tap:(id)sender;

- (void)beginObservingContentSizeChanges;
- (void)stopObservingContentSizeChanges;
- (void)resizeToFitContentHeight:(CGFloat)contentHeight;

@end

@implementation POLCompatibleSurveyViewController {
	POLSurveyViewSizeClass _currentSizeClass;
	CGFloat _initialContainerHeight;
	BOOL _observingContentSizeChanges;
	BOOL _pauseObserver;
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

#if 0
	POLLogInfo("self.backgroundView.constraints=%@", self.backgroundView.constraints);

	if (_viewType == POLViewTypeDialog) {
		POLLogInfo("dialogTopConstraint=%@", self.dialogTopConstraint);
		POLLogInfo("dialogTopConstraint2=%@", self.dialogTopConstraint2);
		POLLogInfo("dialogBottomConstraint=%@", self.dialogBottomConstraint);
		POLLogInfo("dialogBottomConstraint2=%@", self.dialogBottomConstraint2);
		POLLogInfo("dialogLeadingConstraint=%@", self.dialogLeadingConstraint);
		POLLogInfo("dialogTrailingConstraint=%@", self.dialogTrailingConstraint);
	} else if (_viewType == POLViewTypeBottom) {
		POLLogInfo("bottomHalfHeightConstraint=%@", self.bottomHalfHeightConstraint);
		POLLogInfo("bottomBottomConstraint=%@", self.bottomBottomConstraint);
		POLLogInfo("bottomLeadingConstraint=%@", self.bottomLeadingConstraint);
		POLLogInfo("bottomTrailingConstraint=%@", self.bottomTrailingConstraint);
	}
#endif

	_currentSizeClass = POLSurveyViewSizeClassDefault;
	_initialContainerHeight = self.containerView.frame.size.height;
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
	shouldReceiveTouch:(UITouch *)touch
{
	CGPoint loc = [touch locationInView:self.webView];
	if ([self.webView pointInside:loc withEvent:nil]) {
		POLLogInfo("Touch in web view");
		return NO;
	}

	POLLogInfo("Touch outside of web view");
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

	if (_pauseObserver)
		return;

	if (context == POLWebViewContentSizeChangedContext) {
		// leaving these for serious debugging
		//POLLogTrace("%s object=%@, keyPath=%@, change=%@", __func__, object, keyPath, change);
		POLLogTrace("contentSizeChange[%d] keyPath=%@, change=%@", contentSizeChangeCount++, keyPath, change);

		// assume change kind == NSKeyValueChangeSetting

		CGSize old = [change pol_sizeValueForKey:NSKeyValueChangeOldKey undefinedValue:CGSizeZero];
		CGSize new = [change pol_sizeValueForKey:NSKeyValueChangeNewKey undefinedValue:CGSizeZero];

		// ignore vacuous changes
		if (old.height == new.height)
			return;

		//POLLogTrace("contentSizeChange[%d] keyPath=%@, change=%@", contentSizeChangeCount++, keyPath, change);

		if (CGSizeEqualToSize(new, CGSizeZero))
			return;

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
		if (CGSizeEqualToSize(old, CGSizeZero))
			return;

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

- (void)resizeToFitContentHeight:(CGFloat)contentHeight
{
	POLLogTrace("%s contentHeight=%G", __func__, contentHeight);
	POLSurveyViewSizeClass newSizeClass = POLSurveyViewSizeClassDefault;

	UIEdgeInsets safeAreaInsets = self.backgroundView.safeAreaInsets;
	POLLogTrace("safeAreaInsets=%@", NSStringFromUIEdgeInsets(safeAreaInsets));

	CGFloat fullHeight = self.backgroundView.frame.size.height;
	CGFloat maxSafeHeight = fullHeight - safeAreaInsets.top - POLSurveyViewCloseableAreaHeight;
	POLLogTrace("Maximum safe height for containerView is %G", maxSafeHeight);
	CGFloat minHeight = (fullHeight - safeAreaInsets.top - safeAreaInsets.bottom) / 2;
	POLLogTrace("Minimum height for containerView is %G", minHeight);

	// best size class for content height
	if (contentHeight <= minHeight)
		newSizeClass = POLSurveyViewSizeClassDefault;
	else if (contentHeight > _initialContainerHeight && contentHeight < maxSafeHeight)
		newSizeClass = POLSurveyViewSizeClassMatchContent;
	else
		newSizeClass = POLSurveyViewSizeClassMaximum;

	// skip vacuous changes
	if (_currentSizeClass == newSizeClass && newSizeClass == POLSurveyViewSizeClassDefault)
		return;
	if (_currentSizeClass == newSizeClass && newSizeClass == POLSurveyViewSizeClassMaximum)
		return;

	/* Don't skip cur == new && new == MatchContent because the size
	 * may have actually changed. */

	// update constraints
	if (_viewType == POLViewTypeDialog) {
		// skip
		return;
	} else if (_viewType == POLViewTypeBottom) {
		if (newSizeClass == POLSurveyViewSizeClassDefault ) {
			self.bottomHalfHeightConstraint.active = YES;
			self.bottomTopOffsetConstraint.active = NO;
		} else {
			self.bottomHalfHeightConstraint.active = NO;
			self.bottomTopOffsetConstraint.active = YES;
			if (newSizeClass == POLSurveyViewSizeClassMatchContent)
				self.bottomTopOffsetConstraint.constant = maxSafeHeight - contentHeight;
			else if (newSizeClass == POLSurveyViewSizeClassMaximum)
				self.bottomTopOffsetConstraint.constant = POLSurveyViewCloseableAreaHeight;
		}
	}

	// pause observing until animations finish
	_pauseObserver = YES;

	// perform animate view resize
	POLLogTrace("BEGIN CONSTRAINT ANIMATION");
	[UIView animateWithDuration:.5 animations:^{
		[self.backgroundView layoutIfNeeded];
	} completion:^(BOOL finished) {
		POLLogTrace("END CONSTRAINT ANIMATION finished=%{BOOL}d", finished);
		self->_pauseObserver = NO;
	}];
}

#pragma mark - Web View Script Message Handler

- (void)userContentController:(WKUserContentController *)userContentController
	didReceiveScriptMessage:(WKScriptMessage *)message;
{
	// @"ContentSizeDidChange"
	// CGFloat newHeight = 0;
	// [self resizeToFitContentHeight:newHeight];
}

@end
