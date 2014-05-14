//
//  PhraseAnalyzeOperation.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/7/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PhraseAnalyzeOperationDelegate;

@interface PhraseAnalyzeOperation : NSOperation

- (instancetype)initWithMediaItem:(MPMediaItem *)mediaItem delegate:(id)delegate;

@end

@protocol PhraseAnalyzeOperationDelegate <NSObject>

- (void)phraseAnalyzeOperationDidChangeProgress:(CGFloat)progress;
- (void)phraseAnalyzeOperationDidFinish:(NSArray *)phraseStartTimes;
- (void)phraseAnalyzeOperationDidError;

@end
