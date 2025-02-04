/*
 *  POLNetworkSession.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLNetworkSession.h"
#import "POLPolling.h"
#import "POLPolling+Private.h"

#import "POLReward.h"
#import "POLTriggeredSurvey.h"
#import "POLSurvey.h"
#import "POLSurvey+Private.h"
#import "POLStorage.h"

#import "NSURLRequest+Additions.h"

#if USE_LOCAL_SERVER
NSString * const POLNetworkSessionAvailableSurveyAPIEndpoint = @"http://localhost:8080/api/sdk/surveys/available";
NSString * const POLNetworkSessionSurveyAPIEndpoint = @"http://localhost:8080/api/sdk/surveys/";
NSString * const POLNetworkSessionEventAPIEndpoint = @"http://localhost:8080/api/events/collect";
#else
NSString * const POLNetworkSessionAvailableSurveyAPIEndpoint = @"https://api.polling.com/api/sdk/surveys/available";
NSString * const POLNetworkSessionSurveyAPIEndpoint = @"https://api.polling.com/api/sdk/surveys/";
NSString * const POLNetworkSessionEventAPIEndpoint = @"https://api.polling.com/api/events/collect";
#endif

NSString * const POLNetworkSessionUserQueryName = @"user";
NSString * const POLNetworkSessionCustomerIDQueryName = @"customer_id";
NSString * const POLNetworkSessionAPIKeyQueryName = @"api_key";

typedef NS_ENUM(NSInteger, POLSurveyDataTaskType) {
	POLSurveyDataTaskTypeNone,
	POLSurveyDataTaskTypeGetSurveyDetails,
	POLSurveyDataTaskTypeStartSurvey,
	POLSurveyDataTaskTypeCompleteSurvey,
};

NSString * const POLSurveyDataTaskTypeNoneDescription = @"None";
NSString * const POLSurveyDataTaskTypeGetSurveyDetailsDescription = @"GetSurveyDetails";
NSString * const POLSurveyDataTaskTypeStartSurveyDescription = @"StartSurvey";
NSString * const POLSurveyDataTaskTypeCompleteSurveyDescription = @"CompleteSurvey";

NSString * const POLSurveyDataTaskTypeDescriptions[] = {
	[POLSurveyDataTaskTypeNone] = POLSurveyDataTaskTypeNoneDescription,
	[POLSurveyDataTaskTypeGetSurveyDetails] = POLSurveyDataTaskTypeGetSurveyDetailsDescription,
	[POLSurveyDataTaskTypeStartSurvey] = POLSurveyDataTaskTypeStartSurveyDescription,
	[POLSurveyDataTaskTypeCompleteSurvey] = POLSurveyDataTaskTypeCompleteSurveyDescription,
};

NSString * const POLSurveyDataTaskTypeDescription(POLSurveyDataTaskType taskType)
{
	if (taskType > POL_ARRAY_SIZE(POLSurveyDataTaskTypeDescriptions) - 1)
		return @"Unknown";
	return POLSurveyDataTaskTypeDescriptions[taskType];
}

@interface POLNetworkSession () <NSURLSessionDataDelegate>

@end

@implementation POLNetworkSession {
	NSURLSessionConfiguration *_URLSessionConfiguration;
	NSURLSession *_URLSession;
	NSMutableDictionary<NSURLSessionDataTask *, NSMutableData *> *_dataTasks;
}

- (NSURLSessionConfiguration *)URLSessionConfiguration
{
	if (_URLSessionConfiguration)
		return _URLSessionConfiguration;

	_URLSessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
	_URLSessionConfiguration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
	_URLSessionConfiguration.HTTPShouldSetCookies = NO;

	return _URLSessionConfiguration;
}

- (NSURLSession *)URLSession
{
	if (_URLSession)
		return _URLSession;

	_URLSession = [NSURLSession
		sessionWithConfiguration:self.URLSessionConfiguration
		delegate:self
		delegateQueue:NSOperationQueue.mainQueue
	];

	return _URLSession;
}

#pragma mark - URL Builder

+ (NSURL *)URLForEndpoint:(NSString *)endpoint
		   withCustomerID:(NSString * __nullable)customerID APIKey:(NSString * __nullable)apiKey
{
	NSURL *url = nil;
	NSURLComponents *urlComponents = [NSURLComponents componentsWithString:endpoint];
	if (!urlComponents) {
		POLError *err = POLErrorWithCode(POLNetworkSessionBadEndpointURLError);
		POLLogError("Bad endpoint URL=%@, error=%@", endpoint, err);
	}
	NSMutableArray *queryItems = NSMutableArray.new;

	if (customerID)
		[queryItems addObject:[NSURLQueryItem queryItemWithName:POLNetworkSessionCustomerIDQueryName value:customerID]];
	if (apiKey)
		[queryItems addObject:[NSURLQueryItem queryItemWithName:POLNetworkSessionAPIKeyQueryName value:apiKey]];

	urlComponents.queryItems = queryItems;
	url = urlComponents.URL;
	if (!url) {
		POLError *err = POLErrorWithCode(POLNetworkSessionCouldNotBindURLParametersError);
		POLLogError("Could not bind parameters URL=%@, params=%@, error=%@", endpoint, queryItems, err);
	}

	return url;
}

#pragma mark - Task Life Cycle

- (void)beginDataTask:(NSURLSessionDataTask *)dataTask
{
	POLLogTrace("%s dataTask=%@", __func__, dataTask);
	if (!_dataTasks)
		_dataTasks = [NSMutableDictionary<NSURLSessionDataTask *, NSMutableData *> new];
	_dataTasks[dataTask] = NSMutableData.data;
	if (dataTask.state != NSURLSessionTaskStateSuspended) {
		//POLError *err = POLErrorWithCode(POLNetworkSessionTaskCanNotResumeError);
		POLLogWarn("Attempted to resume task in non-resumable state dataTask=%@", dataTask);
	}
	[dataTask resume];
}

- (NSData *)dataForDataTask:(NSURLSessionDataTask *)dataTask
{
	NSData *data = _dataTasks[dataTask];
	if (!data) {
		// POLNetworkSessionDataTaskDoesNotExistsError
		POLLogWarn("Data for task not found dataTask=%@", dataTask);
	}
	return data;
}

- (void)finishDataTask:(NSURLSessionDataTask *)dataTask
{
	POLLogTrace("%s dataTask=%@", __func__, dataTask);
	if (!_dataTasks[dataTask]) {
		// POLNetworkSessionDataTaskDoesNotExistsError
		// not an error, a waring perhaps
		POLLogWarn("Task not found dataTask=%@", dataTask);
	}
	[_dataTasks removeObjectForKey:dataTask];
}

#pragma mark - JSON Parsing

- (NSDictionary *)topLevelDictionaryForData:(NSData *)data error:(POLError **)error
{
	NSDictionary *payload = nil;
	NSError *jErr = nil;
	POLError *pErr = nil;

#if DEBUG_RAW_JSON
	POLLogInfo("Raw JSON: %@", [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding]);
#endif

	payload = [NSJSONSerialization
		JSONObjectWithData:data
		options:0
		error:&jErr
	];

	if (!payload || jErr) {
		if (jErr) {
			// error should have code NSPropertyListReadCorruptError and describes the problem
			pErr = POLErrorWithCodeUnderlyingError(POLNetworkSessionMalformedResponseError, jErr);
		} else
			pErr = POLErrorWithCode(POLNetworkSessionMalformedResponseError);
		POLLogError("Malformed response error=%@", pErr);
		if (error)
			*error = pErr;
		return @{};
	}

	if (![payload isKindOfClass:NSDictionary.class]) {
		pErr = POLErrorWithCode(POLNetworkSessionExpectedDictionaryError);
		POLLogError("Unexpected JSON payload error=%@", pErr);
		if (error)
			*error = pErr;
		return @{};
	}

	if (payload.count == 0) {
		pErr = POLErrorWithCode(POLNetworkSessionEmptyTopLevelDictionaryError);
		POLLogError("Unexpected JSON payload error=%@", pErr);
		if (error)
			*error = pErr;
		return @{};
	}

	return payload;
}

- (NSDictionary *)topLevelDictionaryForDataTask:(NSURLSessionDataTask *)dataTask error:(POLError **)error
{
	NSData *data = [self dataForDataTask:dataTask];
	return [self topLevelDictionaryForData:data error:error];
}

/**
 * Parse available surveys payload
 *
 * Payload is a JSON object with the structure
 *
 * ```json
 * {
 *     "data": [{
 *         "name": "survey name",
 *         "question_count": 1,
 *         "reward": {
 *             "reward_amount": null,
 *             "reward_name": null,
 *         }
 *     }],
 *     "plan": "",
 *     "theme": null
 * }
 * ```
 *
 * @param data the NSData from the response
 * @return array of abailable surveys
 */
