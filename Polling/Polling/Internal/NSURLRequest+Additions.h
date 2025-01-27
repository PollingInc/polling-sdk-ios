//
//  NSURLRequest+Additions.h
//  Polling
//
//  Created by Eddie Hillenbrand on 1/26/25.
//  Copyright © 2025 Polling.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (POLURLRequestAdditions)
+ (NSURLRequest *)GETURLRequest:(NSURL *)url;
+ (NSMutableURLRequest *)POSTURLRequest:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
