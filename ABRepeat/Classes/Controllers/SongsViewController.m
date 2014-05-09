//
//  SongsViewController.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 4/27/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "SongsViewController.h"
#import "SongViewController.h"
#import "MRProgress.h"
#import "PhraseAnalyzer.h"
#import "Song.h"

@interface SongsViewController () <PhraseAnalyzerDelegate>

@property (nonatomic, copy) NSArray *collections;
@property (nonatomic, copy) NSArray *collectionSections;
@property (nonatomic, copy) NSArray *rightSideTitles;
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

    NSMutableArray *titles = [NSMutableArray array];
    for (MPMediaQuerySection *section in self.collectionSections) {
        [titles addObject:section.title];
    }
    self.rightSideTitles = [titles copy];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToSong"]) {
        SongViewController *viewController = [segue destinationViewController];
        viewController.song = (Song *)sender;
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.navigationItem.title = [(Song *)sender title];
    }
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    MPMediaItem *mediaItem = [self mediaItem:indexPath];
    Song *song = [SongController findSongByMediaItem:mediaItem];
    if (song) {
        [self performSegueWithIdentifier:@"ToSong" sender:song];
        return;
    } else {
        [self.phraseAnalyzer startPhraseAnalyzeFromMediaItem:mediaItem];

        __weak PhraseAnalyzer *weakAnalyzer = self.phraseAnalyzer;
        self.progressView = [MRProgressOverlayView new];
        self.progressView.mode = MRProgressOverlayViewModeDeterminateCircular;
        self.progressView.stopBlock = ^(MRProgressOverlayView *view) {
            [weakAnalyzer cancelPhraseAnalyze];
            [view dismiss:YES];
        };
        [self.view.window addSubview:self.progressView];
        [self.progressView show:YES];
    }
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.rightSideTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.rightSideTitles indexOfObject:title];
}

#pragma mark - PhraseAnalyzerDelegate

- (void)phraseAnalyzerDidChangeProgress:(CGFloat)progress {
    self.progressView.progress = progress;
}

- (void)phraseAnalyzerDidFinish:(Song *)song {
    [self.progressView dismiss:YES];
    [self performSegueWithIdentifier:@"ToSong" sender:song];
}

- (void)phraseAnalyzerDidError {
    // TODO: アラートを出す予定
}

#pragma mark - Helper

- (MPMediaItem *)mediaItem:(NSIndexPath *)indexPath {
    MPMediaQuerySection *section = self.collectionSections[indexPath.section];
    MPMediaItemCollection *mediaItemCollection = self.collections[section.range.location + indexPath.row];
    return [mediaItemCollection representativeItem];
}

@end
