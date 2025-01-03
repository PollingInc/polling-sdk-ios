/*
 *  POLStorage.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLStorage.h"
#import "POLSurvey.h"
#import "POLSurvey+Private.h"
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
	NSLog(@"POLStorage location: %@", self.storageURL);
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

- (void)read
{
	NSLog(@"POLStorage reading: %@", POLStorageFilename);
	NSMutableDictionary *savedSorageDict = [NSMutableDictionary dictionaryWithContentsOfURL:self.storageURL];
	if (savedSorageDict)
		_storageDict = savedSorageDict;
}

- (void)write
{
	NSError *err = nil;

	NSLog(@"POLStorage writing: %@", POLStorageFilename);
	[_storageDict writeToURL:self.storageURL error:&err];
	if (err) {
		NSLog(@"Error: %s - %@", __func__, err);
	}
}

- (NSArray<POLTriggeredSurvey *> *)triggeredSurveys
{
	NSArray *storedTriggeredSurveys = _storageDict[POLStorageTriggeredSurveysKey];
	if (!storedTriggeredSurveys)
		return @[];

	NSMutableArray<POLTriggeredSurvey *> *triggeredSurveys = NSMutableArray.new;
	for (NSDictionary *dict in storedTriggeredSurveys) {
		[triggeredSurveys addObject:[POLTriggeredSurvey triggeredSurveyFromDictionary:dict]];
	}

	return triggeredSurveys;
}

- (void)setTriggeredSurveys:(NSArray<POLTriggeredSurvey *> *)triggeredSurveys
{
	NSMutableArray<NSDictionary<NSString *, id> *> *newTriggeredSurveys = NSMutableArray.new;
	for (POLTriggeredSurvey *triggeredSurvey in triggeredSurveys) {
		NSDictionary *dict = triggeredSurvey.dictionaryRepresentation;
		[newTriggeredSurveys addObject:dict];
	}
	_storageDict[POLStorageTriggeredSurveysKey] = newTriggeredSurveys;
}

- (void)removeTriggeredSurvey:(POLTriggeredSurvey *)triggeredSurvey
{
	/* this conveniently removes duplicates */
	NSArray<POLTriggeredSurvey *> *triggeredSurveys = self.triggeredSurveys;
	NSString *uuid = triggeredSurvey.survey.UUID;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"survey.UUID != %@", uuid];
	triggeredSurveys = [triggeredSurveys filteredArrayUsingPredicate:predicate];
	self.triggeredSurveys = triggeredSurveys;
}

- (void)modifiedTriggeredSurvey:(POLTriggeredSurvey *)triggeredSurvey
{
	/* since equality is defined as t1.survey.UUID == t2.survey.UUID */
	[self removeTriggeredSurvey:triggeredSurvey];
	self.triggeredSurveys = [self.triggeredSurveys arrayByAddingObject:triggeredSurvey];
}

@end
