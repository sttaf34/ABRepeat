//
//  SongsViewController.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 4/27/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "SectionIndexSongsViewController.h"

@interface SectionIndexSongsViewController ()

@property (nonatomic, copy) NSArray *collections;
@property (nonatomic, copy) NSArray *collectionSections;
@property (nonatomic, copy) NSArray *rightSideTitles;

@end

@implementation SectionIndexSongsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    MPMediaQuery *mediaQuery = [MPMediaQuery songsQuery];
    self.collections = mediaQuery.collections;
    self.collectionSections = mediaQuery.collectionSections;

    NSMutableArray *titles = [NSMutableArray array];
    for (MPMediaQuerySection *section in self.collectionSections) {
        [titles addObject:section.title];
    }
    self.rightSideTitles = [titles copy];
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.rightSideTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.rightSideTitles indexOfObject:title];
}

#pragma mark - Helper

- (MPMediaItem *)mediaItem:(NSIndexPath *)indexPath {
    MPMediaQuerySection *section = self.collectionSections[indexPath.section];
    MPMediaItemCollection *mediaItemCollection = self.collections[section.range.location + indexPath.row];
    return [mediaItemCollection representativeItem];
}

@end
