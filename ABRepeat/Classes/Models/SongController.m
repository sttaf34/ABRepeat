//
//  SongController.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/9/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "SongController.h"
#import "CoreDataManager.h"

@implementation SongController

+ (Song *)createSongAndPhrasesFromPhraseStartTimes:(NSArray *)phraseStartTimes
                                         mediaItem:(id)mediaItem {
    NSManagedObjectContext *context = [CoreDataManager sharedManager].managedObjectContext;

    NSMutableArray *phrases = [NSMutableArray array];

    Phrase *phrase = [NSEntityDescription insertNewObjectForEntityForName:[Phrase entityName]
                                                   inManagedObjectContext:context];
    phrase.startTime = [NSNumber numberWithFloat:0.0f];
    [phrases addObject:phrase];

    [phraseStartTimes enumerateObjectsUsingBlock:^(NSNumber *phraseStartTime, NSUInteger idx, BOOL *stop) {
        Phrase *phrase = [NSEntityDescription insertNewObjectForEntityForName:[Phrase entityName]
                                                       inManagedObjectContext:context];
        phrase.startTime = phraseStartTime;
        [phrases addObject:phrase];
    }];

    Song *song = [NSEntityDescription insertNewObjectForEntityForName:[Song entityName]
                                               inManagedObjectContext:context];
    song.phrases = [NSSet setWithArray:phrases.copy];
    NSURL *songURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    song.songURL = songURL.absoluteString;
    song.title   = [mediaItem valueForProperty:MPMediaItemPropertyTitle];

    NSError *error;
    [context save:&error];
    if (error) NSLog(@"%@", error);

    return song;
}

+ (Song *)findSongByMediaItem:(MPMediaItem *)mediaItem {
    NSManagedObjectContext *context = [CoreDataManager sharedManager].managedObjectContext;

    NSURL *songURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[Song entityName]];
    [request setFetchLimit:1];
    [request setPredicate:[NSPredicate predicateWithFormat:@"songURL == %@", songURL.absoluteString]];

    NSError *error;
    NSArray *songs = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    } else if (!songs || songs.count == 0) {
        return nil;
    } else {
        return songs[0];
    }
}

@end