- (NSArray<POLSurvey *> *)surveysForData:(NSData *)data error:(POLError **)error
{
	NSDictionary *payload = [self topLevelDictionaryForData:data error:error];
	if (error && *error)
		return @[];
	NSArray *payloadData = nil;
	POLError *pErr = nil;

#if DEBUG_JSON_PAYLOADS
	POLLogInfo("Available surveys: %@", payload);
#endif

	if (!(payloadData = payload[@"data"])) {
		pErr = POLErrorWithCode(POLNetworkSessionNoValueForRequiredKeyError);
		POLLogError("Unexpected JSON payload error=%@", pErr);
		if (error)
			*error = pErr;
		return @[];
	}

	if (![payloadData isKindOfClass:NSArray.class]) {
		pErr = POLErrorWithCode(POLNetworkSessionExpectedArrayError);
		POLLogError("Unexpected JSON payload error=%@", pErr);
		if (error)
			*error = pErr;
		return @[];
	}

	NSMutableArray<POLSurvey *> *surveys = [NSMutableArray<POLSurvey *> new];
	for (NSDictionary *surveyDict in payloadData) {
		POLSurvey *survey = [POLSurvey surveyFromJSONDictionary:surveyDict];
		[surveys addObject:survey];
	}

	return surveys;
}

