//
//  SongController.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/9/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "SongController.h"
#import "CoreDataManager.h"
#import "PhraseAnalyzeOperation.h"

@interface SongController () <PhraseAnalyzeOperationDelegate>

@property (nonatomic, weak) id <SongControllerDelegate> delegate;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) MPMediaItem *currentSongCreateMediaItem;

@end

@implementation SongController

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _operationQueue = [NSOperationQueue new];
    }
    return self;
}

- (void)startCreateSongFromMediaItem:(MPMediaItem *)mediaItem {
    self.currentSongCreateMediaItem = mediaItem;
    PhraseAnalyzeOperation *opetation = [[PhraseAnalyzeOperation alloc] initWithMediaItem:mediaItem delegate:self];
    [self.operationQueue addOperation:opetation];
}

- (void)cancelCreateSong {
    [self.operationQueue cancelAllOperations];
}

- (Song *)findSongByMediaItem:(MPMediaItem *)mediaItem {
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

#pragma mark - PhraseAnalyzeOperationDelegate

- (void)phraseAnalyzeOperationDidChangeProgress:(CGFloat)progress {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.delegate songControllerCreateSongDidChangeProgress:progress];
    }];
}

- (void)phraseAnalyzeOperationDidFinish:(NSArray *)phraseStartTimes {
    NSManagedObjectContext *context = [CoreDataManager sharedManager].privateQueueContext;
    [context performBlock:^{
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
        NSURL *songURL = [self.currentSongCreateMediaItem valueForProperty:MPMediaItemPropertyAssetURL];
        song.songURL = songURL.absoluteString;
        song.title   = [self.currentSongCreateMediaItem valueForProperty:MPMediaItemPropertyTitle];
        
        NSError *error;
        [context save:&error];
        if (error) NSLog(@"%@", error);

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.delegate songControllerCreateSongDidFinish:self.currentSongCreateMediaItem];
        }];
    }];
}

- (void)phraseAnalyzeOperationDidError {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.delegate songControllerCreateSongDidError];
    }];
}

@end
