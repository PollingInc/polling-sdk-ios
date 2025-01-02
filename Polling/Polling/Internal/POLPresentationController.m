/*
*  POLPresentationController.m
*  Polling
*
*  Copyright © 2024 Polling.com. All rights reserved
*/

#import "POLPresentationController.h"

@implementation POLPresentationController

- (CGRect)frameOfPresentedViewInContainerView
{
	CGRect frame = self.containerView.bounds;
	frame = CGRectInset(frame, 50, 200);
	return frame;
}

@end
