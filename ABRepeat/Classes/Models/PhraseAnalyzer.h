//
//  PhraseAnalyzer.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/1/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Song;

@protocol PhraseAnalyzerDelegate;

@interface PhraseAnalyzer : NSObject

@property (nonatomic, weak) id <PhraseAnalyzerDelegate> delegate;

- (id)initWithDelegate:(id)delegate;

- (void)startPhraseAnalyzeFromMediaItem:(MPMediaItem *)mediaItem;
- (void)cancelPhraseAnalyze;

@end

@protocol PhraseAnalyzerDelegate <NSObject>

- (void)phraseAnalyzerDidChangeProgress:(CGFloat)progress;
- (void)phraseAnalyzerDidFinish:(Song *)song;
- (void)phraseAnalyzerDidError;

@end
