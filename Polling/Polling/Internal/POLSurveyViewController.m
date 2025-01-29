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

#import <WebKit/WebKit.h>

@interface POLSurveyViewController () <WKUIDelegate, WKNavigationDelegate>

@end

@implementation POLSurveyViewController {
	WKWebViewConfiguration *_config;
}

- (void)viewDidLoad {
	POLLogTrace("%s", __func__);
	[super viewDidLoad];
}

- (WKWebViewConfiguration *)webViewConfiguration
{
	if (_config)
		return _config;

	_config = WKWebViewConfiguration.new;
	// TODO: add SDK specific configuraton

	return _config;
}

- (void)loadWebRequest
{
	POLLogInfo("Loading URL=%@ for survey=%@ in webView=%@", _survey.URL, _survey, _webView);

	NSURLRequest *req = [NSURLRequest requestWithURL:_survey.URL];
	[_webView loadRequest:req];
}

#pragma mark - Momory Warning

- (void)didReceiveMemoryWarning
{
	POLLogTrace("%s", __func__);
}

#pragma mark - Web View UI Delegate

- (void)webViewDidClose:(WKWebView *)webView
{
	POLLogTrace("%s webView=%@", __func__, webView);
}

#pragma mark - Web View Navigation Delegate

- (void)webView:(WKWebView *)webView
	didFailNavigation:(WKNavigation *)navigation
	withError:(NSError *)error
{
	POLLogTrace("%s webView=%@, navigation=%@, error=%@", __func__, webView, navigation, error);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
	POLLogTrace("%s webView=%@", __func__, webView);
}

@end
