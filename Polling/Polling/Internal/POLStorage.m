/*
 *  POLStorage.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLStorage.h"
#import "POLTriggeredSurvey.h"

NSString * const POLStorageFilename = @"com.polling.PollingUserData.plist";
NSString * const POLStorageTriggeredSurveysKey = @"polling:triggered_surveys";

@interface POLStorage ()
@property (readonly) NSURL *storageURL;
@end

@implementation POLStorage {
	NSMutableDictionary *_storageDict;
}

- init
{
	if (!(self = [super init]))
		return nil;
	_storageDict = NSMutableDictionary.new;
	return self;
}

+ (instancetype)storage
{
	static POLStorage *storage;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		storage = POLStorage.new;
	});
	return storage;
}

- (NSURL *)storageURL
{
	static NSURL *storageURL;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSError *err = nil;
		NSURL *url = [NSFileManager.defaultManager
			URLForDirectory:NSApplicationSupportDirectory
			inDomain:NSUserDomainMask appropriateForURL:nil
			create:YES error:&err];
		if (err) {
			NSLog(@"Error: %@", err);
			// TODO: handle error
		}
		storageURL = [url URLByAppendingPathComponent:POLStorageFilename];
		NSLog(@"polling storage: %@", storageURL);
	});
	return storageURL;
}

- (id)objectForKeyedSubscript:(NSString *)key
{
	return NSObject.new;
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{

}

- (NSArray<POLTriggeredSurvey *> *)triggeredSurveys
{
	NSMutableDictionary *savedSorageDict = [NSMutableDictionary dictionaryWithContentsOfURL:self.storageURL];
	if (savedSorageDict)
		_storageDict = savedSorageDict;

	//NSLog(@"read %@ => %@", self.storageURL, _storageDict);
	NSArray *storedTriggeredSurveys = _storageDict[POLStorageTriggeredSurveysKey];
	if (!storedTriggeredSurveys)
		return @[];

	NSMutableArray<POLTriggeredSurvey *> *triggeredSurveys = [NSMutableArray<POLTriggeredSurvey *> new];
	for (NSDictionary *dict in storedTriggeredSurveys) {
		[triggeredSurveys addObject:[POLTriggeredSurvey triggeredSurveyFromDictionary:dict]];
	}

	return triggeredSurveys;
}

- (void)setTriggeredSurveys:(NSArray<POLTriggeredSurvey *> *)triggeredSurveys
{
	NSError *err = nil;

	NSMutableArray<NSDictionary<NSString *, id> *> *newTriggeredSurveys = NSMutableArray.new;
	for (POLTriggeredSurvey *triggeredSurvey in triggeredSurveys) {
		NSDictionary *dict = triggeredSurvey.dictionaryRepresentation;
		[newTriggeredSurveys addObject:dict];
	}

	_storageDict[POLStorageTriggeredSurveysKey] = newTriggeredSurveys;
	//NSLog(@"write %@ => %@", self.storageURL, _storageDict);

	[_storageDict writeToURL:self.storageURL error:&err];
	if (err) {
		NSLog(@"Error: %s - %@", __func__, err);
	}
}

@end
