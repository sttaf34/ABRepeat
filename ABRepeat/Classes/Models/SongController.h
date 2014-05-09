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

@interface SongController : NSObject

+ (Song *)createSongAndPhrasesFromPhraseStartTimes:(NSArray *)phraseStartTimes
                                         mediaItem:(MPMediaItem *)mediaItem;

+ (Song *)findSongByMediaItem:(MPMediaItem *)mediaItem;

@end
