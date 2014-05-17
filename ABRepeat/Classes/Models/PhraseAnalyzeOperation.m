//
//  PhraseAnalyzeOperation.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/7/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "PhraseAnalyzeOperation.h"
#import <AudioToolbox/AudioToolbox.h>

static const NSInteger kTempSoundFileSampleRate = 10000;
static const NSInteger kTempSoundFileReadFrame = 4096;
static const NSInteger kSoundExistenceBoundary = 100;
static const NSInteger kSoundExistenceAverageReadPackets = 100;
static const NSInteger k1SecondResolution = kTempSoundFileSampleRate / kSoundExistenceAverageReadPackets;

// それぞれのメソッド終了後の進行状況の値
static const CGFloat kProgressAfterCreateTempPCM = 0.5;
static const CGFloat kProgressAfterSoundExistenceArray = 0.9;
static const CGFloat kProgressAfterPhraseStartTimes = 1.0;

// それぞれのメソッドの進行状況通知の頻度
static const NSInteger kProgressFrequencySoundExistenceArray = 5000;
static const NSInteger kProgressFrequencyPhraseStartTimes = 100;

typedef NS_ENUM(NSInteger, CurrentWorking) {
    CurrentWorkingCreateTempPCM,
    CurrentWorkingSoundExistenceArray,
    CurrentWorkingRemoveTempFiles,
    CurrentWorkingPhraseStartTimes,
};

@interface PhraseAnalyzeOperation ()

@property (nonatomic, strong) NSURL *URL;
@property (weak, nonatomic) id<PhraseAnalyzeOperationDelegate> delegate;

@end

@implementation PhraseAnalyzeOperation

- (instancetype)initWithURL:(NSURL *)URL delegate:(id)delegate {
    self = [super init];
    if (self) {
        _URL       = URL;
        _delegate  = delegate;
    }
    return self;
}

- (void)main {
    NSURL *tempPCMFileURL = [self createTempPCMData:self.URL];
    if (!tempPCMFileURL) {
        [self executeDelegateErrorOrCancel];
        return;
    }

    NSArray *existenceArray = [self soundExistenceArrayPer10Millisecond:tempPCMFileURL];
    if (!existenceArray) {
        [self executeDelegateErrorOrCancel];
        return;
    }
    [self removeTempFiles];

    NSArray *phraseStartTimes = [self phraseStartTimesFromSoundExistenceArray:existenceArray];
    if (!phraseStartTimes) {
        [self executeDelegateErrorOrCancel];
        return;
    }
    [self.delegate phraseAnalyzeOperationDidFinish:phraseStartTimes];
}

#pragma mark - Subroutine from main

- (void)executeDelegateErrorOrCancel {
    if (self.isCancelled) {
        [self.delegate phraseAnalyzeOperationDidCancel];
    } else {
        [self.delegate phraseAnalyzeOperationDidError];
    }
}

- (NSURL *)createTempPCMData:(NSURL *)songURL {
    NSURL *tempFileURL = [self tempWAVFileURL];
    AudioStreamBasicDescription outputFormat = [self tempWAVFileFormat];
    OSStatus error;
    ExtAudioFileRef infile, outfile = NULL;

    // AudioBufferListの作成
    UInt32 readFrameSize = kTempSoundFileReadFrame;
    UInt32 bufferSize = sizeof(char) * readFrameSize * outputFormat.mBytesPerPacket;
    char *buffer = malloc(bufferSize);
    AudioBufferList audioBufferList;
    audioBufferList.mNumberBuffers = 1;
    audioBufferList.mBuffers[0].mNumberChannels = outputFormat.mChannelsPerFrame;
    audioBufferList.mBuffers[0].mDataByteSize = bufferSize;
    audioBufferList.mBuffers[0].mData = buffer;

    error = ExtAudioFileOpenURL((__bridge CFURLRef)songURL, &infile);
    if (error) goto ERROR_HANDLING;
    error = ExtAudioFileSetProperty(infile, kExtAudioFileProperty_ClientDataFormat, sizeof(AudioStreamBasicDescription), &outputFormat);
    if (error) goto ERROR_HANDLING;
    error = ExtAudioFileCreateWithURL((__bridge CFURLRef)tempFileURL, kAudioFileWAVEType, &outputFormat, NULL, kAudioFileFlags_EraseFile, &outfile);
    if (error) goto ERROR_HANDLING;

    NSInteger aboutMaxLoopCount = [self aboutMaxLoopCount:infile];
    NSInteger currentLoopCount = 0;
    while (1) {
        if (self.isCancelled) break;
        [self executeDelegateAfterCalculateProgress:++currentLoopCount aboutMaxCount:aboutMaxLoopCount currentWorking:CurrentWorkingCreateTempPCM];

        error = ExtAudioFileRead(infile, &readFrameSize, &audioBufferList);
        if (error) goto ERROR_HANDLING;
        if (readFrameSize == 0) break;
        error = ExtAudioFileWrite(outfile, readFrameSize, &audioBufferList);
        if (error) goto ERROR_HANDLING;
    }

ERROR_HANDLING:
    ExtAudioFileDispose(infile);
    ExtAudioFileDispose(outfile);
    free(buffer);
    if (error || self.isCancelled) {
        return nil;
    } else {
        return tempFileURL;
    }
}

