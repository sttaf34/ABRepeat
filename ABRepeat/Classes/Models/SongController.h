//
//  SongController.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/9/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Song+Helper.h"
#import "Phrase+Helper.h"

@protocol SongControllerDelegate;

@interface SongController : NSObject

- (instancetype)initWithDelegate:(id)delegate;

- (Song *)findSongByMediaItem:(MPMediaItem *)mediaItem;

- (void)startCreateSongFromMediaItem:(MPMediaItem *)mediaItem;
- (void)cancelCreateSong;

@end

@protocol SongControllerDelegate <NSObject>

- (void)songControllerCreateSongDidChangeProgress:(CGFloat)progress;
- (void)songControllerCreateSongDidFinish:(MPMediaItem *)mediaItem;
- (void)songControllerCreateSongDidError;

@end
