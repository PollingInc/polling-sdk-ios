/*
 *  POLSurveyViewController.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLSurveyViewController.h"
#import "POLSurvey.h"

#import <WebKit/WebKit.h>

@interface POLSurveyViewController () <WKUIDelegate>

@end

@implementation POLSurveyViewController {
	POLSurvey *_survey;
	WKWebView *_webView;
	WKWebViewConfiguration *_config;
}

- initWithSurvey:(POLSurvey *)survey
{
	if (!(self = super.init))
		return nil;
	_survey = survey;
	return self;
}

- (void)loadView
{
	_config = WKWebViewConfiguration.new;
	_webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:_config];
	_webView.UIDelegate = self;
	self.view = _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	NSURL *url = _survey.URL;
	//NSURL *url = [NSURL URLWithString:@"https://polling.com"];
	//NSURL *url = [NSURL URLWithString:@"https://apple.com"]

	NSLog(@"loading survey in webview %@", url);
	NSURLRequest *req = [NSURLRequest requestWithURL:url];
	[_webView loadRequest:req];
}

@end
