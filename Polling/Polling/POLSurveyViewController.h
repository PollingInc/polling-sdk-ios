/*
 *  POLSurveyViewController.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class POLSurvey;
@protocol POLSurveyViewControllerDelegate;

@interface POLSurveyViewController : UIViewController

@property (readonly) POLSurvey *survey;
@property (nonatomic, weak, nullable) id<POLSurveyViewControllerDelegate> delegate;

- initWithSurvey:(POLSurvey *)survey;

@end

@protocol POLSurveyViewControllerDelegate

- (void)surveyViewControllerDidDismiss;

@optional

@end

NS_ASSUME_NONNULL_END
