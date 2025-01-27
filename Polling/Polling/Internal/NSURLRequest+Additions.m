//
//  NSURLRequest+Additions.m
//  Polling
//
//  Created by Eddie Hillenbrand on 1/26/25.
//  Copyright © 2025 Polling.com. All rights reserved.
//

#import "NSURLRequest+Additions.h"

NSString * const POLHTTPMethodGET = @"GET";
NSString * const POLHTTPMethodPOST = @"POST";

@implementation NSURLRequest (POLURLRequestAdditions)

+ (NSURLRequest *)GETURLRequest:(NSURL *)url
{
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	req.HTTPMethod = POLHTTPMethodGET;
	req.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	return req;
}

+ (NSMutableURLRequest *)POSTURLRequest:(NSURL *)url
{
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	req.HTTPMethod = POLHTTPMethodPOST;
	req.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	return req;
}

@end
