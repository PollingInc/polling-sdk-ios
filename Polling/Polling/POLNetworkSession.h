/*
 *  POLNetworkSession.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class POLSurvey;
@protocol POLNetworkSessionDelegate;

@interface POLNetworkSession : NSObject

@property (nonatomic, weak, nullable) id <POLNetworkSessionDelegate> delegate;

#pragma mark - Networking

+ (NSURL *)URLForEndpoint:(NSString *)endpoint
		   withCustomerID:(NSString *)customerID APIKey:(NSString *)apiKey;

#pragma mark - Surveys

- (void)fetchSurveysWithOptions:(NSDictionary *)options;
- (void)fetchSurveysWithCustomerID:(NSString *)customerID APIKey:(NSString *)apiKey;

@end

@protocol POLNetworkSessionDelegate <NSObject>

@optional
- (void)networkSessionDidFetchSurveys:(NSArray<POLSurvey *> *)surveys;

@end

NS_ASSUME_NONNULL_END
