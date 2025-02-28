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
