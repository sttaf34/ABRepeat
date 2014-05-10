//
//  AlbumsViewController.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/10/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "AlbumsViewController.h"

@interface AlbumsViewController ()

@property (nonatomic, copy) NSArray *albums;

@end

@implementation AlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.albums = [MPMediaQuery albumsQuery].collections;
}

#pragma mark - TableViewDelegate


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
    NSLog(@"%@", [collection valueForProperty:MPMediaItemPropertyAlbumTitle]);
    return cell;
}

@end
