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

@interface SongsViewController ()

@property (nonatomic, retain, readwrite) NSArray * collections;
@property (nonatomic, retain, readwrite) NSArray * collectionSections;

@end

@implementation SongsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    MPMediaQuery *mediaQuery = [MPMediaQuery songsQuery];
    self.collections = mediaQuery.collections;
    self.collectionSections = mediaQuery.collectionSections;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToSong"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        MPMediaQuerySection *section = self.collectionSections[indexPath.section];
        MPMediaItemCollection *mediaItemCollection = self.collections[section.range.location + indexPath.row];
        MPMediaItem *mediaItem = [mediaItemCollection representativeItem];
        SongViewController *songViewController = [segue destinationViewController];
        songViewController.songURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
        songViewController.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"ToSong" sender:indexPath];
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

    MPMediaQuerySection *section = self.collectionSections[indexPath.section];
    MPMediaItemCollection *mediaItemCollection = self.collections[section.range.location + indexPath.row];
    MPMediaItem *mediaItem = [mediaItemCollection representativeItem];
    cell.textLabel.text = [mediaItem valueForProperty:MPMediaItemPropertyTitle];

    return cell;
}

@end
