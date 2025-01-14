/*
 *  POLLog.m
 *  Polling
 *
 *  Copyright © 2025 Polling.com. All rights reserved.
 */

#import "POLLog.h"

const char * const POLLogPrefix = "POL";
const char * const POLLogSubsystemNameSDK = "com.polling.sdk.ios.log";
const char * const POLLogCategoryNameDefault = "default";

const char * const POLLogLevelLabelNone  = "";
const char * const POLLogLevelLabelError = "ERROR";
const char * const POLLogLevelLabelWarn  = "WARN";
const char * const POLLogLevelLabelInfo  = "INFO";
const char * const POLLogLevelLabelTrace = "TRACE";

os_log_t POLLogDefault(void)
{
	static os_log_t log;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		log = os_log_create(POLLogSubsystemNameSDK, POLLogCategoryNameDefault);
	});
	return log;
}

const char *POLLogLevelLabels[] = {
	[POLLogLevelNone] = POLLogLevelLabelNone,
	[POLLogLevelError] = POLLogLevelLabelError,
	[POLLogLevelWarn] = POLLogLevelLabelWarn,
	[POLLogLevelInfo] = POLLogLevelLabelInfo,
	[POLLogLevelTrace] = POLLogLevelLabelTrace,
};

const char *POLLogLevelLabel(POLLogLevel level)
{
	if (level > POL_ARRAY_SIZE(POLLogLevelLabels) - 1)
		return "";
	return POLLogLevelLabels[level];
}

os_log_type_t POLLogOSLogTypes[] = {
	[POLLogLevelNone] = OS_LOG_TYPE_DEFAULT,
	[POLLogLevelError] = OS_LOG_TYPE_ERROR,
	[POLLogLevelWarn] = OS_LOG_TYPE_DEFAULT,
	[POLLogLevelInfo] = OS_LOG_TYPE_INFO,
	[POLLogLevelTrace] = OS_LOG_TYPE_DEBUG,
};

os_log_type_t POLLogLevelToOSLogType(POLLogLevel level)
{
	if (level > POL_ARRAY_SIZE(POLLogOSLogTypes) - 1)
		return OS_LOG_TYPE_DEFAULT;
	return POLLogOSLogTypes[level];
}
