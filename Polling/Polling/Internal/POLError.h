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
	POLGeneralError = 1,

	POLEncodingFailedError = 21,

	POLSDKError = 100,
	POLSDKNotConfiguredError = 101,

	POLNetworkSessionError = 200,
	POLNetworkSessionBadEndpointURLError = 201,
	POLNetworkSessionCouldNotBindURLParametersError = 202,

	// NOTE: resume is the same as begin/start
	POLNetworkSessionTaskCanNotResumeError = 211,
	POLNetworkSessionTaskTypeUnknownError = 212,
	POLNetworkSessionDataTaskDoesNotExistsError = 213,
	POLNetworkSessionDataTaskInvalidatedError = 214,
	POLNetworkSessionDataTaskFailedError = 215,

	POLNetworkSessionUnexpectedHTTPStatusCodeError = 221,
	POLNetworkSessionUnexpectedContentTypeError = 222,

	POLNetworkSessionResponseBodyError = 230,
	POLNetworkSessionMalformedResponseError = 231,
	POLNetworkSessionEmptyTopLevelDictionaryError = 232,
	POLNetworkSessionExpectedDictionaryError = 233,
	POLNetworkSessionExpectedArrayError = 234,
	POLNetworkSessionNoValueForRequiredKeyError = 235,

	POLSurveyError = 300,
	POLRewardError = 400,
	POLTriggeredSurveyError = 500,

	POLStorageError = 600,
	POLStorageApplicationSupportDirectoryUnavailableError = 601,
	POLStorageWriteFailedError = 602,

	POLViewControllerError = 700,
	POLViewControllerMemoryWarningError = 721,

	POLWebViewError = 800,
	POLWebViewNavigationFailureError = 821,
	POLWebViewProcessTerminatedError = 831,
};

@interface POLError : NSError
+ (instancetype)errorWithCode:(NSInteger)code userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict;
+ (instancetype)errorWithCode:(NSInteger)code underlyingError:(NSError *)underlyingError
					 userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict;
- (NSString *)subsystem;
- (NSString *)category;
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