- (NSArray<POLSurvey *> *)surveysForDataTask:(NSURLSessionDataTask *)dataTask error:(POLError **)error
{
	NSData *data = [self dataForDataTask:dataTask];
	return [self surveysForData:data error:error];
}

/**
 * Parse triggered surveys payload
 *
 * Payload is a JSON object with the structure
 *
 * ```json
 * {
 *     "message" : "Event data saved successfully!",
 *     "triggered_surveys" : [{
 *         "delay_seconds" : 4,
 *         "delayed_timestamp" : "2025-01-22T20:21:07+00:00",
 *         "survey" : {
 *             "name" : "survey name",
 *             "survey_uuid" : "365ae2ef-0ca6-4ba9-a07c-1a3d707e680d"
 *         }
 *     }]
 * }
 * ```
 *
 * @param dataTask the NSURLSessionDataTask
 * @return array of triggered survey objects
 */
- (NSArray<POLTriggeredSurvey *> *)triggeredSurveysForDataTask:(NSURLSessionDataTask *)dataTask error:(POLError **)error
{
	NSDictionary *payload = [self topLevelDictionaryForDataTask:dataTask error:error];
	if (error && *error)
		return @[];
	NSArray *payloadData = nil;
	POLError *pErr = nil;

#if DEBUG_JSON_PAYLOADS
	NSLog(@"Triggered surveys: %@", payload);
#endif

	if (!(payloadData = payload[@"triggered_surveys"])) {
		pErr = POLErrorWithCode(POLNetworkSessionNoValueForRequiredKeyError);
		POLLogError("Unexpected JSON payload error=%@", pErr);
		if (error)
			*error = pErr;
		return @[];
	}

	if (![payloadData isKindOfClass:NSArray.class]) {
		pErr = POLErrorWithCode(POLNetworkSessionExpectedArrayError);
		POLLogError("Unexpected JSON payload error=%@", pErr);
		if (error)
			*error = pErr;
		return @[];
	}

	NSMutableArray<POLTriggeredSurvey *> *triggeredSurveys = [NSMutableArray<POLTriggeredSurvey *> new];
	for (NSDictionary *triggeredSurveyDict in payloadData) {
		POLTriggeredSurvey *triggeredSurvey = [POLTriggeredSurvey triggeredSurveyFromJSONDictionary:triggeredSurveyDict];
		[triggeredSurveys addObject:triggeredSurvey];
	}

	return triggeredSurveys;
}

/**
 * Parse survey details payload
 *
 * Payload is a JSON object with the structure
 *
 * ```json
 * {
 *     "data": {
 *        "uuid": "365ae2ef-0ca6-4ba9-a07c-1a3d707e680d",
 *        "name": "Survey Test SDK 2",
 *        "reward": {
 *            "reward_amount": "10",
 *            "reward_name": "Rubies",
 *            "complete_extra_json": "{\n    \"test\": 123\n}"
 *        },
 *        "question_count": 1,
 *        "user_survey_status": "available",
 *        "completed_at": null
 *    }
 * }
 * ```
 *
 * @param data response body
 * @return a survey object
 */
