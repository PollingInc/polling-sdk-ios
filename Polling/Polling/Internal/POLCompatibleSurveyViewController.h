/*
 *  POLCompatibleSurveyViewController.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <UIKit/UIKit.h>
#import "POLSurveyViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class POLBackgroundView, POLContainerView;

@interface POLCompatibleSurveyViewController : POLSurveyViewController

@property POLViewType viewType;

@property (strong, nonatomic) IBOutlet POLBackgroundView *backgroundView;
@property (weak, nonatomic) IBOutlet POLContainerView *containerView;

- initWithSurvey:(POLSurvey *)survey viewType:(POLViewType)viewType;

@end

@interface POLBackgroundView : UIView
@end

@interface POLContainerView : UIView
@end

NS_ASSUME_NONNULL_END
