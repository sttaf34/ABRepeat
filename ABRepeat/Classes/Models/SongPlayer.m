//
//  SongPlayer.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/1/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "SongPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "Phrase.h"
#import "Song+Helper.h"

const NSUInteger SongPlayerCurrentPlayingIndexStop = NSUIntegerMax;
const CGFloat kPlaySpeedMin = 0.8;
const CGFloat kPlaySpeedMax = 1.5;
const CGFloat kPlaySpeedDistance = 0.1;

@interface SongPlayer () <AVAudioPlayerDelegate>

@property (nonatomic, weak) id<SongPlayerDelegate> delegate;
@property (nonatomic, strong) Song *song;
@property (nonatomic, strong) NSArray *phrases;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign, readwrite) NSUInteger playingIndex;

@property (nonatomic, strong) NSTimer *checkCurrentTimeTimer;
@property (nonatomic, strong) NSTimer *checkPlayingIndexTimer;

@end

@implementation SongPlayer

- (id)initWithDelegate:(id)delegate song:(Song *)song {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _song     = song;
        _phrases  = song.sortedPhrases;
        _playingIndex = SongPlayerCurrentPlayingIndexStop;

        NSError *error;
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:song.URL error:&error];
        if (error) return nil;
        _player.delegate = self;
        _player.numberOfLoops = 0;
        _player.enableRate = YES;

        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];

        self.checkCurrentTimeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                                      target:self
                                                                    selector:@selector(checkCurrentTime)
                                                                    userInfo:nil
                                                                     repeats:YES];

        self.checkPlayingIndexTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                                       target:self
                                                                     selector:@selector(checkPlayingIndex)
                                                                     userInfo:nil
                                                                      repeats:YES];
    }
    return self;
}

- (void)dealloc {
    [self.checkCurrentTimeTimer invalidate];
    [self.checkPlayingIndexTimer invalidate];
}

#pragma mark - Player

- (void)playPhraseAtIndex:(NSUInteger)index {
    Phrase *phrase = self.song.sortedPhrases[index];
    self.player.currentTime = phrase.startTime.floatValue;
    [self.player play];
}

- (void)stop {
    [self.player stop];
}

- (BOOL)playToggle {
    if (self.isPlay) {
        [self stop];
    } else {
        [self.player play];
    }
    return self.isPlay;
}

- (BOOL)isPlay {
    return self.player.playing;
}

- (BOOL)repeatToggle {
    self.player.numberOfLoops = -1 - self.player.numberOfLoops;
    return [self isRepeat];
}

- (BOOL)isRepeat {
    if (self.player.numberOfLoops == 0) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Speed

- (void)speedUp {
    self.player.rate += kPlaySpeedDistance;
    self.player.rate = (self.player.rate > kPlaySpeedMax) ? kPlaySpeedMax : self.player.rate;
}

- (void)speedDown {
    self.player.rate -= kPlaySpeedDistance;
    self.player.rate = (self.player.rate < kPlaySpeedMin) ? kPlaySpeedMin : self.player.rate;
}

- (BOOL)isEnabledSpeedUp {
    return (self.player.rate < kPlaySpeedMax);
}

- (BOOL)isEnabledSpeedDown {
    return (self.player.rate > kPlaySpeedMin);
}

- (NSUInteger)playSpeed {
    return (NSUInteger)roundf(self.player.rate * 100);
}

#pragma mark - Timer

- (void)checkCurrentTime {
    [self.delegate songPlayerChangeCurrentTime:self.player.currentTime];
}

- (void)checkPlayingIndex {
    NSUInteger currentPlayingIndex = SongPlayerCurrentPlayingIndexStop;

    if (self.player.playing) {
        CGFloat currentTime = self.player.currentTime;
        for (int i = 0; i < self.phrases.count; i++) {
            Phrase *phrase = (Phrase *)self.phrases[i];
            if (currentTime >= phrase.startTime.floatValue) {
                currentPlayingIndex = i;
            }
        }
    }

    if (self.playingIndex == currentPlayingIndex) {
        return;
    } else {
        self.playingIndex = currentPlayingIndex;
        [self.delegate songPlayerChangePhraseAtIndex:self.playingIndex];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.delegate songPlayerPlayerStop];
}

@end