- (POLSurvey *)surveyForData:(NSData *)data error:(POLError **)error
{
	NSDictionary *payload = [self topLevelDictionaryForData:data error:error];
	if (error && *error)
		return nil;
	NSDictionary *payloadData = nil;
	POLError *pErr = nil;

#if DEBUG_JSON_PAYLOADS
	POLLogInfo("Survey: %@", payload);
#endif

	if (!(payloadData = payload[@"data"])) {
		pErr = POLErrorWithCode(POLNetworkSessionNoValueForRequiredKeyError);
		POLLogError("Unexpected JSON payload error=%@", pErr);
		if (error)
			*error = pErr;
		return nil;
	}

	if (![payloadData isKindOfClass:NSDictionary.class]) {
		pErr = POLErrorWithCode(POLNetworkSessionExpectedDictionaryError);
		POLLogError("Unexpected JSON payload error=%@", pErr);
		if (error)
			*error = pErr;
		return nil;
	}

	return [POLSurvey surveyFromJSONDictionary:payloadData];
}

- (POLSurvey *)surveyForDataTask:(NSURLSessionDataTask *)dataTask error:(POLError **)error
{
	NSData *data = [self dataForDataTask:dataTask];
	return [self surveyForData:data error:error];
}

/**
 * Parse embed completed response
 *
 * Payload is a JSON object with the structure
 *
 * ```json
 * {
 *     "data":[]
 * }
 *```
 *
 * or
 *
 * ```json
 * {
 *     "data": [{
 *         "uuid": "dcaca06d-5ed5-4235-90fb-e2d7efc2a5b6",
 *         "name": "Survey Test SDK 1",
 *         "started_at": "2025-01-27T19:52:44+00:00",
 *         "completed_at": "2025-01-27T19:52:45+00:00",
 *         "reward": {
 *             "complete_extra_json": null,
 *             "reward_amount": null,
 *             "reward_name": null
 *         }
 *     }]
 * }
 * ```
 *
 * @param data response body
 * @return a survey object
 */
- (NSArray<POLSurvey *> *)surveysFromData:(NSData *)data error:(POLError **)error
{
	NSDictionary *payload = [self topLevelDictionaryForData:data error:error];
	if (error && *error)
		return @[];
	NSDictionary *payloadData = nil;
	POLError *pErr = nil;

#if DEBUG_JSON_PAYLOADS
	POLLogInfo("Embed surveys: %@", payload);
#endif

	if (!(payloadData = payload[@"data"])) {
		pErr = POLErrorWithCode(POLNetworkSessionNoValueForRequiredKeyError);
		POLLogError("Unexpected JSON payload error=%@", pErr);
		if (error)
			*error = pErr;
		return @[];
	}

	if (![payloadData isKindOfClass:NSArray.class]) {
		pErr = POLErrorWithCode(POLNetworkSessionExpectedArrayError);
		POLLogError("Unexpected JSON payload error=%@", pErr);
		if (error)
			*error = pErr;
		return @[];
	}

	NSMutableArray<POLSurvey *> *surveys = [NSMutableArray<POLSurvey *> new];
	for (NSDictionary *surveyDict in payloadData) {
		POLSurvey *survey = [POLSurvey surveyFromJSONDictionary:surveyDict];
		[surveys addObject:survey];
	}

	return surveys;
}

#pragma mark - Surveys

- (void)fetchAvailableSurveys
{
	POLLogTrace("%s", __func__);
	NSURL *url = [self.class URLForEndpoint:POLNetworkSessionAvailableSurveyAPIEndpoint
							 withCustomerID:POLPolling.polling.customerID
									 APIKey:POLPolling.polling.apiKey];

	NSURLRequest *req = [NSURLRequest GETURLRequest:url];

	NSURLSessionDataTask *dataTask = [self.URLSession dataTaskWithRequest:req];
	dataTask.taskDescription = POLNetworkSessionAvailableSurveyAPIEndpoint;
	dataTask.priority = NSURLSessionTaskPriorityLow;
	[self beginDataTask:dataTask];
}

