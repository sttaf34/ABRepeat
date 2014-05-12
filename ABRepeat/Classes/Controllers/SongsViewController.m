//
//  PlaylistSongsViewController.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/10/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "SongsViewController.h"
#import "SongController.h"
#import "MRProgress.h"
#import "SongViewController.h"

@interface SongsViewController ()
@property (nonatomic, strong) SongController *songController;
@property (nonatomic, strong) MRProgressOverlayView *progressView;
@end

@implementation SongsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.songController = [[SongController alloc] initWithDelegate:self];
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

    MPMediaItem *mediaItem = self.mediaItemCollection.items[indexPath.row];

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mediaItemCollection.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MPMediaItem *mediaItem = self.mediaItemCollection.items[indexPath.row];
    cell.textLabel.text = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
    return cell;
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
    self.progressView.titleLabelText = NSLocalizedString(@"SongsViewController songControllerCreateSongDidError", @"");
}

@end
