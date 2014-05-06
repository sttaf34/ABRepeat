//
//  PhraseAnalyzer.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/1/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhraseAnalyzer : NSObject

- (NSArray *)phrasesFromSongURL:(NSURL *)songURL;

@end
