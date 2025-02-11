/*
 *  POLPolling+Private.h
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */


#import "POLPolling.h"
#import "POLError.h"
#import "POLLog.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Version Info

extern const short POLVersionMajorNumber;
extern const short POLVersionMinorNumber;
extern const short POLVersionPatchNumber;

extern const unsigned char POLVersionBranchString[];
extern const unsigned char POLVersionCommitString[];
extern const unsigned char POLVersionConfigString[];

extern const unsigned char POLVersionRepoStateString[];

extern const unsigned char POLVersionString[];
extern const unsigned char POLVersionLongString[];
extern const unsigned char POLVersionAllString[];

#pragma mark - SDK Initialization Checks

void POLSetSDKInitialized(BOOL initialized);
BOOL POLIsSDKInitialized(void);

void POLShutdownSDK(void);
BOOL POLIsSDKShutdown(void);

BOOL POLIsSDKDisabled(void);

#define POLGuardPublicAPI() ({											\
	if (!POLPolling.polling.delegate)									\
		POLLogWarn("Polling delegate not set");							\
	if (POLIsSDKDisabled()) {											\
		if (POLIsSDKShutdown()) {										\
			POLLogError("Attempt to use shutdown SDK; ignoring request"); \
			return;														\
		}																\
		POLLogError("Attempt to use uninitialized SDK; ignoring request"); \
		if (POLIsObviouslyInvalidString(POLPolling.polling.customerID))	\
			POLLogError("You must set 'customerID'");					\
		if (POLIsObviouslyInvalidString(POLPolling.polling.apiKey))		\
			POLLogError("You must set 'apiKey'");						\
		return;															\
	}																	\
})

#pragma mark - POLPolling Singleton Internals

NSString * const POLViewTypeDescription(POLViewType viewType);

@class POLTriggeredSurvey;

@interface POLPolling ()

@property (readonly,getter=isSurveyVisible) BOOL surveyVisible;

@property NSMutableArray<POLSurvey *> *openedSurveys;

- (void)getSurveyDetailsForTriggeredSurvey:(POLTriggeredSurvey *)triggeredSurvey;
- (void)postponeSurvey:(POLSurvey *)survey;

- (void)presentSurveyInternal:(POLSurvey *)survey;

@end

NS_ASSUME_NONNULL_END
