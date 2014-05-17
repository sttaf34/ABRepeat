//
//  SongController.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/9/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Song+Helper.h"
#import "Phrase.h"

typedef void (^createSongProgressBlock)(CGFloat progress);
typedef void (^createSongFinishBlock)(MPMediaItem *mediaItem);
typedef void (^createSongErrorBlock)(NSError *error);

@interface SongController : NSObject

- (instancetype)init;

- (Song *)findSongByMediaItem:(MPMediaItem *)mediaItem;

- (void)startCreateSongFromMediaItem:(MPMediaItem *)mediaItem
                       progressBlock:(createSongProgressBlock)progressBlock
                         finishBlock:(createSongFinishBlock)finishBlock
                          errorBlock:(createSongErrorBlock)errorBlock;
- (void)cancelCreateSong;

@end
