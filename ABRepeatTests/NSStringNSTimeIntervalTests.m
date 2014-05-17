//
//  NSStringNSTimeIntervalTests.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/17/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+NSTimeInterval.h"

@interface NSStringNSTimeIntervalTests : XCTestCase

@end

@implementation NSStringNSTimeIntervalTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testMinuteSecondStringWithTimeInterval {
    NSDictionary *argAndResult = @{@700:@"11:40", @123:@"02:03", @0:@"00:00", @-3:@"00:00", @12000:@"200:00", };
    [argAndResult enumerateKeysAndObjectsUsingBlock:^(NSNumber *arg, NSString *result, BOOL *stop) {
        XCTAssertEqualObjects(result, [NSString minuteSecondStringWithTimeInterval:arg.doubleValue]);
    }];
}

- (void)testMinuteSecondString10MillisecondWithTimeInterval {
    NSDictionary *argAndResult = @{@701.54:@"11:41:54", @123.0004:@"02:03:00", @-3.0854:@"00:00:00"};
    [argAndResult enumerateKeysAndObjectsUsingBlock:^(NSNumber *arg, NSNumber *result, BOOL *stop) {
        XCTAssertEqualObjects(result, [NSString minuteSecondString10MillisecondWithTimeInterval:arg.doubleValue]);
    }];
}

@end
