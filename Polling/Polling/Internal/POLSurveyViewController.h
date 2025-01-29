/*
 *  POLSurveyViewController.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <UIKit/UIKit.h>
#import "POLPolling.h"
#import "POLSurveyViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class POLSurvey;
@class WKWebView, WKWebViewConfiguration;

@interface POLSurveyViewController : UIViewController

@property POLSurvey *survey;
@property (nonatomic, weak, nullable) id<POLSurveyViewControllerDelegate> delegate;

@property WKWebView *webView;

- (WKWebViewConfiguration *)webViewConfiguration;
- (void)loadWebRequest;

@end



NS_ASSUME_NONNULL_END