- (void)fetchSurvey:(POLSurvey *)survey taskType:(POLSurveyDataTaskType)taskType
{
	POLLogTrace("%s survey=%@, taskType=%@", __func__, survey, POLSurveyDataTaskTypeDescription(taskType));
	POLError *pErr = nil;

	NSURLSessionDataTask *dataTask;

	switch (taskType) {
	case POLSurveyDataTaskTypeGetSurveyDetails: {
		NSURL *url = [NSURL URLWithString:POLNetworkSessionSurveyAPIEndpoint];
		url = [url URLByAppendingPathComponent:survey.UUID];
		url = [POLNetworkSession URLForEndpoint:url.absoluteString
								 withCustomerID:POLPolling.polling.customerID
										 APIKey:POLPolling.polling.apiKey];

		NSURLRequest *req = [NSURLRequest GETURLRequest:url];
		dataTask = [self.URLSession dataTaskWithRequest:req];
		break;
	}
	case POLSurveyDataTaskTypeStartSurvey: {
		NSURLRequest *req = [NSURLRequest GETURLRequest:survey.completionURL];
		dataTask = [self.URLSession dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
			POLError *pErr = nil;
			if (error) {
				pErr = POLErrorWithCodeUnderlyingError(POLNetworkSessionDataTaskFailedError, error);
				POLLogError("Encountered error processing request=%@, response=%@, error=%@", req, response, error);
				[self.delegate networkSessionDidFailWithError:pErr];
				return;
			}
			NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
			POLLogInfo("%@ %@ => %@ %@", req.HTTPMethod, req.URL,
				@(httpResponse.statusCode), httpResponse.MIMEType);
			if (httpResponse.statusCode != 200) {
				pErr = POLErrorWithCode(POLNetworkSessionUnexpectedHTTPStatusCodeError);
				POLLogError("Failed to start survey statusCode=%@, error=%@", @(httpResponse.statusCode), pErr);
				[self.delegate networkSessionDidFailWithError:pErr];
				return;
			}

			if (![httpResponse.MIMEType isEqualToString:@"application/json"]) {
				pErr = POLErrorWithCode(POLNetworkSessionUnexpectedContentTypeError);
				POLLogError("Expected application/json got Content-Type=%@ error=%@", httpResponse.MIMEType, pErr);
				[self.delegate networkSessionDidFailWithError:pErr];
				return;
			}

			if (survey.embedViewRequested) {
				NSArray<POLSurvey *> *responseSurveys = [self surveysFromData:data error:&pErr];
				if (pErr) {
					[self.delegate networkSessionDidFailWithError:pErr];
					return;
				}
				[POLPolling.polling.openedSurveys addObjectsFromArray:responseSurveys];
			} else {
				POLSurvey *responseSurvey = [self surveyForData:data error:&pErr];
				if (pErr) {
					[self.delegate networkSessionDidFailWithError:pErr];
					return;
				}
				[POLPolling.polling.openedSurveys addObject:responseSurvey];
			}
		}];
		break;
	}
	case POLSurveyDataTaskTypeCompleteSurvey: {
		NSURLRequest *req = [NSURLRequest GETURLRequest:survey.completionURL];
		dataTask = [self.URLSession dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
			POLError *pErr = nil;
			if (error) {
				pErr = POLErrorWithCodeUnderlyingError(POLNetworkSessionDataTaskFailedError, error);
				POLLogError("Encountered error processing request=%@, response=%@, error=%@", req, response, error);
				[self.delegate networkSessionDidFailWithError:pErr];
				return;
			}
			NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
			POLLogInfo("%@ %@ => %@ %@", req.HTTPMethod, req.URL,
				@(httpResponse.statusCode), httpResponse.MIMEType);
			if (httpResponse.statusCode != 200) {
				pErr = POLErrorWithCode(POLNetworkSessionUnexpectedHTTPStatusCodeError);
				POLLogError("Failed to complete survey statusCode=%@, error=%@", @(httpResponse.statusCode), pErr);
				[self.delegate networkSessionDidFailWithError:pErr];
				return;
			}

			if (![httpResponse.MIMEType isEqualToString:@"application/json"]) {
				pErr = POLErrorWithCode(POLNetworkSessionUnexpectedContentTypeError);
				POLLogError("Expected application/json got Content-Type=%@ error=%@", httpResponse.MIMEType, pErr);
				[self.delegate networkSessionDidFailWithError:pErr];
				return;
			}

			[POLStorage.storage read];
			if (survey.embedViewRequested) {
				NSArray<POLSurvey *> *responseSurveys = [self surveysFromData:data error:&pErr];
				if (pErr) {
					[self.delegate networkSessionDidFailWithError:pErr];
					return;
				}
				for (POLSurvey *responseSurvey in responseSurveys) {
					if ([POLStorage.storage alreadyCompleted:responseSurvey]) {
						POLLogInfo("Survey alread completed responseSurvey=%@", responseSurvey);
						continue;
					}
					[POLStorage.storage addCompletedSurvey:responseSurvey];
					[self.delegate networkSessionDidCompleteSurvey:responseSurvey];
				}

			} else {
				POLSurvey *responseSurvey = [self surveyForData:data error:&pErr];
				if (pErr) {
					[self.delegate networkSessionDidFailWithError:pErr];
					return;
				}
				[self.delegate networkSessionDidCompleteSurvey:responseSurvey];
			}
			[POLStorage.storage write];
		}];
		break;
	}
	default:
		pErr = POLErrorWithCode(POLNetworkSessionTaskTypeUnknownError);
		POLLogError("Unknown task type survey=%@ taskType=%@, error=%@", survey, POLSurveyDataTaskTypeDescription(taskType), pErr);
		[self.delegate networkSessionDidFailWithError:pErr];
		return;
	}

	dataTask.taskDescription = POLNetworkSessionSurveyAPIEndpoint;
	dataTask.priority = NSURLSessionTaskPriorityLow;

	[self beginDataTask:dataTask];
}

