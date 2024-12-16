/*
 *  ViewController.m
 *  UIKitApp
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "ViewController.h"
#import <Polling/Polling.h>

@interface ViewController () <POLPollingDelegate>

@property (weak, nonatomic) IBOutlet UIButton *showSurveyButton;

@end

@implementation ViewController {
	POLPolling *_polling;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	//_polling = [[POLPolling alloc] initWithCustomerID:@"ios-sdk-test-customer_00000"
	_polling = [[POLPolling alloc]
				initWithCustomerID:@"test-customer_00000"
				APIKey:@"H3uZsrv6B2qyRXGePLxQ9U8g7vilWFTjIhZO"];
	_polling.delegate = self;
}

#pragma mark - Polling Delegate Methods

- (void)surveyDidOpen:(POLSurvey *)survey
{
	NSLog(@"%s", __func__);
}

- (void)surveyDidDismiss:(POLSurvey *)survey
{
	NSLog(@"%s", __func__);
}

- (void)surveyDidPostpone:(POLSurvey *)survey
{
	NSLog(@"%s", __func__);
}

- (void)surveyDidComplete:(POLSurvey *)survey
{
	NSLog(@"%s", __func__);
}

- (void)surveyDidSucceed:(POLSurvey *)survey
{
	NSLog(@"%s", __func__);
}

- (void)surveyDidFail:(POLSurvey *)survey
{
	NSLog(@"%s", __func__);
}


- (void)survey:(POLSurvey *)survey didReward:(POLReward *)reward
{
	NSLog(@"%s", __func__);
}


- (void)pollingSurveyDidBecomeAvailable
{
	NSLog(@"%s", __func__);
}

- (IBAction)showSurvey:(id)sender
{
	NSLog(@"%s", __func__);

	[_polling presentSurvey:POLSurvey.new];
}

@end
