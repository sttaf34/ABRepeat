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

@interface PhraseAnalyzeOperation ()

@property (nonatomic, strong) MPMediaItem *mediaItem;
@property (weak, nonatomic) id<PhraseAnalyzeOperationDelegate> delegate;

@end

@implementation PhraseAnalyzeOperation

- (instancetype)initWithMediaItem:(MPMediaItem *)mediaItem delegate:(id)delegate {
    self = [super init];
    if (self) {
        _mediaItem = mediaItem;
        _delegate  = delegate;
    }
    return self;
}

- (void)main {
    NSURL *songURL = [self.mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    NSArray *phraseStartTime = [self phraseStartTimeOrNil:songURL];

    if (phraseStartTime) {
        [self.delegate phraseAnalyzeOperationDidFinish:phraseStartTime];
    } else if (!phraseStartTime && !self.isCancelled) {
        [self.delegate phraseAnalyzeOperationDidError];
    }
}

- (NSArray *)phraseStartTimeOrNil:(NSURL *)songURL {
    NSURL *tempPCMFileURL = [self createTempPCMData:songURL];

    if (!tempPCMFileURL || self.isCancelled) return nil;

    NSArray *existenceArray = [self soundExistenceArrayPer10Millisecond:tempPCMFileURL];
    if (!existenceArray || self.isCancelled) return nil;

    [self removeTempFiles];

    NSArray *phraseStartTimes = [self phraseStartTimesFromSoundExistenceArray:existenceArray];
    return phraseStartTimes;
}

- (void)executeDelegateAfterCalculateProgress:(NSInteger)currentCount aboutMaxCount:(NSInteger)abountMaxCount {
    CGFloat progress = (CGFloat)currentCount / abountMaxCount;
    if (progress > 1) progress = 1.0;
    [self.delegate phraseAnalyzeOperationDidChangeProgress:progress];
}

- (NSInteger)aboutMaxLoopCount:(ExtAudioFileRef)audioFileRef {
    UInt64 fileLengthFrames;
    UInt32 size = sizeof(SInt64);
    ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileLengthFrames, &size, &fileLengthFrames);
    return (fileLengthFrames * kTempSoundFileSampleRate / 44100.0) / kTempSoundFileReadFrame;
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
        [self executeDelegateAfterCalculateProgress:++currentLoopCount aboutMaxCount:aboutMaxLoopCount];

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
    if (error) {
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
    error = AudioFileOpenURL((__bridge CFURLRef)PCMFileURL,
                             kAudioFileReadPermission,
                             kAudioFileWAVEType,
                             &audioFileID);
    if (error) goto ERROR_HANDLING;

    error = AudioFileGetProperty(audioFileID,
                                 kAudioFilePropertyAudioDataPacketCount,
                                 &size,
                                 &packetCount);
    if (error) goto ERROR_HANDLING;

ERROR_HANDLING:
    if (error) {
        NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
        AudioFileClose(audioFileID);
        return nil;
    }

    UInt32 ioNumPackets = kSoundExistenceAverageReadPackets;
    short buffer[kSoundExistenceAverageReadPackets] = {0};
    for (int i = 0; i < packetCount; i += kSoundExistenceAverageReadPackets) {
        if (self.isCancelled) {
            AudioFileClose(audioFileID);
            return nil;
        }

        error = AudioFileReadPackets(audioFileID,
                                     NO,
                                     NULL,
                                     NULL,
                                     i,
                                     &ioNumPackets,
                                     &buffer);
        if (error) {
            NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
            AudioFileClose(audioFileID);
            return nil;
        }

        // 読み込んだパケットの平均値の取得
        int sum = 0;
        for (int j = 0; j < ioNumPackets; j++) {
            sum += abs(*(buffer + j));
        }
        int average = sum / kSoundExistenceAverageReadPackets;

        BOOL isSoundExistence = average > kSoundExistenceBoundary;
        [soundExistenceArray addObject:[NSNumber numberWithBool:isSoundExistence]];
    }

    AudioFileClose(audioFileID);
    return soundExistenceArray;
}

- (void)removeTempFiles {
    NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
    [paths enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL *stop) {
        NSString *absolutePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:absolutePath error:nil];
    }];
}

// TODO: 頭出しをどう判定しているかのコメントが必要
// TODO: 頭出し判定を調整出来るようにするかもしれない
static const NSInteger kSoundExistenceJudgeCountNO = 20;
static const NSInteger kSoundExistenceJudgeCountYES = 10;

- (NSArray *)phraseStartTimesFromSoundExistenceArray:(NSArray *)soundExistenceArray {
    NSMutableArray *phraseBeginTimes = [NSMutableArray array];

    for (int i = 0; i < soundExistenceArray.count - kSoundExistenceJudgeCountNO - kSoundExistenceJudgeCountYES; i++) {
        if (self.isCancelled) return nil;

        BOOL isSoundExistence = [(NSNumber *)soundExistenceArray[i] boolValue];
        if (isSoundExistence) continue;

        BOOL isPhraseBeginTime = YES;

        for (int j = 0; j < kSoundExistenceJudgeCountNO; j++) {
            if ([(NSNumber *)soundExistenceArray[i + j] boolValue]) {
                isPhraseBeginTime = NO;
                break;
            }
        }
        if (!isPhraseBeginTime) continue;

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

@end
