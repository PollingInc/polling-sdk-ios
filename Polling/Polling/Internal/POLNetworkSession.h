/*
 *  POLNetworkSession.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class POLSurvey, POLTriggeredSurvey;
@protocol POLNetworkSessionDelegate;

FOUNDATION_EXTERN NSString * const POLNetworkSessionAvailableSurveyAPIEndpoint;
FOUNDATION_EXTERN NSString * const POLNetworkSessionSurveyAPIEndpoint;
FOUNDATION_EXTERN NSString * const POLNetworkSessionEventAPIEndpoint;

@interface POLNetworkSession : NSObject

@property (nonatomic, weak, nullable) id <POLNetworkSessionDelegate> delegate;

#pragma mark - Networking

+ (NSURL *)URLForEndpoint:(NSString *)endpoint
		   withCustomerID:(NSString * __nullable)customerID APIKey:(NSString * __nullable)apiKey;

#pragma mark - Surveys

- (void)fetchAvailableSurveys;

- (void)fetchSurvey:(POLSurvey *)survey;
- (void)fetchSurveyWithUUID:(NSString *)uuid;

- (void)preCompleteSurvey:(POLSurvey *)survey;
- (void)completeSurvey:(POLSurvey *)survey;

- (void)postEvent:(NSString *)eventName withValue:(NSString *)eventValue;

@end

@protocol POLNetworkSessionDelegate <NSObject>

- (void)networkSessionDidFetchAvailableSurveys:(NSArray<POLSurvey *> *)surveys;
- (void)networkSessionDidFetchSurvey:(POLSurvey *)survey;
- (void)networkSessionDidCompleteSurvey:(POLSurvey *)survey;
- (void)networkSessionDidUpdateTriggeredSurveys:(NSArray<POLTriggeredSurvey *> *)triggeredSurvey;

@end

NS_ASSUME_NONNULL_END
