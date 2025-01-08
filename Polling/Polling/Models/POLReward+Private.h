//
//  POLReward+Private.h
//  Polling
//
//  Created by Eddie Hillenbrand on 1/7/25.
//  Copyright © 2025 Polling.com. All rights reserved.
//

#import <Polling/Polling.h>

NS_ASSUME_NONNULL_BEGIN

@interface POLReward ()

+ (instancetype)rewardFromDictionary:(NSDictionary *)dict;
+ (instancetype)rewardFromJSONDictionary:(NSDictionary *)dict;

- (NSDictionary<NSString *,id> *)dictionaryRepresentation;
- (NSString *)JSONRepresentation;

@end

NS_ASSUME_NONNULL_END
