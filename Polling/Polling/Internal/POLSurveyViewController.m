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

	if (@available(macOS 10.15, iOS 13 *)) {
		[_config.userContentController addUserScript:self.userScriptResizeObserver];
	}

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

#if 0
- (void)webView:(WKWebView *)webView
	decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
	decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
	POLLogTrace("%s webView=%@, navigationAction=%@", __func__, webView, navigationAction);
	decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView
	didStartProvisionalNavigation:(WKNavigation *)navigation
{
	POLLogTrace("%s webView=%@, navigation=%@", __func__, webView, navigation);
	POLLogTrace("    webView.scrollView=%@", webView.scrollView);
	POLLogTrace("    webView.scrollView.contentSize=%@", NSStringFromCGSize(webView.scrollView.contentSize));
}

- (void)webView:(WKWebView *)webView
	didCommitNavigation:(WKNavigation *)navigation
{
	POLLogTrace("%s webView=%@, navigation=%@", __func__, webView, navigation);
	POLLogTrace("    webView.scrollView=%@", webView.scrollView);
	POLLogTrace("    webView.scrollView.contentSize=%@", NSStringFromCGSize(webView.scrollView.contentSize));
}

- (void)webView:(WKWebView *)webView
	didFinishNavigation:(WKNavigation *)navigation
{
	POLLogTrace("%s webView=%@, navigation=%@", __func__, webView, navigation);
	POLLogTrace("    webView.scrollView=%@", webView.scrollView);
	POLLogTrace("    webView.scrollView.contentSize=%@", NSStringFromCGSize(webView.scrollView.contentSize));
}
#endif

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
