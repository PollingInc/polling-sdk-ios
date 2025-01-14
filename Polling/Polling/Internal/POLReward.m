/*
 *  POLReward.m
 *  Polling
 *
 *  Copyright © 2024 Polling.com. All rights reserved
 */

#import "POLReward.h"
#import "POLReward+Private.h"

@implementation POLReward

- initWithDictionary:(NSDictionary *)dict
{
	if (!(self = super.init))
		return nil;

	_name = dict[@"name"];
	_amount = dict[@"amount"];
	_completeExtraJSON = dict[@"completeExtraJSON"];

	return self;
}

- initWithJSONDictionary:(NSDictionary *)dict
{
	if (!(self = super.init))
		return nil;

	_name = dict[@"reward_name"];
	_amount = dict[@"reward_amount"];
	_completeExtraJSON = dict[@"complete_extra_json"];

	return self;
}

+ (instancetype)rewardFromDictionary:(NSDictionary *)dict
{
	return [self.class.alloc initWithDictionary:dict];
}

+ (instancetype)rewardFromJSONDictionary:(NSDictionary *)dict
{
	return [self.class.alloc initWithJSONDictionary:dict];
}

- (NSDictionary<NSString *,id> *)dictionaryRepresentation
{
	return @{
		@"name": self.name,
		@"amount": self.amount,
		@"completeExtraJSON": self.completeExtraJSON,
	};
}

- (NSString *)JSONRepresentation
{
	NSDictionary *dict = @{
		@"reward_name": self.name,
		@"reward_amount": self.amount,
	};
	NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
	return [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p name='%@', amount=%@>",
			NSStringFromClass(self.class),
			self,
			self.name,
			self.amount
	];
}

@end
