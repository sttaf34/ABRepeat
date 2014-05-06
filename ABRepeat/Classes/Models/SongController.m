//
//  SongController.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/1/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "SongController.h"
#import <AVFoundation/AVFoundation.h>
#import "PhraseAnalyzer.h"
#import "Phrase.h"

const NSUInteger SongControllerCurrentPlayingIndexStop = NSUIntegerMax;
const CGFloat kPlaySpeedMin = 0.8;
const CGFloat kPlaySpeedMax = 1.5;
const CGFloat kPlaySpeedDistance = 0.1;

@interface SongController () <AVAudioPlayerDelegate>

@property (nonatomic, weak) id<SongControllerDelegate> delegate;
@property (nonatomic, strong) NSURL *songURL;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong, readwrite) NSArray *phrases;
@property (nonatomic, assign, readwrite) NSUInteger playingIndex;

@end

@implementation SongController

- (id)initWithDelegate:(id)delegate songURL:(NSURL *)songURL {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _songURL = songURL;
        _playingIndex = SongControllerCurrentPlayingIndexStop;

        NSError *error;
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:songURL error:&error];
        if (error) return nil;
        _player.delegate = self;
        _player.numberOfLoops = 0;
        _player.enableRate = YES;
    }
    return self;
}

- (void)dealloc {
    [self.timer invalidate];
}

- (void)startSongAnalyze {
    PhraseAnalyzer *analyzer = [[PhraseAnalyzer alloc] init];
    self.phrases = [analyzer phrasesFromSongURL:self.songURL];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01f
                                                  target:self
                                                selector:@selector(checkPlayingIndex)
                                                userInfo:nil
                                                 repeats:YES];
}

#pragma mark - Player

- (void)playPhraseAtIndex:(NSUInteger)index {
    Phrase *phrase = self.phrases[index];
    self.player.currentTime = phrase.startTime;
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
    return (NSUInteger)(self.player.rate * 100);
}

#pragma mark - Timer

- (void)checkPlayingIndex {
    NSUInteger currentPlayingIndex = SongControllerCurrentPlayingIndexStop;

    if (self.player.playing) {
        CGFloat currentTime = self.player.currentTime;
        for (int i = 0; i < self.phrases.count; i++) {
            Phrase *phrase = (Phrase *)self.phrases[i];
            if (currentTime >= phrase.startTime) {
                currentPlayingIndex = i;
            }
        }
    }

    if (self.playingIndex == currentPlayingIndex) {
        return;
    } else {
        self.playingIndex = currentPlayingIndex;
        [self.delegate songControllerChangePhraseAtIndex:self.playingIndex];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.delegate songControllerPlayerStop];
}

@end
