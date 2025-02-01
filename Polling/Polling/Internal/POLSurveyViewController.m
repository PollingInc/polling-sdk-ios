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

//#import "POLUserScripts.h"
FOUNDATION_EXTERN NSString * const POLUserScriptPreventTextInputZoomSource;

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

- (WKUserScript *)userScriptPreventTextInputZoom
{
	return [[WKUserScript alloc] initWithSource:POLUserScriptPreventTextInputZoomSource
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

	WKPreferences *preferences = WKPreferences.new;
	preferences.minimumFontSize = 16; // does not seem to work
	_config.preferences = preferences;

	return _config;
}

- (void)loadWebRequest
{
	POLLogInfo("Loading URL=%@ for survey=%@ in webView=%@", _survey.URL, _survey, _webView);

	NSURLRequest *req = [NSURLRequest requestWithURL:_survey.URL];
	[_webView loadRequest:req];
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning
{
	POLLogTrace("%s", __func__);
	POLShutdownSDK();
	[self.webView stopLoading];
	[self.webView removeFromSuperview];
	_webView = nil;
	[self dismissViewControllerAnimated:NO completion:^{
		POLError *error = POLErrorWithCode(POLSurveyViewMemoryWarningError);
		[self.delegate surveyViewControllerDidDismiss:(POLSurveyViewController *)self withError:error];
	}];
}

#pragma mark - Web View UI Delegate

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
	POLShutdownSDK();
	[self.webView stopLoading];
	[self.webView removeFromSuperview];
	_webView = nil;
	[self dismissViewControllerAnimated:NO completion:^{
		POLError *error = POLErrorWithCode(POLWebViewNavigationFailureError);
		[self.delegate surveyViewControllerDidDismiss:(POLSurveyViewController *)self withError:error];
	}];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
	POLLogTrace("%s webView=%@", __func__, webView);
	POLShutdownSDK();
	[self.webView stopLoading];
	[self.webView removeFromSuperview];
	_webView = nil;
	[self dismissViewControllerAnimated:NO completion:^{
		POLError *error = POLErrorWithCode(POLWebViewProcessTerminatedError);
		[self.delegate surveyViewControllerDidDismiss:(POLSurveyViewController *)self withError:error];
	}];
}

@end
