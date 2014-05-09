//
//  Song+Helper.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/7/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "Song.h"

@interface Song (Helper)

- (NSURL *)URL;
- (NSArray *)sortedPhrases;

@end
