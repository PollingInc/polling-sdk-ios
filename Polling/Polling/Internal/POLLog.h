/*
 *  POLLog.h
 *  Polling
 *
 *  Copyright © 2025 Polling.com. All rights reserved.
 */

#import "POLDefines.h"

#import <Foundation/Foundation.h>
#import <os/log.h>

typedef NS_ENUM(NSUInteger, POLLogLevel) {
	POLLogLevelNone = 0,
	POLLogLevelError,
	POLLogLevelWarn,
	POLLogLevelInfo,
	POLLogLevelTrace,
};

typedef NS_ENUM(NSUInteger, POLLogSubsystem) {
	POLLogSubsystemSDK,
};

typedef NS_ENUM(NSUInteger, POLLogSubsystemCategory) {
	POLLogSDKCategoryDefault,
};

os_log_t POLLogDefault(void);
const char *POLLogLevelLabel(POLLogLevel level);
os_log_type_t POLLogLevelToOSLogType(POLLogLevel level);

#define POLLogWithLevel(log, level, fmt, ...) ({					\
	os_log_with_type(log, POLLogLevelToOSLogType(level),			\
		fmt, ##__VA_ARGS__);										\
})

#if 0
#define POLLogWithLevel(log, level, fmt, ...) ({						\
	os_log_with_type(log, POLLogLevelToOSLogType(level),				\
		POL_LOG_PREFIX_FMT fmt, POLLogPrefix, POLLogLevelName(level),	\
		##__VA_ARGS__);													\
})
#endif

#define POLLogError(fmt, ...) POLLogWithLevel(POLLogDefault(), POLLogLevelError, fmt, ##__VA_ARGS__)
#define POLLogWarn(fmt, ...) POLLogWithLevel(POLLogDefault(), POLLogLevelWarn, fmt, ##__VA_ARGS__)
#define POLLogInfo(fmt, ...) POLLogWithLevel(POLLogDefault(), POLLogLevelInfo, fmt, ##__VA_ARGS__)
#define POLLogTrace(fmt, ...) POLLogWithLevel(POLLogDefault(), POLLogLevelTrace, fmt, ##__VA_ARGS__)

#ifndef DEBUG
#undef POLLogTrace
#define POLLogTrace(fmt, ...)
#endif
