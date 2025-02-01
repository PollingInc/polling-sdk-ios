/*
 *  POLSurveyViewControllerDelegate.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class POLSurveyViewController, POLError;

@protocol POLSurveyViewControllerDelegate

- (void)surveyViewControllerDidOpen:(POLSurveyViewController *)surveyViewController;
- (void)surveyViewControllerDidDismiss:(POLSurveyViewController *)surveyViewController;
- (void)surveyViewControllerDidDismiss:(POLSurveyViewController *)surveyViewController withError:(POLError *)error;

@optional

@end

NS_ASSUME_NONNULL_END