- (void)fetchSurveyWithUUID:(NSString *)uuid
{
	POLLogTrace("%s UUID=%@", __func__, uuid);
	[self fetchSurvey:[POLSurvey surveyWithUUID:uuid]];
}

- (void)fetchSurvey:(POLSurvey *)survey
{
	[self fetchSurvey:survey taskType:POLSurveyDataTaskTypeGetSurveyDetails];
}

- (void)startSurvey:(POLSurvey *)survey
{
	[self fetchSurvey:survey taskType:POLSurveyDataTaskTypeStartSurvey];
}

- (void)completeSurvey:(POLSurvey *)survey
{
	[self fetchSurvey:survey taskType:POLSurveyDataTaskTypeCompleteSurvey];
}

#pragma mark - Events

- (void)postEvent:(NSString *)eventName withValue:(NSString *)eventValue
{
	POLLogTrace("%s eventName=%@, eventValue=%@", __func__, eventName, eventValue);
	NSURLComponents *urlComponents = [NSURLComponents componentsWithString:POLNetworkSessionEventAPIEndpoint];
	urlComponents.queryItems = @[
		[NSURLQueryItem queryItemWithName:POLNetworkSessionUserQueryName value:POLPolling.polling.customerID],
		[NSURLQueryItem queryItemWithName:POLNetworkSessionAPIKeyQueryName value:POLPolling.polling.apiKey]
	];
	NSURL *url = urlComponents.URL;

	NSString *post = [NSString stringWithFormat:@"event=%@&value=%@", eventName, eventValue];
	NSData *postBody = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	if (!postBody) {
		POLError *pErr = POLErrorWithCode(POLEncodingFailedError);
		POLLogError("Could not encode POST body URL=%@, body=%@, error=%@", url, post, pErr);
		[self.delegate networkSessionDidFailWithError:pErr];
		return;
	}
	NSString *postLength = [NSString stringWithFormat:@"%@", @(postBody.length)];

	NSMutableURLRequest *req = [NSURLRequest POSTURLRequest:url];
	req.HTTPBody = postBody;
	[req addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req addValue:postLength forHTTPHeaderField:@"Content-Length"];

	NSURLSessionDataTask *dataTask = [self.URLSession dataTaskWithRequest:req];
	dataTask.taskDescription = POLNetworkSessionEventAPIEndpoint;
	dataTask.priority = NSURLSessionTaskPriorityLow;
	[self beginDataTask:dataTask];
}

#pragma mark - Control

- (void)invalidateAndCancel
{
	if (POLIsSDKShutdown())
		[self.URLSession invalidateAndCancel];
	else
		POLLogWarn("Attempt to invalidate URL session without catastrophic failure");
}

#pragma mark - URL Session Delegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
	POLLogTrace("%s session=%@, error=%@", __func__, session, error);
	if (!error) {
		// the URL session was invalidated because we explictly requested
		// probably because the SDK was shutdown, do nothing
		return;
	}
	// the URL session was invalidated because of an error
	POLError *pErr = POLErrorWithCodeUnderlyingError(POLNetworkSessionError, error);
	[self.delegate networkSessionDidFailWithError:pErr];
}

