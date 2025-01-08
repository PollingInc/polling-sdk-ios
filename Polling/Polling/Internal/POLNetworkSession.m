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

#if USE_LOCAL_SERVER
//NSString * const POLNetworkSessionBaseAppURL = @"https://app.polling.com";
//NSString * const POLNetworkSessionBaseAPIURL = @"https://api.polling.com";
//NSString * const POLNetworkSessionSurveyViewEndpoint = @"http://localhost:8080/sdk/available-surveys";
NSString * const POLNetworkSessionAvailableSurveyAPIEndpoint = @"http://localhost:8080/api/sdk/surveys/available";
NSString * const POLNetworkSessionSurveyAPIEndpoint = @"http://localhost:8080/api/sdk/surveys/";
NSString * const POLNetworkSessionEventAPIEndpoint = @"http://localhost:8080/api/events/collect";
#else
//NSString * const POLNetworkSessionBaseAppURL = @"https://app.polling.com";
//NSString * const POLNetworkSessionBaseAPIURL = @"https://api.polling.com";
//NSString * const POLNetworkSessionSurveyViewEndpoint = @"https://app.polling.com/sdk/available-surveys";
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
	POLSurveyDataTaskTypeBeginSurvey,
	POLSurveyDataTaskTypeCompleteSurvey,
};

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

+ (NSURL *)URLForEndpoint:(NSString *)endpoint
		   withCustomerID:(NSString * __nullable)customerID APIKey:(NSString * __nullable)apiKey
{
	NSURLComponents *urlComponents = [NSURLComponents componentsWithString:endpoint];
	NSMutableArray *queryItems = NSMutableArray.new;

	if (customerID)
		[queryItems addObject:[NSURLQueryItem queryItemWithName:POLNetworkSessionCustomerIDQueryName value:customerID]];
	if (apiKey)
		[queryItems addObject:[NSURLQueryItem queryItemWithName:POLNetworkSessionAPIKeyQueryName value:apiKey]];

	urlComponents.queryItems = queryItems;

	return urlComponents.URL;
}

- (void)beginDataTask:(NSURLSessionDataTask *)dataTask
{
	if (!_dataTasks)
		_dataTasks = [NSMutableDictionary<NSURLSessionDataTask *, NSMutableData *> new];
	_dataTasks[dataTask] = NSMutableData.data;
	[dataTask resume];
}

- (NSData *)dataForDataTask:(NSURLSessionDataTask *)dataTask
{
	return _dataTasks[dataTask];
}

- (void)finishDataTask:(NSURLSessionDataTask *)dataTask
{
	_dataTasks[dataTask] = nil;
}

- (NSDictionary *)topLevelDictionaryForData:(NSData *)data
{
	NSDictionary *payload = nil;
	NSError *error = nil;

#if DEBUG_RAW_JSON
	NSLog(@"Raw JSON: %@", [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding]);
#endif

	payload = [NSJSONSerialization
		JSONObjectWithData:data
		options:0
		error:&error
	];

	if (error) {
		NSLog(@"Error: %s - %@", __func__, error);
		return @{};
	}

	if (!payload) {
		error = [NSError errorWithDomain:@"Networking" code:0 userInfo:nil];
		NSLog(@"Error: %s - %@", __func__, error);
		return @{};
	}

	return payload;
}

