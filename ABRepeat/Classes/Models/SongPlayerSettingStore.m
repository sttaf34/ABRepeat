//
//  SongPlayerSettingStore.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/11/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "SongPlayerSettingStore.h"

static NSString *const kKeyRate = @"rate";
static NSString *const kKeyNumberOfLoops = @"numberOfLoops";

@implementation SongPlayerSettingStore

+ (void)setRate:(CGFloat)rate {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:rate forKey:kKeyRate];
    [userDefaults synchronize];
}

+ (CGFloat)rate {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{kKeyRate: @1.0}];
    return [userDefaults floatForKey:kKeyRate];
}

+ (void)setNumberOfLoops:(NSInteger)numberOfLoops {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:numberOfLoops forKey:kKeyNumberOfLoops];
    [userDefaults synchronize];
}

+ (NSInteger)numberOfLoops {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{kKeyNumberOfLoops: @-1}];
    return [userDefaults integerForKey:kKeyNumberOfLoops];
}

@end
