//
//  SongPlayerSettingStore.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/11/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongPlayerSettingStore : NSObject

+ (void)setRate:(CGFloat)rate;
+ (CGFloat)rate;

+ (void)setNumberOfLoops:(NSInteger)numberOfLoops;
+ (NSInteger)numberOfLoops;

@end
