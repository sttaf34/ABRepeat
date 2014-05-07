//
//  PhraseAnalyzer.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/1/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "PhraseAnalyzer.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Phrase.h"
#import "PhraseAnalyzeOperation.h"

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

- (void)startPhraseAnalyzeFromSongURL:(NSURL *)songURL {
    PhraseAnalyzeOperation *operation = [[PhraseAnalyzeOperation alloc] initWithURL:songURL delegate:self];
    [self.operationQueue addOperation:operation];
}

- (void)cancelPhraseAnalyze {
    [self.operationQueue cancelAllOperations];
}

#pragma mark - PhraseAnalyzeOperationDelegate

- (void)phraseAnalyzeOperationDidChangeProgress:(CGFloat)progress {
    [self.delegate phraseAnalyzerDidChangeProgress:progress];
}

- (void)phraseAnalyzeOperationDidFinish:(NSArray *)phrases {
    [self.delegate phraseAnalyzerDidFinish:phrases];
}

@end
