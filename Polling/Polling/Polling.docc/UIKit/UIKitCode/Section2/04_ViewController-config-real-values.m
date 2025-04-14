#import "ViewController.h"
#import <Polling/Polling.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    POLPolling.polling.customerID = [NSString stringWithFormat:@"id_%@", @(NSDate.date.timeIntervalSinceReferenceDate)];
    POLPolling.polling.apiKey = @"glKUGJIaXmE40qWpnm5F6lf2UzXjAuh03t9V";
}

- (IBAction)showSurvey:(id)sender {
}

@end