- (NSDictionary *)topLevelDictionaryForDataTask:(NSURLSessionDataTask *)dataTask
{
	NSData *data = [self dataForDataTask:dataTask];
	return [self topLevelDictionaryForData:data];
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
- (NSArray<POLSurvey *> *)surveysForData:(NSData *)data
{
	NSDictionary *payload = [self topLevelDictionaryForData:data];
	NSArray *payloadData = nil;
	NSError *error = nil;

#if DEBUG_JSON_PAYLOADS
	NSLog(@"Available surveys: %@", payload);
#endif

	// payload expect NSDictionary
	if (![payload isKindOfClass:NSDictionary.class]) {
		error = [NSError errorWithDomain:@"Data" code:0 userInfo:nil];
		NSLog(@"Unexpected JSON payload: %s - %@", __func__, error);
		return @[];
	}

	if (payload.count == 0)
		return @[];

	// payload.data expect NSArray
	if (!(payloadData = payload[@"data"])) {
		error = [NSError errorWithDomain:@"Data" code:1 userInfo:nil];
		NSLog(@"Unexpected JSON payload: %s - %@", __func__, error);
		return @[];
	}

	NSMutableArray<POLSurvey *> *surveys = [NSMutableArray<POLSurvey *> new];
	for (NSDictionary *surveyDict in payloadData) {
		POLSurvey *survey = [POLSurvey surveyFromJSONDictionary:surveyDict];
		[surveys addObject:survey];
	}

	return surveys;
}

- (NSArray<POLSurvey *> *)surveysForDataTask:(NSURLSessionDataTask *)dataTask
{
	NSData *data = [self dataForDataTask:dataTask];
	return [self surveysForData:data];
}

- (NSArray<POLTriggeredSurvey *> *)triggeredSurveysForDataTask:(NSURLSessionDataTask *)dataTask
{
	NSDictionary *payload = [self topLevelDictionaryForDataTask:dataTask];
	NSArray *payloadData = nil;
	NSError *error = nil;

#if DEBUG_JSON_PAYLOADS
	NSLog(@"Triggered surveys: %@", payload);
#endif

	// payload expect NSDictionary
	if (![payload isKindOfClass:NSDictionary.class]) {
		error = [NSError errorWithDomain:@"Data" code:0 userInfo:nil];
		NSLog(@"Unexpected JSON payload: %s - %@", __func__, error);
		return @[];
	}

	if (payload.count == 0)
		return @[];

	// payload.data expect NSArray
	if (!(payloadData = payload[@"triggered_surveys"])) {
		error = [NSError errorWithDomain:@"Data" code:1 userInfo:nil];
		NSLog(@"Unexpected JSON payload: %s - %@", __func__, error);
		return @[];
	}

	NSMutableArray<POLTriggeredSurvey *> *triggeredSurveys = [NSMutableArray<POLTriggeredSurvey *> new];
	for (NSDictionary *triggeredSurveyDict in payloadData) {
		POLTriggeredSurvey *triggeredSurvey = [POLTriggeredSurvey triggeredSurveyFromJSONDictionary:triggeredSurveyDict];
		[triggeredSurveys addObject:triggeredSurvey];
	}

	return triggeredSurveys;
}

- (POLSurvey *)surveyForDataTask:(NSURLSessionDataTask *)dataTask
{
	NSDictionary *payload = [self topLevelDictionaryForDataTask:dataTask];
	NSDictionary *payloadData = nil;
	NSError *error = nil;

#if DEBUG_JSON_PAYLOADS
	NSLog(@"Survey: %@", payload);
#endif

	// payload expect NSDictionary
	if (![payload isKindOfClass:NSDictionary.class]) {
		error = [NSError errorWithDomain:@"Data" code:0 userInfo:nil];
		NSLog(@"Unexpected JSON payload: %s - %@", __func__, error);
		return nil;
	}

	if (payload.count == 0)
		return nil;

	// payload.data expect NSDictionary
	if (!(payloadData = payload[@"data"])) {
		error = [NSError errorWithDomain:@"Data" code:1 userInfo:nil];
		NSLog(@"Unexpected JSON payload: %s - %@", __func__, error);
		return nil;
	}

	return [POLSurvey surveyFromJSONDictionary:payloadData];
}

- (POLSurvey *)surveyForData:(NSData *)data
{
	NSDictionary *payload = [self topLevelDictionaryForData:data];
	NSDictionary *payloadData = nil;
	NSError *error = nil;

#if DEBUG_JSON_PAYLOADS
	NSLog(@"Survey: %@", payload);
#endif

	// payload expect NSDictionary
	if (![payload isKindOfClass:NSDictionary.class]) {
		error = [NSError errorWithDomain:@"Data" code:0 userInfo:nil];
		NSLog(@"Unexpected JSON payload: %s - %@", __func__, error);
		return nil;
	}

	if (payload.count == 0)
		return nil;

	// payload.data expect NSDictionary
	if (!(payloadData = payload[@"data"])) {
		error = [NSError errorWithDomain:@"Data" code:1 userInfo:nil];
		NSLog(@"Unexpected JSON payload: %s - %@", __func__, error);
		return nil;
	}

	return [POLSurvey surveyFromJSONDictionary:payloadData];
}

#pragma mark - Surveys

- (void)fetchAvailableSurveys
{
	NSURL *url = [self.class URLForEndpoint:POLNetworkSessionAvailableSurveyAPIEndpoint
							 withCustomerID:POLPolling.polling.customerID
									 APIKey:POLPolling.polling.apiKey];

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	req.HTTPMethod = @"GET";
	req.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

	NSURLSessionDataTask *dataTask = [self.URLSession dataTaskWithRequest:req];
	dataTask.taskDescription = POLNetworkSessionAvailableSurveyAPIEndpoint;
	dataTask.priority = NSURLSessionTaskPriorityLow;
	[self beginDataTask:dataTask];
}

//- (void)fetchSurvey:(POLSurvey *)survey withTaskDelegate:(id<NSURLSessionTaskDelegate> __nullable)delegate
- (void)fetchSurvey:(POLSurvey *)survey taskType:(POLSurveyDataTaskType)taskType
{
	NSURL *url = [NSURL URLWithString:POLNetworkSessionSurveyAPIEndpoint];
	url = [url URLByAppendingPathComponent:survey.UUID];
	url = [POLNetworkSession URLForEndpoint:url.absoluteString
							 withCustomerID:POLPolling.polling.customerID
									 APIKey:POLPolling.polling.apiKey];

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	req.HTTPMethod = @"GET";
	req.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

	NSURLSessionDataTask *dataTask;

	switch (taskType) {
	case POLSurveyDataTaskTypeGetSurveyDetails: {
		dataTask = [self.URLSession dataTaskWithRequest:req];
		break;
	}
	case POLSurveyDataTaskTypeBeginSurvey: {
		dataTask = [self.URLSession dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
			if (error) {
				NSLog(@"Error: %s - %@", __func__, error);
				return;
			}
			NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
			NSLog(@"Begin survey response %@ %@", @(httpResponse.statusCode), httpResponse.MIMEType);
			if (httpResponse.statusCode != 200) {
				NSLog(@"Error: %s - %@", __func__, @"failed to begin survey");
				return;
			}
			NSArray<POLSurvey *> * surveys = @[[self surveyForData:data]];
			[POLPolling.polling.openedSurveys addObjectsFromArray:surveys];
		}];
		break;
	}
	case POLSurveyDataTaskTypeCompleteSurvey: {
		dataTask = [self.URLSession dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
			if (error) {
				NSLog(@"Error: %s - %@", __func__, error);
				return;
			}
			NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
			NSLog(@"Complete survey response %@ %@", @(httpResponse.statusCode), httpResponse.MIMEType);
			if (httpResponse.statusCode != 200) {
				NSLog(@"Error: %s - %@", __func__, @"failed to complete survey");
				return;
			}
			NSArray<POLSurvey *> * surveys = @[[self surveyForData:data]];
			for (POLSurvey *s in surveys)
				if ([s isEqual:survey])
					[self.delegate networkSessionDidCompleteSurvey:survey];
		}];
		break;
	}
	default:
		NSLog(@"unexpected data task type");
		break;
	}


	dataTask.taskDescription = POLNetworkSessionSurveyAPIEndpoint;
	dataTask.priority = NSURLSessionTaskPriorityLow;

	/* task specific delegates are iOS 15+ */
	//if (delegate) {
	//	dataTask.delegate = delegate;
	//}

	[self beginDataTask:dataTask];
}

