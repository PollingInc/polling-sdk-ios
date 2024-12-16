/*
 *  POLPolling.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class POLSurvey, POLReward;
@protocol POLPollingDelegate;

@interface POLPolling : NSObject

- init NS_UNAVAILABLE;

- initWithCustomerID:(NSString *)customerID APIKey:(NSString *)apiKey;

@property (nonatomic, weak, nullable) id <POLPollingDelegate> delegate;

- (void)presentSurvey:(POLSurvey *)survey;

@end


@protocol POLPollingDelegate <NSObject>

@optional

- (void)surveyDidOpen:(POLSurvey *)survey;
- (void)surveyDidDismiss:(POLSurvey *)survey;
- (void)surveyDidPostpone:(POLSurvey *)survey;
- (void)surveyDidComplete:(POLSurvey *)survey;
- (void)surveyDidSucceed:(POLSurvey *)survey;
- (void)surveyDidFail:(POLSurvey *)survey;

- (void)survey:(POLSurvey *)survey didReward:(POLReward *)reward;

- (void)pollingSurveyDidBecomeAvailable;

@end

NS_ASSUME_NONNULL_END
