//
//  PhraseAnalyzer.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/1/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "PhraseAnalyzer.h"
#import <AudioToolbox/AudioToolbox.h>
#import "PhraseAnalyzeOperation.h"
#import "SongController.h"
#import "Song.h"
#import "Phrase.h"

@interface PhraseAnalyzer () <PhraseAnalyzeOperationDelegate>

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation PhraseAnalyzer

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _operationQueue = [NSOperationQueue new];
    }
    return self;
}

- (void)startPhraseAnalyzeFromMediaItem:(MPMediaItem *)mediaItem {
    PhraseAnalyzeOperation *opetation = [[PhraseAnalyzeOperation alloc] initWithMediaItem:mediaItem delegate:self];
    [self.operationQueue addOperation:opetation];
}

- (void)cancelPhraseAnalyze {
    [self.operationQueue cancelAllOperations];
}

#pragma mark - PhraseAnalyzeOperationDelegate

- (void)phraseAnalyzeOperationDidChangeProgress:(CGFloat)progress {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.delegate phraseAnalyzerDidChangeProgress:progress];
    }];
}

- (void)phraseAnalyzeOperationDidFinish:(Song *)song {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.delegate phraseAnalyzerDidFinish:song];
    }];
}

- (void)phraseAnalyzeOperationDidError {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.delegate phraseAnalyzerDidError];
    }];
}

@end
