/*
 *  POLCompatibleSurveyViewController.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <UIKit/UIKit.h>
#import "POLSurveyViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface POLCompatibleSurveyViewController : POLSurveyViewController

@property POLViewType viewType;

- initWithSurvey:(POLSurvey *)survey viewType:(POLViewType)viewType;

@end

NS_ASSUME_NONNULL_END
