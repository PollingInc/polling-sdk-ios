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
