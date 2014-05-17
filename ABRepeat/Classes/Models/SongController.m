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

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSURL *currentSongCreateURL;

@property (nonatomic, copy) createSongProgressBlock progressBlock;
@property (nonatomic, copy) createSongFinishBlock finishBlock;
@property (nonatomic, copy) createSongErrorBlock errorBlock;

@end

@implementation SongController

- (instancetype)init {
    self = [super init];
    if (self) {
        _operationQueue = [NSOperationQueue new];
    }
    return self;
}

- (void)startCreateSongWithURL:(NSURL *)URL
                 progressBlock:(createSongProgressBlock)progressBlock
                   finishBlock:(createSongFinishBlock)finishBlock
                    errorBlock:(createSongErrorBlock)errorBlock {
    self.currentSongCreateURL = URL;
    PhraseAnalyzeOperation *operation = [[PhraseAnalyzeOperation alloc] initWithURL:URL delegate:self];
    [self.operationQueue addOperation:operation];

    self.progressBlock = progressBlock;
    self.finishBlock   = finishBlock;
    self.errorBlock    = errorBlock;
}

- (void)cancelCreateSong {
    [self.operationQueue cancelAllOperations];
}

- (Song *)findSongByURL:(NSURL *)URL {
    NSManagedObjectContext *context = [CoreDataManager sharedManager].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[Song entityName]];
    [request setFetchLimit:1];
    [request setPredicate:[NSPredicate predicateWithFormat:@"songURL == %@", URL.absoluteString]];

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

- (Song *)findSongByMediaItem:(MPMediaItem *)mediaItem {
    NSURL *songURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    return [self findSongByURL:songURL];
}

#pragma mark - PhraseAnalyzeOperationDelegate

- (void)phraseAnalyzeOperationDidChangeProgress:(CGFloat)progress {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.progressBlock(progress);
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
        song.songURL = self.currentSongCreateURL.absoluteString;

        NSError *error;
        [context save:&error];
        if (error) NSLog(@"%@", error);

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.finishBlock(self.currentSongCreateURL);
        }];
    }];
}

- (void)phraseAnalyzeOperationDidError {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.errorBlock(nil);
    }];
}

- (void)phraseAnalyzeOperationDidCancel {

}

@end
