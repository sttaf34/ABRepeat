//
//  NSString+NSTimeInterval.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/15/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "NSString+NSTimeInterval.h"

@implementation NSString (NSTimeInterval)

+ (NSString *)minuteSecondStringWithTimeInterval:(NSTimeInterval)interval {
    if (interval < 0) return @"00:00";
    int minute = (int)interval / 60;
    int second = (int)interval % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minute, second];
}

+ (NSString *)minuteSecondString10MillisecondWithTimeInterval:(NSTimeInterval)interval {
    if (interval < 0) return @"00:00:00";
    NSString *minuteSecond = [[self class] minuteSecondStringWithTimeInterval:interval];
    int a100Milisecond = (int)(interval * 100) % 100;
    return [NSString stringWithFormat:@"%@:%02d", minuteSecond, a100Milisecond];
}

@end
