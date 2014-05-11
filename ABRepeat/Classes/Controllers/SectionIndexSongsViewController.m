//
//  SongsViewController.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 4/27/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "SectionIndexSongsViewController.h"
#import "SongViewController.h"
#import "MRProgress.h"
#import "SongController.h"

@interface SectionIndexSongsViewController () <SongControllerDelegate>

@property (nonatomic, copy) NSArray *collections;
@property (nonatomic, copy) NSArray *collectionSections;
@property (nonatomic, copy) NSArray *rightSideTitles;
@property (nonatomic, strong) SongController *songController;
@property (nonatomic, strong) MRProgressOverlayView *progressView;

@end

@implementation SectionIndexSongsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.songController = [[SongController alloc] initWithDelegate:self];

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
    Song *song = [self.songController findSongByMediaItem:mediaItem];

    if (song) {
        [self performSegueWithIdentifier:@"ToSong" sender:song];
    } else {
        [self.songController startCreateSongFromMediaItem:mediaItem];
        __weak SongController *weakSongController = self.songController;
        self.progressView = [MRProgressOverlayView new];
        self.progressView.mode = MRProgressOverlayViewModeDeterminateCircular;
        self.progressView.stopBlock = ^(MRProgressOverlayView *view) {
            [weakSongController cancelCreateSong];
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
    cell.textLabel.textColor = [UIColor colorWithWhite:44.0 / 255 alpha:1];
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.rightSideTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.rightSideTitles indexOfObject:title];
}

#pragma mark - SongControllerDelegate

- (void)songControllerCreateSongDidChangeProgress:(CGFloat)progress {
    self.progressView.progress = progress;
}

- (void)songControllerCreateSongDidFinish:(MPMediaItem *)mediaItem {
    [self.progressView dismiss:YES];
    Song *song = [self.songController findSongByMediaItem:mediaItem];
    [self performSegueWithIdentifier:@"ToSong" sender:song];
}

- (void)songControllerCreateSongDidError {
    self.progressView.titleLabelText = @"未対応の\nファイルです";
}

#pragma mark - Helper

- (MPMediaItem *)mediaItem:(NSIndexPath *)indexPath {
    MPMediaQuerySection *section = self.collectionSections[indexPath.section];
    MPMediaItemCollection *mediaItemCollection = self.collections[section.range.location + indexPath.row];
    return [mediaItemCollection representativeItem];
}

@end