- (void)fetchSurvey:(POLSurvey *)survey
{
	[self fetchSurvey:survey taskType:POLSurveyDataTaskTypeGetSurveyDetails];
}

- (void)fetchSurveyWithUUID:(NSString *)uuid
{
	[self fetchSurvey:[POLSurvey surveyWithUUID:uuid]];
}

/* beginSurvey? */
- (void)preCompleteSurvey:(POLSurvey *)survey
{
	[self fetchSurvey:survey taskType:POLSurveyDataTaskTypeBeginSurvey];
}

- (void)completeSurvey:(POLSurvey *)survey
{
	[self fetchSurvey:survey taskType:POLSurveyDataTaskTypeCompleteSurvey];
}

- (void)postEvent:(NSString *)eventName withValue:(NSString *)eventValue
{
	NSURLComponents *urlComponents = [NSURLComponents componentsWithString:POLNetworkSessionEventAPIEndpoint];
	urlComponents.queryItems = @[
		[NSURLQueryItem queryItemWithName:POLNetworkSessionUserQueryName value:POLPolling.polling.customerID],
		[NSURLQueryItem queryItemWithName:POLNetworkSessionAPIKeyQueryName value:POLPolling.polling.apiKey]
	];
	NSURL *url = urlComponents.URL;

	NSString *post = [NSString stringWithFormat:@"event=%@&value=%@", eventName, eventValue];
	NSData *postBody = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%@", @(postBody.length)];

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	req.HTTPMethod = @"POST";
	req.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	req.HTTPBody = postBody;
	[req addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req addValue:postLength forHTTPHeaderField:@"Content-Length"];

	NSURLSessionDataTask *dataTask = [self.URLSession dataTaskWithRequest:req];
	dataTask.taskDescription = POLNetworkSessionEventAPIEndpoint;
	dataTask.priority = NSURLSessionTaskPriorityLow;
	[self beginDataTask:dataTask];
}

