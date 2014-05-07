//
//  PhraseAnalyzeOperation.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/7/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "PhraseAnalyzeOperation.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Phrase.h"

static const NSInteger kTempSoundFileSampleRate = 10000;
static const NSInteger kTempSoundFileReadFrame = 1024;
static const NSInteger kSoundExistenceBoundary = 100;
static const NSInteger kSoundExistenceAverageReadPackets = 100;
static const NSInteger k1SecondResolution = kTempSoundFileSampleRate / kSoundExistenceAverageReadPackets;

@interface PhraseAnalyzeOperation ()

@property (nonatomic, strong) NSURL *songURL;

@end

@implementation PhraseAnalyzeOperation

- (id)initWithURL:(NSURL *)songURL delegate:(id)delegate {
    self = [super init];
    if (self) {
        _songURL  = songURL;
        _delegate = delegate;
    }
    return self;
}

// TODO: 受け取った音楽ファイルが既にPCMな場合の処理
// TODO: これらの処理は全部時間がかかるので別スレッドにする
// TODO: 各CoreAudio系の関数のエラー処理が必要
- (void)main {
    NSURL *tempPCMFileURL = [self createTempPCMData:self.songURL];
    NSArray *existenceArray = [self soundExistenceArrayPer10Millisecond:tempPCMFileURL];
    NSArray *phraseBeginTimes = [self phraseBeginTimesFromSoundExistenceArray:existenceArray];
    CGFloat playTime = (CGFloat)existenceArray.count / k1SecondResolution;
    NSArray *phrases = [self phrasesFromPhraseBeginTimes:phraseBeginTimes songPlayTime:playTime];
    [self.delegate phraseAnalyzeOperationDidFinish:phrases];
}

- (NSURL *)createTempPCMData:(NSURL *)songURL {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    NSString *fileName = [NSString stringWithFormat:@"%@.wav", [dateFormatter stringFromDate:[NSDate date]]];
    NSURL *tempFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];

    // 16ビット・モノラルな設定
    AudioStreamBasicDescription outputFormat;
    outputFormat.mFormatID			= kAudioFormatLinearPCM;
    outputFormat.mFormatFlags		= kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    outputFormat.mSampleRate        = kTempSoundFileSampleRate;
    outputFormat.mFramesPerPacket	= 1;
    outputFormat.mChannelsPerFrame	= 1;
    outputFormat.mBitsPerChannel    = 16;
    outputFormat.mBytesPerPacket    = 2;
    outputFormat.mBytesPerFrame		= 2;
    outputFormat.mReserved			= 0;

    ExtAudioFileRef infile, outfile;
    ExtAudioFileOpenURL((__bridge CFURLRef)songURL, &infile);
    ExtAudioFileSetProperty(infile,
                            kExtAudioFileProperty_ClientDataFormat,
                            sizeof(AudioStreamBasicDescription),
                            &outputFormat);

    ExtAudioFileCreateWithURL((__bridge CFURLRef)tempFileURL,
                              kAudioFileWAVEType,
                              &outputFormat,
                              NULL,
                              kAudioFileFlags_EraseFile,
                              &outfile);

    UInt32 readFrameSize = kTempSoundFileReadFrame;
    UInt32 bufferSize = sizeof(char) * readFrameSize * outputFormat.mBytesPerPacket;
    char *buffer = malloc(bufferSize);

    AudioBufferList audioBufferList;
    audioBufferList.mNumberBuffers = 1;
    audioBufferList.mBuffers[0].mNumberChannels = outputFormat.mChannelsPerFrame;
    audioBufferList.mBuffers[0].mDataByteSize = bufferSize;
    audioBufferList.mBuffers[0].mData = buffer;

    while (1) {
        readFrameSize = kTempSoundFileReadFrame;
        ExtAudioFileRead(infile, &readFrameSize, &audioBufferList);
        if (readFrameSize == 0) break;
        ExtAudioFileWrite(outfile,
                          readFrameSize,
                          &audioBufferList);
    }

    ExtAudioFileDispose(infile);
    ExtAudioFileDispose(outfile);
    free(buffer);

    return tempFileURL;
}

- (NSArray *)soundExistenceArrayPer10Millisecond:(NSURL *)PCMFileURL {
    NSMutableArray *soundExistenceArray = [NSMutableArray array];

    AudioFileID audioFileID;
    AudioFileOpenURL((__bridge CFURLRef)PCMFileURL,
                     kAudioFileReadPermission,
                     kAudioFileWAVEType,
                     &audioFileID);

    UInt64 packetCount;
    UInt32 size = sizeof(UInt64);
    AudioFileGetProperty (audioFileID,
                          kAudioFilePropertyAudioDataPacketCount,
                          &size,
                          &packetCount);

    UInt32 ioNumPackets = kSoundExistenceAverageReadPackets;
    short buffer[kSoundExistenceAverageReadPackets] = {0};
    for (int i = 0; i < packetCount; i += kSoundExistenceAverageReadPackets) {
        AudioFileReadPackets(audioFileID,
                             NO,
                             NULL,
                             NULL,
                             i,
                             &ioNumPackets,
                             &buffer);

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

// TODO: 頭出しをどう判定しているかのコメントが必要
// TODO: 頭出し判定を調整出来るようにするかもしれない
static const NSInteger kSoundExistenceJudgeCountNO = 20;
static const NSInteger kSoundExistenceJudgeCountYES = 10;

- (NSArray *)phraseBeginTimesFromSoundExistenceArray:(NSArray *)soundExistenceArray {
    NSMutableArray *phraseBeginTimes = [NSMutableArray array];

    for (int i = 0; i < soundExistenceArray.count - kSoundExistenceJudgeCountNO - kSoundExistenceJudgeCountYES; i++) {
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

- (NSArray *)phrasesFromPhraseBeginTimes:(NSArray *)phraseBeginTimes songPlayTime:(CGFloat)songPlayTime {
    NSMutableArray *phrases = [NSMutableArray array];

    Phrase *phrase = [[Phrase alloc] initWithStartTime:0.0f];
    [phrases addObject:phrase];

    for (int i = 0; i < phraseBeginTimes.count; i++) {
        CGFloat startTime = [(NSNumber *)phraseBeginTimes[i] floatValue];
        Phrase *phrase = [[Phrase alloc] initWithStartTime:startTime];
        [phrases addObject:phrase];
    }
    return phrases;
}

@end
