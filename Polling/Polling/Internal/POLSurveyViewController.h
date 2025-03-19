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
@class POLBackgroundView, POLContainerView;
@class WKWebView, WKWebViewConfiguration;

@interface POLSurveyViewController : UIViewController

@property POLSurvey *survey;
@property (nonatomic, weak, nullable) id<POLSurveyViewControllerDelegate> delegate;

@property WKWebView *webView;

- (WKWebViewConfiguration *)webViewConfiguration;
- (void)loadWebRequest;

@property POLViewType viewType;

@property (strong, nonatomic) IBOutlet POLBackgroundView *backgroundView;
@property (weak, nonatomic) IBOutlet POLContainerView *containerView;

- init NS_UNAVAILABLE;
- initWithSurvey:(POLSurvey *)survey viewType:(POLViewType)viewType;

#pragma mark - Dialog Layout Constraints

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dialogTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dialogTopConstraint2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dialogBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dialogBottomConstraint2;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dialogLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dialogTrailingConstraint;

#pragma mark - Bottom Layout Constraints

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHalfHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTopOffsetConstraint;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTrailingConstraint;

@end

@interface POLBackgroundView : UIView
@end

@interface POLContainerView : UIView
@end


NS_ASSUME_NONNULL_END
