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

#pragma mark - View

@implementation POLBackgroundView
@end

@implementation POLContainerView
@end

#pragma mark - View Controller

@interface POLCompatibleSurveyViewController () <WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate>

- (void)tap:(id)sender;
@end

@implementation POLCompatibleSurveyViewController {

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

	[self.delegate surveyViewControllerDidOpen:(POLSurveyViewController *)self];
	[self loadWebRequest];
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
		[self.delegate surveyViewControllerDidDismiss:(POLSurveyViewController *)self];
	}];
}

@end
