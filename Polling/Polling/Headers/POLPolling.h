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

/** Survey view style */
typedef NS_ENUM(NSInteger, POLViewType) {
	POLViewTypeNone = 0,

	/** Display survey in view that is centered over existing app
	 * content. */
	POLViewTypeDialog = 1,

	/** Display survey in a sheet that slides up from the bottom over
	 * existing app content. */
	POLViewTypeBottom = 2,

} NS_SWIFT_NAME(Polling.ViewType);


/**
 * The primary SDK object
 *
 * @discussion
 * Configure the SDK and to access features like sending log events
 * and displaying surveys.
 */
NS_SWIFT_NAME(Polling)
@interface POLPolling : NSObject

- init NS_UNAVAILABLE;
+ new NS_UNAVAILABLE;

/**
 * Returns the ``POLPolling`` singleton object.
 *
 * @discussion
 * The singleton object is used to configure the SDK and to access
 * features like sending log events and displaying surveys.
 *
 * @return ``POLPolling`` singleton instance
 */
+ (instancetype)polling;

/**
 * Delegate that handles callbacks from the SDK
 *
 * @discussion
 * This delegate object is responsible for handling callbacks from the
 * SDK. The object you assign to this property must conform to the
 * ``POLPollingDelegate`` protocol.
 */
@property (nonatomic, weak, nullable) id <POLPollingDelegate> delegate;

/**
 * An string that uniquely identifies your customer
 *
 * @discussion
 * Long discussion explaining intricacies of the symbol
 */
@property NSString *customerID;

/**
 * An API Key
 *
 * @discussion
 * API key for your embed integration. To get an API key sign up for a
 * Polling.com account and create an embed using the dashboard.
 */
@property NSString *apiKey;

/**
 * Disable survey availability checks
 *
 * @discussion
 * Set to YES to disable automatic checks for available surveys.
 */
@property BOOL disableCheckingForAvailableSurveys;

/**
 * Survey view style
 *
 * @discussion
 * Set this property before using ``showSurvey:`` or ``showEmbedView``
 * to display the survey or embed using a view style.
 */
@property POLViewType viewType;


/* public API methods */

/**
 * Send and log events
 *
 * @discussion
 * Sends and logs a custom event with a value. Events can be use to
 * link data with customers or to trigger a survey.
 *
 * @param eventName the name of the event
 * @param eventValue the value of the event
 */
- (void)logEvent:(NSString *)eventName value:(NSString *)eventValue;

/**
 * Log a purchase
 *
 * @discussion
 * Sends and logs a purchase. The purchase amount ``intergerCents``
 * should be normalized to a non-fractional value using the smallest
 * recongnized demonination for the currency.
 *
 * e.g. a purchase totalling $10.57 USD should be normalized to 1057.
 *
 * @param integerCents the normalized purchase amount
 */
- (void)logPurchase:(int)integerCents;

/**
 * Log user session
 *
 * @discussion
 * Sends and logs user session.
 */
- (void)logSession;
- (void)showEmbedView;

/**
 * Show a specific survey
 *
 * @discussion
 * Show a specific survey identified by its UUID. Survey UUIDs are
 * available on the Polling.com dashboard.
 *
 * @param surveyUuid the UUID of the survey to show
 */
- (void)showSurvey:(NSString *)surveyUuid;

/* The accessor methods: setCustomerID, setApiKey, setViewType,
 *   setDisableCheckingForAvailableSurveys are implicitly available in
 *   ObjC, but Swift code must use the property form?
 *
 * TODO: explicitly declare accessors?
 */

@end

/**
 * A protocol that defines methods the SDK can call to provide
 * information to your app
 *
 * @discussion
 * Implement these method to receive information from the Polling SDK.
 *
 * After implementing these methods in an object, assign that object
 * to the delegate property of the shared singleton object accessed
 * through ``POLPolling.polling``. The SDK calls the methods of your
 * delegate at appropriate times.
 *
 */
NS_SWIFT_NAME(PollingDelegate)
@protocol POLPollingDelegate <NSObject>

@optional

/* public callbacks */

/**
 * Notifies your app when a survey is completed
 *
 * @discussion
 * Called when a user completes and closes a survey.
 *
 * @param response the survey represented as a JSON string
 */
- (void)pollingOnSuccess:(NSString *)response;

/**
 * Notifies your app when an error occurs
 *
 * @discussion
 * Called when the SDK encounters and error processing your request or
 * when displaying a survey.
 *
 * @param error a string describing the error
 */
- (void)pollingOnFailure:(NSString *)error;

/**
 * Notifies your app when the user receives an award
 *
 * @discussion
 * Called after a user completes a survey with an associated award.
 *
 * @param reward an ``POLReward`` encapsulating the reward
 */
- (void)pollingOnReward:(POLReward *)reward;

/**
 * Notifies your app when surveys are available
 *
 * @discussion
 * Called when surveys are availablel
 */
- (void)pollingOnSurveyAvailable;

@end

NS_ASSUME_NONNULL_END
