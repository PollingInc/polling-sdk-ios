/*
 *  POLCompatibleSurveyViewController.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <UIKit/UIKit.h>
#import "POLPolling.h"
#import "POLSurveyViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class POLSurvey;

@interface POLCompatibleSurveyViewController : UIViewController

@property POLViewType viewType;
@property (readonly) POLSurvey *survey;
@property (nonatomic, weak, nullable) id<POLSurveyViewControllerDelegate> delegate;

- init NS_UNAVAILABLE;
- initWithSurvey:(POLSurvey *)survey viewType:(POLViewType)viewType;

@end

NS_ASSUME_NONNULL_END
