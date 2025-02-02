/*
 *  POLNetworkSession.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class POLSurvey, POLTriggeredSurvey, POLError;
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

- (void)startSurvey:(POLSurvey *)survey;
- (void)completeSurvey:(POLSurvey *)survey;

#pragma mark - Events

- (void)postEvent:(NSString *)eventName withValue:(NSString *)eventValue;

#pragma mark - Control

- (void)invalidateAndCancel;

@end

@protocol POLNetworkSessionDelegate <NSObject>

- (void)networkSessionDidFetchAvailableSurveys:(NSArray<POLSurvey *> *)surveys;
- (void)networkSessionDidFetchSurvey:(POLSurvey *)survey;
- (void)networkSessionDidCompleteSurvey:(POLSurvey *)survey;
- (void)networkSessionDidUpdateTriggeredSurveys:(NSArray<POLTriggeredSurvey *> *)triggeredSurvey;

- (void)networkSessionDidFailWithError:(POLError *)error;

@end

NS_ASSUME_NONNULL_END
