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

typedef NS_ENUM(NSInteger, POLViewType) {
	POLViewTypeNone = 0,
	POLViewTypeDialog = 1,
	POLViewTypeBottom = 2,
} NS_SWIFT_NAME(Polling.ViewType);


NS_SWIFT_NAME(Polling)
@interface POLPolling : NSObject

- init NS_UNAVAILABLE;
+ new NS_UNAVAILABLE;

+ (instancetype)polling;

@property (nonatomic, weak, nullable) id <POLPollingDelegate> delegate;

@property NSString *customerID;
@property NSString *apiKey;
@property POLViewType viewType;
@property BOOL disableCheckingForAvailableSurveys;

/* public API methods */
- (void)logEvent:(NSString *)eventName value:(NSString *)eventValue;
- (void)logPurchase:(int)integerCents;
- (void)logSession;
- (void)showEmbedView;
- (void)showSurvey:(NSString *)surveyUuid;

/* The accessor methods: setCustomerID, setApiKey, setViewType,
 *   setDisableCheckingForAvailableSurveys are implicitly available in
 *   ObjC, but Swift code must use the property form?
 *
 * TODO: explicitly declare accessors?
 */

@end

NS_SWIFT_NAME(PollingDelegate)
@protocol POLPollingDelegate <NSObject>

@optional

/* public callbacks */
- (void)pollingOnSuccess:(NSString *)response;
- (void)pollingOnFailure:(NSString *)error;
- (void)pollingOnReward:(POLReward *)reward;
- (void)pollingOnSurveyAvailable;

@end

NS_ASSUME_NONNULL_END
