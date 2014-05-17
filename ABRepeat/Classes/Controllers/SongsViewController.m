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

    self.songController = [[SongController alloc] init];
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
        return;
    }

    createSongProgressBlock progressBlock = ^(CGFloat progress){ self.progressView.progress = progress; };
    createSongFinishBlock finishBlock = ^(MPMediaItem *mediaItem){
        self.progressView.progress = 1.0;
        [self.progressView dismiss:YES];
        Song *song = [self.songController findSongByMediaItem:mediaItem];
        [self performSegueWithIdentifier:@"ToSong" sender:song];
    };
    createSongErrorBlock errorBlock = ^(NSError *error){
        self.progressView.titleLabelText = NSLocalizedString(@"SongsViewController songControllerCreateSongDidError", @"");
    };

    [self.songController startCreateSongFromMediaItem:mediaItem
                                        progressBlock:progressBlock
                                          finishBlock:finishBlock
                                           errorBlock:errorBlock];

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

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mediaItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MPMediaItem *mediaItem = [self mediaItem:indexPath];
    cell.textLabel.text = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
    cell.textLabel.textColor = BLACK_TEXT_COLOR;
    return cell;
}

#pragma mark - Helper

- (MPMediaItem *)mediaItem:(NSIndexPath *)indexPath {
    return self.mediaItems[indexPath.row];
}

@end
