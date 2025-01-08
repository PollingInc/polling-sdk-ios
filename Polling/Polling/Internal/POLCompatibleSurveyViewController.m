/*
 *  POLCompatibleSurveyViewController.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLCompatibleSurveyViewController.h"
#import "POLSurveyViewController.h"
#import "POLSurvey.h"
#import "POLSurvey+Private.h"

#import <WebKit/WebKit.h>

#pragma mark - View

@interface POLBackgroundView : UIView
@end
@implementation POLBackgroundView
@end

@interface POLContainerView : UIView
@end
@implementation POLContainerView
@end

#pragma mark - View Controller

@interface POLCompatibleSurveyViewController () <WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet POLBackgroundView *backgroundView;
@property (weak, nonatomic) IBOutlet POLContainerView *containerView;
- (void)tap:(id)sender;
@end

@implementation POLCompatibleSurveyViewController {
	POLSurvey *_survey;
	POLViewType _viewType;
	WKWebView *_webView;
	WKWebViewConfiguration *_config;
}

- initWithSurvey:(POLSurvey *)survey viewType:(POLViewType)viewType
{
	NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.polling.Polling"];
	NSString *nibName = @"POLSurveyDialogViewController";
	if (viewType == POLViewTypeBottom)
		nibName = @"POLSurveyBottomViewController";
	if (!(self = [super initWithNibName:nibName bundle:bundle]))
		return nil;
	_survey = survey;
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
	tap.delegate = self;
	[self.view addGestureRecognizer:tap];

	_backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];

	_config = WKWebViewConfiguration.new;
	_webView = [[WKWebView alloc] initWithFrame:_containerView.bounds configuration:_config];
	_webView.UIDelegate = self;
	_webView.navigationDelegate = self;

	_webView.translatesAutoresizingMaskIntoConstraints = NO;
	[_containerView addSubview:_webView];

	[NSLayoutConstraint
		constraintWithItem:_webView
		attribute:NSLayoutAttributeLeading
		relatedBy:NSLayoutRelationEqual
		toItem:_webView.superview
		attribute:NSLayoutAttributeLeading
		multiplier:1.0
		constant:0
	].active = YES;
	[NSLayoutConstraint
		constraintWithItem:_webView.superview
		attribute:NSLayoutAttributeTrailing
		relatedBy:NSLayoutRelationEqual
		toItem:_webView
		attribute:NSLayoutAttributeTrailing
		multiplier:1.0
		constant:0
	].active = YES;
	[NSLayoutConstraint
		constraintWithItem:_webView
		attribute:NSLayoutAttributeTop
		relatedBy:NSLayoutRelationEqual
		toItem:_webView.superview
		attribute:NSLayoutAttributeTop
		multiplier:1.0
		constant:0
	].active = YES;
	[NSLayoutConstraint
		constraintWithItem:_webView.superview
		attribute:NSLayoutAttributeBottom
		relatedBy:NSLayoutRelationEqual
		toItem:_webView
		attribute:NSLayoutAttributeBottom
		multiplier:1.0
		constant:0
	].active = YES;

	NSURL *url = _survey.embedViewRequested ? _survey.embedViewURL : _survey.URL;
	NSLog(@"loading survey in webview %@", url);

	NSURLRequest *req = [NSURLRequest requestWithURL:url];
	[_webView loadRequest:req];

	[self.delegate surveyViewControllerDidOpen:(POLSurveyViewController *)self];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
	shouldReceiveTouch:(UITouch *)touch
{
	CGPoint loc = [touch locationInView:_webView];
	if ([_webView pointInside:loc withEvent:nil]) {
		NSLog(@"touch in web view");
		return NO;
	}

	NSLog(@"touch outside of web view");
	return YES;
}

- (void)tap:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:^{
		[self.delegate surveyViewControllerDidDismiss:(POLSurveyViewController *)self];
	}];
}

- (void)webView:(WKWebView *)webView
	didFailNavigation:(WKNavigation *)navigation
	withError:(NSError *)error
{
	NSLog(@"Error: %@ %@ %@", webView, navigation, error);
}

@end