- (void)URLSession:(NSURLSession *)session
			  task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
	POLLogTrace("%s session=%@, task=%@, error=%@", __func__, session, task, error);
	POLError *pErr = nil;

	if (error && error.code == NSURLErrorCancelled) {
		// NOTE: no reason to handle NSURLErrorCancelled because that
		// is explict and the error must have arose elsewhere and should
		// be handled where it arose
		POLLogTrace("Task was cancelled: %s session=%@, task=%@, error=%@", __func__, session, task, error);
		return;
	} else if (error) {
		pErr = POLErrorWithCodeUnderlyingError(POLNetworkSessionDataTaskFailedError, error);
		POLLogError("Task complete with error: %s - %@", __func__, pErr);
		[self.delegate networkSessionDidFailWithError:pErr];
		return;
	}

	if (task.taskDescription == POLNetworkSessionAvailableSurveyAPIEndpoint) {
		NSURLSessionDataTask *dataTask = (NSURLSessionDataTask *)task;
		NSArray<POLSurvey *> *availableSurveys = [self surveysForDataTask:dataTask error:&pErr];
		if (pErr)
			[self.delegate networkSessionDidFailWithError:pErr];
		else
			[self.delegate networkSessionDidFetchAvailableSurveys:availableSurveys];
		[self finishDataTask:dataTask];
		return;
	}

	if (task.taskDescription == POLNetworkSessionEventAPIEndpoint) {
		NSURLSessionDataTask *dataTask = (NSURLSessionDataTask *)task;
		NSArray<POLTriggeredSurvey *> *triggeredSurveys = [self triggeredSurveysForDataTask:dataTask error:&pErr];
		if (pErr)
			[self.delegate networkSessionDidFailWithError:pErr];
		else
			[self.delegate networkSessionDidUpdateTriggeredSurveys:triggeredSurveys];
		[self finishDataTask:dataTask];
		return;
	}

	if (task.taskDescription == POLNetworkSessionSurveyAPIEndpoint) {
		NSURLSessionDataTask *dataTask = (NSURLSessionDataTask *)task;
		POLSurvey *survey = [self surveyForDataTask:dataTask error:&pErr];
		if (pErr)
			[self.delegate networkSessionDidFailWithError:pErr];
		else
			[self.delegate networkSessionDidFetchSurvey:survey];
		[self finishDataTask:dataTask];
		return;
	}
}

- (void)URLSession:(NSURLSession *)session
	dataTask:(NSURLSessionDataTask *)dataTask
	didReceiveResponse:(NSURLResponse *)response
	completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
	POLLogTrace("%s session=%@, dataTask=%@, response=%@", __func__, session, dataTask, response);
	POLError *pErr = nil;

	NSURLRequest *request;
	NSHTTPURLResponse *httpResponse;

	request = dataTask.currentRequest;
	httpResponse = (NSHTTPURLResponse *)response;

	POLLogInfo("%@ %@ => %@ %@", request.HTTPMethod, request.URL,
			   @(httpResponse.statusCode), httpResponse.MIMEType);

	if (httpResponse.statusCode != 200) {
		pErr = POLErrorWithCode(POLNetworkSessionUnexpectedHTTPStatusCodeError);
		POLLogError("Bad response status code %@", pErr);
		[self.delegate networkSessionDidFailWithError:pErr];
		completionHandler(NSURLSessionResponseCancel);
		return;
	}

	if (![httpResponse.MIMEType isEqualToString:@"application/json"]) {
		pErr = POLErrorWithCode(POLNetworkSessionUnexpectedContentTypeError);
		POLLogError("Expected application/json got Content-Type=%@ error=%@",  httpResponse.MIMEType, pErr);
		[self.delegate networkSessionDidFailWithError:pErr];
		completionHandler(NSURLSessionResponseCancel);
		return;
	}

	// continue
	completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
	dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
	POLLogTrace("%s session=%@, dataTask=%@, dataLenght=%{iec-bytes}lu", __func__, session, dataTask, (unsigned long)data.length);

	NSMutableData *mutData = (NSMutableData *)[self dataForDataTask:dataTask];
	[mutData appendData:data];
}

@end
