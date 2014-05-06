//
//  Phrase.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/2/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "Phrase.h"

@implementation Phrase

- (id)initWithStartTime:(CGFloat)startTime {
    self = [super init];
    if (self) {
        _startTime = startTime;
    }
    return self;
}

@end
