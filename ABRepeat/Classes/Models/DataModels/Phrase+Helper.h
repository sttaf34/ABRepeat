//
//  Phrase+Helper.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/8/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "Phrase.h"

@interface Phrase (Helper)

- (NSInteger)startTimeMinute;
- (NSInteger)startTimeSecond;
- (NSInteger)startTime100Millisecond;
- (NSInteger)startTime10Millisecond;

@end
