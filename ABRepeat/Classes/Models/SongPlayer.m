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
#import "SongPlayerSettingStore.h"

const NSUInteger SongPlayerCurrentPlayingIndexStop = NSUIntegerMax;
const CGFloat kPlaySpeedMin = 0.5;
const CGFloat kPlaySpeedMax = 2.5;
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
        _player.enableRate = YES;
        _player.rate = [SongPlayerSettingStore rate];
        _player.numberOfLoops = [SongPlayerSettingStore numberOfLoops];


        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeCallback:)
                                                     name:AVAudioSessionRouteChangeNotification object:nil];

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.checkCurrentTimeTimer invalidate];
    [self.checkPlayingIndexTimer invalidate];
}

#pragma mark - PlayerControl

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

#pragma mark - Repeat

- (BOOL)repeatToggle {
    self.player.numberOfLoops = -1 - self.player.numberOfLoops;
    [SongPlayerSettingStore setNumberOfLoops:self.player.numberOfLoops];
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
    [SongPlayerSettingStore setRate:self.player.rate];
}

- (void)speedDown {
    self.player.rate -= kPlaySpeedDistance;
    self.player.rate = (self.player.rate < kPlaySpeedMin) ? kPlaySpeedMin : self.player.rate;
    [SongPlayerSettingStore setRate:self.player.rate];
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
    int currentMinute = (int)self.player.currentTime / 60;
    int currentSecond = (int)self.player.currentTime % 60;
    int totalMinute   = (int)self.player.duration / 60;
    int totalSecond   = (int)self.player.duration % 60;
    NSString *time = [NSString stringWithFormat:@"%02d:%02d / %02d:%02d", currentMinute, currentSecond, totalMinute, totalSecond];
    [self.delegate songPlayerChangeTIme:time];
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

#pragma mark - 

- (void)audioRouteChangeCallback:(NSNotification *)notification {
    NSInteger routeChangeReason = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            [self.player pause];
            break;
        default:
            break;
    }
}

@end
