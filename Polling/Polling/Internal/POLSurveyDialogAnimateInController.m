/*
 *  POLSurveyDialogAnimateInController.m
 *  Polling
 *
 *  Copyright © 2025 Polling.com. All rights reserved.
 */

#import "POLSurveyDialogAnimateInController.h"
#import "POLSurveyViewController.h"
#import "POLPolling+Private.h"

@implementation POLSurveyDialogAnimateInController

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext
{
	UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
	UIView *containerView = transitionContext.containerView;

	POLLogTrace("toVC=%@", toVC);
	POLLogTrace("toView=%@", toView);
	POLLogTrace("containerView=%@", containerView);

#if DEBUG
	UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
	POLLogTrace("fromVC=%@", fromVC);
	POLLogTrace("fromView=%@", fromView);
#endif

	if ([toVC isKindOfClass:POLSurveyViewController.class]) {
		POLSurveyViewController *vc = (POLSurveyViewController *)toVC;
		UIView *toContainerView = vc.containerView;
		NSTimeInterval duration = [self transitionDuration:transitionContext];
		CGAffineTransform startAF = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
		CGAffineTransform finalAF = CGAffineTransformIdentity;

		toView.frame = containerView.frame;
		[containerView addSubview:toView];

		POLLogTrace("%@ beginAnimation toContainerView=%@, duration=%G", NSStringFromClass(self.class), toContainerView, duration);
		[UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
			POLLogTrace("%@ %p animations[", NSStringFromClass(self.class), self);
			[UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0 animations:^{
				POLLogTrace("    initial %p,", self);
				toView.alpha = 0.0;
				toContainerView.transform = startAF;
			}];
			[UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
				POLLogTrace("    half %p,", self);
				toView.alpha = 1.0;
			}];
			[UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
				POLLogTrace("    final %p", self);
				toContainerView.transform = finalAF;
			}];
		} completion:^(BOOL finished) {
			POLLogTrace("] %@ %p endAnimation finished=%{BOOL}d", NSStringFromClass(self.class), self, finished);
			[transitionContext completeTransition:YES]; // TODO: check for canceled?
		}];
	}
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext
{
	return 1;
}

@end
