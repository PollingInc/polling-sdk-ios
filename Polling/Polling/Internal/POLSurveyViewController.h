/*
 *  POLSurveyViewController.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <UIKit/UIKit.h>
#import "POLSurveyViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class POLSurvey;

@interface POLSurveyViewController : UIViewController

@property (readonly) POLSurvey *survey;
@property (nonatomic, weak, nullable) id<POLSurveyViewControllerDelegate> delegate;

- init NS_UNAVAILABLE;

- initWithSurvey:(POLSurvey *)survey;

@end



NS_ASSUME_NONNULL_END
