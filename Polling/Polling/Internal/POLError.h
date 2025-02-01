/*
 *  POLError.h
 *  Polling
 *
 *  Copyright © 2025 Polling.com. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "NSDictionary+Additions.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const POLPollingErrorDomain;

FOUNDATION_EXTERN NSString * const POLErrorFileKey;
FOUNDATION_EXTERN NSString * const POLErrorMethodKey;
FOUNDATION_EXTERN NSString * const POLErrorLineNumberKey;

NS_ERROR_ENUM(POLPollingErrorDomain) {
	POLPollingGenericError = 1,

	POLPollingEncodingFailedError = 21,

	POLPollingSDKError = 100,
	POLPollingSDKNotConfiguredError = 101,

	POLNetworkSessionError = 200,

	POLNetworkSessionBadEndpointURLError = 201,
	POLNetworkSessionCouldNotBindURLParametersError = 202,

	// NOTE: resume is the same as begin/start
	POLNetworkSessionTaskCanNotResumeError = 211,
	POLNetworkSessionTaskTypeUnknownError = 212,

	POLNetworkSessionUnexpectedHTTPStatusCodeError = 204,
	POLNetworkSessionUnexpectedContentTypeError = 204,
	POLNetworkSessionDataTaskDoesNotExistsError = 205,
	POLNetworkSessionDataTaskInvalidatedError = 206,
	POLNetworkSessionDataTaskFailedError = 207,

	POLNetworkSessionResponseError = 250,
	POLNetworkSessionMalformedResponseError = 251,
	POLNetworkSessionEmptyTopLevelDictionaryError = 252,

	POLNetworkSessionExpectedDictionaryError = 261,
	POLNetworkSessionExpectedArrayError = 262,
	POLNetworkSessionNoValueForRequiredKeyError = 263,

	POLSurveyError = 300,
	POLRewardError = 400,
	POLTriggeredSurveyError = 500,

	POLStorageError = 600,
	POLStorageApplicationSupportDirectoryUnavailableError = 601,
	POLStorageWriteFailedError = 602,

	POLSurveyViewError = 700,

	POLSurveyViewMemoryWarningError = 721,

	POLWebViewError = 800,

	POLWebViewNavigationFailureError = 821,

	POLWebViewProcessTerminatedError = 831,
};

@interface POLError : NSError
+ (instancetype)errorWithCode:(NSInteger)code userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict;
+ (instancetype)errorWithCode:(NSInteger)code underlyingError:(NSError *)underlyingError
					 userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict;
@end

#define POLErrorWithCode(code) (				\
	[POLError errorWithCode:code userInfo:@{	\
		POLErrorFileKey: @(__FILE_NAME__),		\
		POLErrorMethodKey: @(__func__),			\
		POLErrorLineNumberKey: @(__LINE__),		\
	}]											\
)

#define POLErrorWithCodeUserInfo(code, userInfo) (	\
	[POLError errorWithCode:code userInfo:[@{		\
		POLErrorFileKey: @(__FILE_NAME__),			\
		POLErrorMethodKey: @(__func__),				\
		POLErrorLineNumberKey: @(__LINE__),			\
	} copyAddingEntriesFromDictionary:userInfo]]	\
)

#define POLErrorWithCodeUnderlyingError(code, uErr) (				\
	[POLError errorWithCode:code underlyingError:uErr userInfo:@{	\
		POLErrorFileKey: @(__FILE_NAME__),							\
		POLErrorMethodKey: @(__func__),								\
		POLErrorLineNumberKey: @(__LINE__),							\
	}]																\
)

#define POLErrorWithCodeUnderlyingErrorUserInfo(code, uErr, userInfo) (	\
	[POLError errorWithCode:code underlyingError:uErr userInfo:[@{		\
		POLErrorFileKey: @(__FILE_NAME__),								\
		POLErrorMethodKey: @(__func__),									\
		POLErrorLineNumberKey: @(__LINE__),								\
	} copyAddingEntriesFromDictionary:userInfo]]						\
)

NS_ASSUME_NONNULL_END