#pragma mark - URL Session Delegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
	NSLog(@"Error: %s - %@", __func__, error);
}

- (void)URLSession:(NSURLSession *)session
			  task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
	if (error && error.code != NSURLErrorCancelled) {
		NSLog(@"Error: %s - %@", __func__, error);
		return;
	}

	if (task.taskDescription == POLNetworkSessionAvailableSurveyAPIEndpoint) {
		NSURLSessionDataTask *dataTask = (NSURLSessionDataTask *)task;
		NSArray<POLSurvey *> *availableSurveys = [self surveysForDataTask:dataTask];
		[self.delegate networkSessionDidFetchAvailableSurveys:availableSurveys];
		[self finishDataTask:dataTask];
		return;
	}

	if (task.taskDescription == POLNetworkSessionEventAPIEndpoint) {
		NSURLSessionDataTask *dataTask = (NSURLSessionDataTask *)task;
		NSArray<POLTriggeredSurvey *> *triggeredSurveys = [self triggeredSurveysForDataTask:dataTask];
		[self.delegate networkSessionDidUpdateTriggeredSurveys:triggeredSurveys];
		[self finishDataTask:dataTask];
		return;
	}

	if (task.taskDescription == POLNetworkSessionSurveyAPIEndpoint) {
		NSURLSessionDataTask *dataTask = (NSURLSessionDataTask *)task;
		POLSurvey *survey = [self surveyForDataTask:dataTask];
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
	NSURLRequest *request;
	NSHTTPURLResponse *httpResponse;

	request = dataTask.currentRequest;
	httpResponse = (NSHTTPURLResponse *)response;

	NSLog(@"%@ %@", request.HTTPMethod, request.URL);
	NSLog(@"%@ %@", @(httpResponse.statusCode), httpResponse.MIMEType);

	if (httpResponse.statusCode != 200) {
		// handle error
		completionHandler(NSURLSessionResponseCancel);
		return;
	}

	// continue
	completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
	dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
	[_dataTasks[dataTask] appendData:data];
}

@end
