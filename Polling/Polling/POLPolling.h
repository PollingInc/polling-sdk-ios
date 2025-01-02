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
	POLViewTypeNone,
	POLViewTypeDialog,
	POLViewTypeBottom,
};

@interface POLPolling : NSObject

/* ========================================================================= */

/* NOTE: the SDK initialization is a mess, I have not settled on how I
 * want this to work. The Objective-C way for typical SDK
 * initialization differs a great deal from the other Polling
 * SDKs. */
- init NS_UNAVAILABLE;
- initWithCustomerID:(NSString *)customerID APIKey:(NSString *)apiKey;

+ (instancetype)polling;

- (void)initializeWithCustomerID:(NSString *)customerID APIKey:(NSString *)apiKey;
//- (void)initializeWithPayload:(id)POLSDKPayload;

@property (nonatomic, weak, nullable) id <POLPollingDelegate> delegate;

@property NSString *customerID;
@property NSString *apiKey;

@property BOOL disableCheckingForAvailableSurveys;

/* ========================================================================= */


/* public API methods */
- (void)logEvent:(NSString *)eventName value:(NSString *)eventValue;
- (void)logPurchase:(int)integerCents;
- (void)logSession;
- (void)setViewType:(POLViewType)viewType;
- (void)showEmbedView;
- (void)showSurvey:(NSString *)surveyUuid;
/* - (void)setApiKey(string apiKey) */
/* - (void)setCustomerId(string customerId) */


@end


@protocol POLPollingDelegate <NSObject>

@optional

/* public callbacks */
- (void)pollingOnSuccess:(NSString *)response;
- (void)pollingOnFailure:(NSString *)error;
- (void)pollingOnReward:(POLReward *)reward;
- (void)pollingOnSurveyAvailable;

@end

NS_ASSUME_NONNULL_END
