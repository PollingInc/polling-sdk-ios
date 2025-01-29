/*
 *  POLModernSurveyViewController.m
 *  Polling
 *
 *  Copyright © 2025 Polling.com. All rights reserved.
 */

#import "POLModernSurveyViewController.h"
#import "POLPolling+Private.h"
#import "POLLog.h"
#import "POLError.h"
#import "POLSurvey.h"
#import "POLSurvey+Private.h"

#import <WebKit/WebKit.h>

@interface POLModernSurveyViewController () <WKUIDelegate, WKNavigationDelegate>
@end

@implementation POLModernSurveyViewController {

}

- initWithSurvey:(POLSurvey *)survey
{
	POLLogTrace("%s survey=%@", __func__, survey);

	if (!(self = super.init))
		return nil;

	self.survey = survey;

	return self;
}

- (void)loadView
{
	POLLogTrace("%s", __func__);

	self.webView = [[WKWebView alloc] initWithFrame:CGRectZero
								  configuration:self.webViewConfiguration];
	self.webView.UIDelegate = self;
	self.webView.navigationDelegate = self;

	self.view = self.webView;
}

- (void)viewDidLoad {
	POLLogTrace("%s", __func__);
    [super viewDidLoad];
	// ...
	[self loadWebRequest];
}


@end
