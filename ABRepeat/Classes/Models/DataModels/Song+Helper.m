//
//  Song+Helper.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/7/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "Song+Helper.h"

@implementation Song (Helper)

- (NSURL *)URL {
    return [NSURL URLWithString:self.songURL];
}

- (NSArray *)sortedPhrases {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startTime.floatValue" ascending:YES];
    return [self.phrases.allObjects sortedArrayUsingDescriptors:@[sortDescriptor]];
}

@end
