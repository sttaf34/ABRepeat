//
//  SongsViewController.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 4/27/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "SongsViewController.h"
#import "SongViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PhraseAnalyzer.h"
#import "MRProgress.h"

@interface SongsViewController () <PhraseAnalyzerDelegate>

@property (nonatomic, copy) NSArray *collections;
@property (nonatomic, copy) NSArray *collectionSections;
@property (nonatomic, strong) PhraseAnalyzer *phraseAnalyzer;
@property (nonatomic, strong) MRProgressOverlayView *progressView;

@end

@implementation SongsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.phraseAnalyzer = [[PhraseAnalyzer alloc] initWithDelegate:self];

    MPMediaQuery *mediaQuery = [MPMediaQuery songsQuery];
    self.collections = mediaQuery.collections;
    self.collectionSections = mediaQuery.collectionSections;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToSong"]) {
        SongViewController *viewController = [segue destinationViewController];
        viewController.phrases = (NSArray *)sender;
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        NSURL *songURL = [self mediaItemURL:path];
        viewController.songURL = songURL;
    }
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    MPMediaItem *mediaItem = [self mediaItem:indexPath];
    NSURL *songURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    [self.phraseAnalyzer startPhraseAnalyzeFromSongURL:songURL];

    self.progressView = [MRProgressOverlayView new];
    self.progressView.mode = MRProgressOverlayViewModeDeterminateCircular;
    self.progressView.stopBlock = ^(MRProgressOverlayView *view) {
        [view dismiss:YES];
    };
    [self.view.window addSubview:self.progressView];
    [self.progressView show:YES];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.collectionSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MPMediaQuerySection *mediaQuerySection = self.collectionSections[section];
    return mediaQuerySection.range.length;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    MPMediaQuerySection *mediaQuerySection = self.collectionSections[section];
    return mediaQuerySection.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MPMediaItem *mediaItem = [self mediaItem:indexPath];
    cell.textLabel.text = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
    return cell;
}

#pragma mark - PhraseAnalyzerDelegate

- (void)phraseAnalyzerDidChangeProgress:(CGFloat)progress {

}

- (void)phraseAnalyzerDidFinish:(NSArray *)phrases {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.progressView dismiss:YES];
        [self performSegueWithIdentifier:@"ToSong" sender:phrases];
    }];
}

#pragma mark - Helper

- (MPMediaItem *)mediaItem:(NSIndexPath *)indexPath {
    MPMediaQuerySection *section = self.collectionSections[indexPath.section];
    MPMediaItemCollection *mediaItemCollection = self.collections[section.range.location + indexPath.row];
    return [mediaItemCollection representativeItem];
}

- (NSURL *)mediaItemURL:(NSIndexPath *)indexPath {
    return [[self mediaItem:indexPath] valueForProperty:MPMediaItemPropertyAssetURL];
}

@end
