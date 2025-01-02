/*
 *  POLSurveyCompletionController.m
 *  Polling
 *
 *  Copyright © 2025 Polling.com. All rights reserved.
 */

#import "POLSurveyCompletionController.h"

@implementation POLSurveyCompletionController

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
}

@end
