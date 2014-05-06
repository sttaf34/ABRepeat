//
//  SongController.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/1/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSUInteger SongControllerCurrentPlayingIndexStop;

@protocol SongControllerDelegate;

@interface SongController : NSObject

@property (nonatomic, strong, readonly) NSArray *phrases;
@property (nonatomic, assign, readonly) NSUInteger playingIndex;

- (id)initWithDelegate:(id)delegate songURL:(NSURL *)URL;
- (void)startSongAnalyze;

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

@protocol SongControllerDelegate <NSObject>

- (void)songControllerPlayerStop;
- (void)songControllerChangePhraseAtIndex:(NSUInteger)index;

@end
