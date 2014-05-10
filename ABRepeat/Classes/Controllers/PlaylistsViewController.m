//
//  PlaylistsViewController.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/10/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "PlaylistsViewController.h"
#import "PlaylistSongsViewController.h"

@interface PlaylistsViewController ()

@property (nonatomic, copy) NSArray *playlists;

@end

@implementation PlaylistsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.playlists = [MPMediaQuery playlistsQuery].collections;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToPlaylistSongs"]) {
        PlaylistSongsViewController *viewController = [segue destinationViewController];
        viewController.playlist = sender;
        viewController.navigationItem.title = @"hoge";
    }
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    MPMediaItemCollection *playlist = self.playlists[indexPath.row];
    [self performSegueWithIdentifier:@"ToPlaylistSongs" sender:playlist];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.playlists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MPMediaItemCollection *collection = self.playlists[indexPath.row];
    cell.textLabel.text = [collection valueForProperty:MPMediaPlaylistPropertyName];
    return cell;
}

@end