- (NSArray *)soundExistenceArrayPer10Millisecond:(NSURL *)PCMFileURL {
    NSMutableArray *soundExistenceArray = [NSMutableArray array];
    OSStatus error;
    UInt64 packetCount = 0;
    UInt32 size = sizeof(UInt64);
    AudioFileID audioFileID = NULL;

    error = AudioFileOpenURL((__bridge CFURLRef)PCMFileURL, kAudioFileReadPermission, kAudioFileWAVEType, &audioFileID);
    if (error) goto ERROR_AND_CANCEL_HANDLING;
    error = AudioFileGetProperty(audioFileID, kAudioFilePropertyAudioDataPacketCount, &size, &packetCount);
    if (error) goto ERROR_AND_CANCEL_HANDLING;

    UInt32 ioNumPackets = kSoundExistenceAverageReadPackets;
    short buffer[kSoundExistenceAverageReadPackets] = {0};
    NSLog(@"%s loopCount -> %d", __PRETTY_FUNCTION__, (int)packetCount);
    for (int i = 0; i < packetCount; i += kSoundExistenceAverageReadPackets) {
        if (self.isCancelled) goto ERROR_AND_CANCEL_HANDLING;
        if (i % kProgressFrequencySoundExistenceArray == 0) {
            [self executeDelegateAfterCalculateProgress:i aboutMaxCount:(NSInteger)packetCount - 1
                                         currentWorking:CurrentWorkingSoundExistenceArray];
        }

        error = AudioFileReadPackets(audioFileID, NO, NULL, NULL, i, &ioNumPackets, &buffer);
        if (error) goto ERROR_AND_CANCEL_HANDLING;

        // 読み込んだパケットの平均値を取得し、音が鳴っているかを判別
        int sum = 0;
        for (int j = 0; j < ioNumPackets; j++) {
            sum += abs(*(buffer + j));
        }
        int average = sum / kSoundExistenceAverageReadPackets;
        BOOL isSoundExistence = average > kSoundExistenceBoundary;
        [soundExistenceArray addObject:[NSNumber numberWithBool:isSoundExistence]];
    }

ERROR_AND_CANCEL_HANDLING:
    AudioFileClose(audioFileID);
    if (error || self.isCancelled) {
        return nil;
    } else {
        return soundExistenceArray;
    }
}

- (void)removeTempFiles {
    NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
    [paths enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL *stop) {
        NSString *absolutePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:absolutePath error:nil];
    }];
}

static const NSInteger kSoundExistenceJudgeCountNO = 20;
static const NSInteger kSoundExistenceJudgeCountYES = 10;

