//
//  PhraseAnalyzeOperation.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/7/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Song;

@protocol PhraseAnalyzeOperationDelegate;

@interface PhraseAnalyzeOperation : NSOperation

@property (weak, nonatomic) id<PhraseAnalyzeOperationDelegate> delegate;

- (id)initWithMediaItem:(MPMediaItem *)mediaItem delegate:(id)delegate;

@end

@protocol PhraseAnalyzeOperationDelegate <NSObject>

- (void)phraseAnalyzeOperationDidChangeProgress:(CGFloat)progress;
- (void)phraseAnalyzeOperationDidFinish:(Song *)song;
- (void)phraseAnalyzeOperationDidError;

@end
