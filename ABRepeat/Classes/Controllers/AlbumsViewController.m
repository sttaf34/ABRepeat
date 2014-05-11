//
//  AlbumsViewController.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/10/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "AlbumsViewController.h"
#import "SongsViewController.h"

@interface AlbumsViewController ()

@property (nonatomic, copy) NSArray *albums;

@end

@implementation AlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.albums = [MPMediaQuery albumsQuery].collections;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToSongs"]) {
        SongsViewController *viewController = [segue destinationViewController];
        viewController.mediaItemCollection = sender;

        MPMediaItem *mediaItem = [(MPMediaItemCollection *)sender representativeItem];
        viewController.navigationItem.title = [mediaItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    }
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    MPMediaItemCollection *album = self.albums[indexPath.row];
    [self performSegueWithIdentifier:@"ToSongs" sender:album];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MPMediaItemCollection *collection = self.albums[indexPath.row];
    MPMediaItem *mediaItem = [collection representativeItem];
    cell.textLabel.text = [mediaItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    return cell;
}

@end
