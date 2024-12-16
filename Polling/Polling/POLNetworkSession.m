/*
 *  POLNetworkSession.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLNetworkSession.h"

#import "Models/POLSurvey.h"
#import "Models/POLReward.h"
#import "Models/POLSurvey+Private.h"

NSString * const POLNetworkSessionBaseAppURL = @"https://app.polling.com";
NSString * const POLNetworkSessionBaseAPIURL = @"https://api.polling.com";

NSString * const POLNetworkSessionSurveyViewEndpoint = @"https://app.polling.com/sdk/available-surveys";
NSString * const POLNetworkSessionSurveysDefaultEmbedViewEndpoint = @"https://app.polling.com/embed/";

NSString * const POLNetworkSessionSurveyAPIEndpoint = @"https://api.polling.com/api/sdk/surveys/available";
NSString * const POLNetworkSessionEventAPIEndpoint = @"https://api.polling.com/api/events/collect";

NSString * const POLNetworkSessionCustomerIDQueryName = @"customer_id";
NSString * const POLNetworkSessionAPIKeyQueryName = @"api_key";

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
		delegateQueue:nil
	];

	return _URLSession;
}

- (NSURL *)URLForEndpoint:(NSString *)endpoint
		   WithCustomerID:(NSString *)customerID APIKey:(NSString *)apiKey
{
	NSURLComponents *urlComponents = [NSURLComponents componentsWithString:endpoint];
	urlComponents.queryItems = @[
		[NSURLQueryItem queryItemWithName:POLNetworkSessionCustomerIDQueryName value:customerID],
		[NSURLQueryItem queryItemWithName:POLNetworkSessionAPIKeyQueryName value:apiKey],
	];

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
 * @param dataTask the NSURLSessionDataTask associated with the endpoint request
 * @return array of abailable surveys
 */
- (NSArray<POLSurvey *> *)surveysForDataTask:(NSURLSessionDataTask *)dataTask
{
	NSData *data = [self dataForDataTask:dataTask];
	NSDictionary *payload;
	NSArray *payloadData;
	NSError *error = nil;

	payload = [NSJSONSerialization
		JSONObjectWithData:data
		options:0
		error:&error
	];

	if (error) {
		NSLog(@"Error: %s - %@", __func__, error);
		return @[];
	}

	if (!payload) {
		error = [NSError errorWithDomain:@"Networking" code:0 userInfo:nil];
		NSLog(@"Error: %s - %@", __func__, error);
		return @[];
	}

	NSLog(@"available surveys %@", payload);

	// payload expect NSDictionary
	if (![payload isKindOfClass:NSDictionary.class]) {
		error = [NSError errorWithDomain:@"Data" code:0 userInfo:nil];
		NSLog(@"Unexpected JSON payload: %s - %@", __func__, error);
		return @[];
	}

	// payload.data expect NSArray
	if (!(payloadData = payload[@"data"])) {
		error = [NSError errorWithDomain:@"Data" code:0 userInfo:nil];
		NSLog(@"Unexpected JSON payload: %s - %@", __func__, error);
		return @[];
	}

	NSMutableArray<POLSurvey *> *surveys = [NSMutableArray<POLSurvey *> new];
	for (NSDictionary *surveyDict in payloadData) {
		[surveys addObject:[POLSurvey surveyFromDictionary:surveyDict]];
	}

	return surveys;
}

#pragma mark - Surveys

- (void)fetchSurveysWithOptions:(NSDictionary *)options
{

}

- (void)fetchSurveysWithCustomerID:(NSString *)customerID APIKey:(NSString *)apiKey
{
	NSURL *url = [self URLForEndpoint:POLNetworkSessionSurveyAPIEndpoint
					   WithCustomerID:customerID APIKey:apiKey];

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	req.HTTPMethod = @"GET";
	req.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

	NSURLSessionDataTask *dataTask = [self.URLSession dataTaskWithRequest:req];
	dataTask.taskDescription = POLNetworkSessionSurveyAPIEndpoint;
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

	if (task.taskDescription == POLNetworkSessionSurveyAPIEndpoint) {
		NSURLSessionDataTask *dataTask = (NSURLSessionDataTask *)task;
		if ([self.delegate respondsToSelector:@selector(networkSessionDidFetchSurveys:)])
			[(id<POLNetworkSessionDelegate>)self.delegate
				networkSessionDidFetchSurveys:[self surveysForDataTask:dataTask]];
		[self finishDataTask:dataTask];
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
