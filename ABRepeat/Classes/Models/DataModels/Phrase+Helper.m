//
//  Phrase+Helper.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/8/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "Phrase+Helper.h"

@implementation Phrase (Helper)

- (NSInteger)startTimeMinute {
    return (int)self.startTime.floatValue / 60;
}

- (NSInteger)startTimeSecond {
    return (int)self.startTime.floatValue % 60;
}

- (NSInteger)startTime100Millisecond {
    return (NSInteger)(self.startTime.floatValue * 10) % 10;
}

- (NSInteger)startTime10Millisecond {
    return (NSInteger)(self.startTime.floatValue * 100) % 100;
}

@end
