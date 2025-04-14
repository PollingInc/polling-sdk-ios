#import "ViewController.h"
#import <Polling/Polling.h>

@interface ViewController () <POLPollingDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    POLPolling.polling.customerID = [NSString stringWithFormat:@"id_%@", @(NSDate.date.timeIntervalSinceReferenceDate)];
    POLPolling.polling.apiKey = @"glKUGJIaXmE40qWpnm5F6lf2UzXjAuh03t9V";
    POLPolling.polling.delegate = self;
}

- (IBAction)showSurvey:(id)sender {
    [POLPolling.polling showSurvey:@"da7c0197-6495-45d7-8354-672dbe1eff75"];
}

#pragma mark - Polling Delegate Methods

- (void)pollingOnSuccess:(NSString *)response {
    NSLog(@"SUCCESS: response=%@", response);
}

- (void)pollingOnFailure:(NSString *)error {
    NSLog(@"ERROR: error=%@", error);
}

- (void)pollingOnReward:(POLReward *)reward {
    NSLog(@"REWARD: reward=%@", reward);
}

- (void)pollingOnSurveyAvailable {
    NSLog(@"AVAILABLE: Survey available");
}

@end
