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
    int minute = (int)interval / 60;
    int second = (int)interval % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minute, second];
}

+ (NSString *)minuteSecondString10MillisecondWithTimeInterval:(NSTimeInterval)interval {
    int minute = (int)interval / 60;
    int second = (int)interval % 60;
    int a100Milisecond = (int)(interval * 100) % 100;
    return [NSString stringWithFormat:@"%02d:%02d:%02d", minute, second, a100Milisecond];
}

+ (NSString *)minuteSecondX2StringWithTimeIntervalLeft:(NSTimeInterval)left
                                         intervalRight:(NSTimeInterval)right {
    int leftMinute = (int)left / 60;
    int leftSecond = (int)left % 60;
    int rightMinute = (int)right / 60;
    int rightSecond = (int)right % 60;
    return [NSString stringWithFormat:@"%02d:%02d / %02d:%02d", leftMinute, leftSecond, rightMinute, rightSecond];
}

@end
