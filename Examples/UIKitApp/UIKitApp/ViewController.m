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

@property (weak, nonatomic) IBOutlet UITextField *surveyUUID;
@property (weak, nonatomic) IBOutlet UIButton *showDialogButton;
@property (weak, nonatomic) IBOutlet UIButton *showBottomButton;

@property (weak, nonatomic) IBOutlet UITextField *eventName;
@property (weak, nonatomic) IBOutlet UITextField *eventValue;
@property (weak, nonatomic) IBOutlet UIButton *logEventButton;

@end

@implementation ViewController {
	POLPolling *_polling;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	//_polling = [[POLPolling alloc] initWithCustomerID:@"ios-sdk-test-customer_00000"
	//			APIKey:@"H3uZsrv6B2qyRXGePLxQ9U8g7vilWFTjIhZO"];

	//_polling = POLPolling.polling;
	//_polling.customerID = @"ios-sdk-test-customer_00000";
	//_polling.apiKey = @"H3uZsrv6B2qyRXGePLxQ9U8g7vilWFTjIhZO";

	_polling = POLPolling.polling;
	[_polling initializeWithCustomerID:@"ios-sdk-test-customer_00000" APIKey:@"H3uZsrv6B2qyRXGePLxQ9U8g7vilWFTjIhZO"];
	_polling.delegate = self;
	_polling.disableCheckingForAvailableSurveys = YES;
}

- (IBAction)showDialog:(id)sender
{
	NSLog(@"%s", __func__);
	[_polling setViewType:POLViewTypeDialog];
	[_polling showSurvey:self.surveyUUID.text];
}

- (IBAction)showBottom:(id)sender
{
	NSLog(@"%s", __func__);
	[_polling setViewType:POLViewTypeBottom];
	[_polling showSurvey:self.surveyUUID.text];
}

- (IBAction)logEvent:(id)sender
{
	NSLog(@"%s", __func__);

	NSString *event = self.eventName.text;
	NSString *value = self.eventValue.text;

	[_polling logEvent:event value:value];
}

#pragma mark - Polling Delegate Methods

- (void)pollingOnSuccess:(NSString *)response
{
	NSLog(@"%s response=%@", __func__, response);
}

- (void)pollingOnFailure:(NSString *)error
{
	NSLog(@"%s error=%@", __func__, error);
}

- (void)pollingOnReward:(POLReward *)reward
{
	NSLog(@"%s reward=%@", __func__, reward);
}

- (void)pollingOnSurveyAvailable
{
	NSLog(@"%s", __func__);
}




@end
