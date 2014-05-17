//
//  NSString+NSTimeInterval.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/15/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSTimeInterval)

+ (NSString *)minuteSecondStringWithTimeInterval:(NSTimeInterval)interval;
+ (NSString *)minuteSecondString10MillisecondWithTimeInterval:(NSTimeInterval)interval;

@end
