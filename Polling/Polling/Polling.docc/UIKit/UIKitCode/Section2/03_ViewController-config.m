#import "ViewController.h"
#import <Polling/Polling.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    POLPolling.polling.customerID = @"UniqueCustomerIDProvidedByYou";
    POLPolling.polling.apiKey = @"EmbedAPIKeyFromPolling.com";
}

- (IBAction)showSurvey:(id)sender {
}

@end
