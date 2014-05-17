//
//  SongControllerTests.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/17/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SongController.h"
#import "NSManagedObject+Helper.h"

@interface SongControllerTests : XCTestCase

@end

@implementation SongControllerTests {
    NSURL *_fileAIFFURL;
    NSURL *_fileM4AURL;
    NSManagedObjectModel *_objectModel;
    NSPersistentStoreCoordinator *_coordinator;
    NSManagedObjectContext *_context;
    SongController *_songController;
}

- (void)setUp {
    [super setUp];
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    _fileAIFFURL = [testBundle URLForResource:@"test_sound" withExtension:@"aiff"];
    _fileM4AURL  = [testBundle URLForResource:@"test_sound" withExtension:@"m4a"];

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_objectModel];
    [_coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    _context = [[NSManagedObjectContext alloc] init];
    _context.persistentStoreCoordinator = _coordinator;

    _songController = [[SongController alloc] init];
}

- (void)testFindSongByURL {
    Song *song = [NSEntityDescription insertNewObjectForEntityForName:[Song entityName]
                                               inManagedObjectContext:_context];
    song.songURL = _fileAIFFURL.absoluteString;
    XCTAssertNotNil([_songController findSongByURL:_fileAIFFURL]);
}

- (void)testCreateSongWithURL {
    __block BOOL isFinished = NO;
    [_songController startCreateSongWithURL:_fileAIFFURL progressBlock:^(CGFloat progress) {}
                               finishBlock:^(NSURL *URL){
                                   XCTAssertNotNil([_songController findSongByURL:URL]);
                                   isFinished = YES;
                               }
                                errorBlock:^(NSError *error){}];
    while (!isFinished) { [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]]; }
    XCTAssertTrue(isFinished);
}

@end
