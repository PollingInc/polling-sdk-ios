/*
 *  ViewController.m
 *  UIKitApp
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "ViewController.h"
#import <Polling/Polling.h>

@interface ViewController () <POLPollingDelegate>

@property (weak, nonatomic) IBOutlet UITextField *surveyUUID;
@property (weak, nonatomic) IBOutlet UIButton *showDialogButton;
@property (weak, nonatomic) IBOutlet UIButton *showBottomButton;

@property (weak, nonatomic) IBOutlet UIButton *embedDialogButton;
@property (weak, nonatomic) IBOutlet UIButton *embedBottomButton;

@property (weak, nonatomic) IBOutlet UITextField *eventName;
@property (weak, nonatomic) IBOutlet UITextField *eventValue;
@property (weak, nonatomic) IBOutlet UIButton *logEventButton;

@end

@implementation ViewController {
	POLPolling *_polling;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	NSString *customerID = [NSString stringWithFormat:@"ios-customer_%@", @(NSDate.date.timeIntervalSinceReferenceDate)];

	_polling = POLPolling.polling;
	_polling.customerID = customerID;
	_polling.apiKey = @"H3uZsrv6B2qyRXGePLxQ9U8g7vilWFTjIhZO";
	_polling.delegate = self;
	_polling.disableCheckingForAvailableSurveys = YES;
}

- (IBAction)showDialog:(id)sender
{
	NSLog(@"(UIKitApp) %s UUID=%@", __func__, self.surveyUUID.text);

	NSString *uuid = self.surveyUUID.text;

	_polling.viewType = POLViewTypeDialog;
	[_polling showSurvey:uuid];
}

- (IBAction)showBottom:(id)sender
{
	NSLog(@"(UIKitApp) %s UUID=%@", __func__, self.surveyUUID.text);

	NSString *uuid = self.surveyUUID.text;

	_polling.viewType = POLViewTypeBottom;
	[_polling showSurvey:uuid];
}

- (IBAction)embedDialog:(id)sender
{
	NSLog(@"(UIKitApp) %s", __func__);
	_polling.viewType = POLViewTypeDialog;
	[_polling showEmbedView];
}

- (IBAction)embedBottom:(id)sender
{
	NSLog(@"(UIKitApp) %s", __func__);
	_polling.viewType = POLViewTypeBottom;
	[_polling showEmbedView];
}

- (IBAction)logEvent:(id)sender
{
	NSLog(@"(UIKitApp) %s eventName=%@, eventValue=%@", __func__, self.eventName.text, self.eventValue.text);

	NSString *event = self.eventName.text;
	NSString *value = self.eventValue.text;

	[_polling logEvent:event value:value];
}

#pragma mark - Polling Delegate Methods

- (void)pollingOnSuccess:(NSString *)response
{
	NSLog(@"SUCCESS (UIKitApp): response=%@", response);
}

- (void)pollingOnFailure:(NSString *)error
{
	NSLog(@"ERROR (UIKitApp): error=%@", error);
}

- (void)pollingOnReward:(POLReward *)reward
{
	NSLog(@"REWARD (UIKitApp): reward=%@", reward);
}

- (void)pollingOnSurveyAvailable
{
	NSLog(@"(UIKitApp) There is a survey available.");
}

@end