- (NSArray *)phraseStartTimesFromSoundExistenceArray:(NSArray *)soundExistenceArray {
    NSMutableArray *phraseBeginTimes = [NSMutableArray array];

    // soundExistenceArray[i]の値を見て
    // NOがkSoundExistenceJudgeCountNO個、YESがkSoundExistenceJudgeCountYES個並んだ場合の時間を
    // phraseBeginTimeとしている
    NSInteger loopCount = soundExistenceArray.count - kSoundExistenceJudgeCountNO - kSoundExistenceJudgeCountYES;
    NSLog(@"%s loopCount -> %d", __PRETTY_FUNCTION__, (int)loopCount);
    for (int i = 0; i < loopCount; i++) {
        if (self.isCancelled) return nil;
        if (i % kProgressFrequencyPhraseStartTimes == 0) {
            [self executeDelegateAfterCalculateProgress:i aboutMaxCount:loopCount - 1
                                         currentWorking:CurrentWorkingPhraseStartTimes];
        }

        BOOL isSoundExistence = [(NSNumber *)soundExistenceArray[i] boolValue];
        if (isSoundExistence) continue;

        // NOがkSoundExistenceJudgeCountNO個並んでいるかチェック
        BOOL isPhraseBeginTime = YES;
        for (int j = 0; j < kSoundExistenceJudgeCountNO; j++) {
            if ([(NSNumber *)soundExistenceArray[i + j] boolValue]) {
                isPhraseBeginTime = NO;
                break;
            }
        }
        if (!isPhraseBeginTime) continue;

        // YESがkSoundExistenceJudgeCountYES個並んでいるかチェック
        for (int j = kSoundExistenceJudgeCountNO; j < kSoundExistenceJudgeCountNO + kSoundExistenceJudgeCountYES; j++) {
            if (![(NSNumber *)soundExistenceArray[i + j] boolValue]) {
                isPhraseBeginTime = NO;
                break;
            }
        }

        if (isPhraseBeginTime) {
            int second   = i / k1SecondResolution;
            int sssecond = i % k1SecondResolution;
            float phraseBeginTime = second + (float)sssecond / k1SecondResolution;
            [phraseBeginTimes addObject:[NSNumber numberWithFloat:phraseBeginTime]];
        }
    }
    return [phraseBeginTimes copy];
}

#pragma mark - Helper

- (NSURL *)tempWAVFileURL {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    NSString *fileName = [NSString stringWithFormat:@"%@.wav", [dateFormatter stringFromDate:[NSDate date]]];
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
}

- (AudioStreamBasicDescription)tempWAVFileFormat {
    AudioStreamBasicDescription format;
    format.mFormatID          = kAudioFormatLinearPCM;
    format.mFormatFlags	      = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    format.mSampleRate        = kTempSoundFileSampleRate;
    format.mFramesPerPacket	  = 1;
    format.mChannelsPerFrame  = 1;
    format.mBitsPerChannel    = 16;
    format.mBytesPerPacket    = 2;
    format.mBytesPerFrame     = 2;
    format.mReserved          = 0;
    return format;
}

- (void)executeDelegateAfterCalculateProgress:(NSInteger)currentCount
                                aboutMaxCount:(NSInteger)abountMaxCount
                               currentWorking:(CurrentWorking)currentWorking {
    CGFloat ratio = (CGFloat)currentCount / abountMaxCount;
    CGFloat progress;
    switch (currentWorking) {
        case CurrentWorkingCreateTempPCM:
            progress = ratio * kProgressAfterCreateTempPCM;
            break;
        case CurrentWorkingSoundExistenceArray:
            progress = ratio * (kProgressAfterSoundExistenceArray - kProgressAfterCreateTempPCM) + kProgressAfterCreateTempPCM;
            break;
        case CurrentWorkingRemoveTempFiles:
            break;
        case CurrentWorkingPhraseStartTimes:
            progress = ratio * (kProgressAfterPhraseStartTimes - kProgressAfterSoundExistenceArray) + kProgressAfterSoundExistenceArray;
    }
    [self.delegate phraseAnalyzeOperationDidChangeProgress:progress];
}

- (NSInteger)aboutMaxLoopCount:(ExtAudioFileRef)audioFileRef {
    UInt64 fileLengthFrames;
    UInt32 size = sizeof(SInt64);
    ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileLengthFrames, &size, &fileLengthFrames);
    return (fileLengthFrames * kTempSoundFileSampleRate / 44100.0) / kTempSoundFileReadFrame;
}

@end
