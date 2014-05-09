//
//  SongViewController.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/1/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "SongViewController.h"
#import "SongCell.h"
#import "SongPlayer.h"
#import "Phrase+Helper.h"
#import "Song+Helper.h"

@interface SongViewController () <SongPlayerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) SongPlayer *songPlayer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *repeatButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *speedMinusButton;
@property (weak, nonatomic) IBOutlet UIButton *speedPlusButton;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *playSpeedLabel;

@end

@implementation SongViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.songPlayer = [[SongPlayer alloc] initWithDelegate:self song:self.song];
    [self.songPlayer playPhraseAtIndex:0];

    [self updateVisibleCells];
    [self updateButtonsAndLabelsStatus];
}

- (void)dealloc {
    [self.songPlayer stop];
}

- (void)updateButtonsAndLabelsStatus {
    if (self.songPlayer.isRepeat) {
        self.repeatButton.alpha = 1.0;
    } else {
        self.repeatButton.alpha = 0.2;
    }
    self.playButton.selected = self.songPlayer.isPlay;
    self.speedMinusButton.enabled = self.songPlayer.isEnabledSpeedDown;
    self.speedPlusButton.enabled = self.songPlayer.isEnabledSpeedUp;

    self.playSpeedLabel.text = [NSString stringWithFormat:@"%d%%", self.songPlayer.playSpeed];
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.songPlayer playPhraseAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self updateButtonsAndLabelsStatus];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.song.sortedPhrases.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self updateCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Helper

- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self.tableView];
    return [self.tableView indexPathForRowAtPoint:point];
}

- (void)updateCell:(SongCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Phrase *phrase = self.song.sortedPhrases[indexPath.row];
    cell.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d.%02d", phrase.startTimeMinute, phrase.startTimeSecond, phrase.startTime10Millisecond];
    [cell playingIndicatorWorking:(indexPath.row == self.songPlayer.playingIndex)];
}

- (void)updateVisibleCells {
    for (SongCell *cell in [self.tableView visibleCells]){
        [self updateCell:cell atIndexPath:[self.tableView indexPathForCell:cell]];
    }
}

#pragma mark - SongPlayerDelegate

- (void)songPlayerChangePhraseAtIndex:(NSUInteger)index {
    [self updateVisibleCells];
}

- (void)songPlayerPlayerStop {
    [self updateButtonsAndLabelsStatus];
}

- (void)songPlayerChangeCurrentTime:(CGFloat)currentTime {
    int minute = (int)currentTime / 60;
    int second = (int)currentTime % 60;
    self.playTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minute, second];
}

#pragma mark - ButtonCallback

- (IBAction)repeatButtonCallback:(id)sender {
    [self.songPlayer repeatToggle];
    [self updateButtonsAndLabelsStatus];
}

- (IBAction)playButtonCallback:(id)sender {
    [self.songPlayer playToggle];
    [self updateButtonsAndLabelsStatus];
}

- (IBAction)speedMinusButtonCallback:(id)sender {
    [self.songPlayer speedDown];
    [self updateButtonsAndLabelsStatus];
}

- (IBAction)speedPlusButtonCallback:(id)sender {
    [self.songPlayer speedUp];
    [self updateButtonsAndLabelsStatus];
}

@end
