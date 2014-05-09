//
//  SongPlayer.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/1/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSUInteger SongPlayerCurrentPlayingIndexStop;

@class Song;
@protocol SongPlayerDelegate;

@interface SongPlayer : NSObject

@property (nonatomic, assign, readonly) NSUInteger playingIndex;

- (id)initWithDelegate:(id)delegate song:(Song *)song;

- (void)playPhraseAtIndex:(NSUInteger)index;
- (void)stop;

- (BOOL)playToggle;
- (BOOL)isPlay;

- (BOOL)repeatToggle;
- (BOOL)isRepeat;

- (void)speedUp;
- (void)speedDown;
- (BOOL)isEnabledSpeedUp;
- (BOOL)isEnabledSpeedDown;
- (NSUInteger)playSpeed;      // 標準スピードならば100を返す

@end

@protocol SongPlayerDelegate <NSObject>

- (void)songPlayerPlayerStop;
- (void)songPlayerChangePhraseAtIndex:(NSUInteger)index;
- (void)songPlayerChangeCurrentTime:(CGFloat)currentTime;

@end
