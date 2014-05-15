//
//  SongViewController.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/1/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "SongViewController.h"
#import "SongCell.h"
#import "EasyTapButton.h"
#import "SongPlayer.h"
#import "Phrase+Helper.h"
#import "Song+Helper.h"

static const NSInteger kButtonPadding = 16;

@interface SongViewController () <SongPlayerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) SongPlayer *songPlayer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet EasyTapButton *repeatButton;
@property (weak, nonatomic) IBOutlet EasyTapButton *playButton;
@property (weak, nonatomic) IBOutlet EasyTapButton *speedMinusButton;
@property (weak, nonatomic) IBOutlet EasyTapButton *speedPlusButton;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *playSpeedLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;

@end

@implementation SongViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Storyboardでは0.5pxの線が引けないのでコードで配置
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.5)];
    border.backgroundColor = NAVIGATION_BAR_BORDER_BOTTOM_COLOR;
    [self.buttonsView addSubview:border];

    // 画面の最下部に配置されたボタンはハイライトが即座に反映されないので、ボトムのタップ領域は広げない
    // 左右端のボタンは多目にタップ領域を拡大
    self.repeatButton.tappableInsets     = UIEdgeInsetsMake(kButtonPadding, kButtonPadding * 2, 0, kButtonPadding);
    self.playButton.tappableInsets       = UIEdgeInsetsMake(kButtonPadding, kButtonPadding, 0, kButtonPadding);
    self.speedMinusButton.tappableInsets = UIEdgeInsetsMake(kButtonPadding, kButtonPadding, 0, kButtonPadding);
    self.speedPlusButton.tappableInsets  = UIEdgeInsetsMake(kButtonPadding, kButtonPadding, 0, kButtonPadding * 2);

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
    self.repeatButton.selected = self.songPlayer.isRepeat;
    self.playButton.selected = self.songPlayer.isPlay;
    self.speedMinusButton.enabled = self.songPlayer.isEnabledSpeedDown;
    self.speedPlusButton.enabled = self.songPlayer.isEnabledSpeedUp;

    self.playSpeedLabel.text = [NSString stringWithFormat:@"%d%%", (int)self.songPlayer.playSpeed];
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
    [cell stopImmediatelyIndicator];
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
    cell.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d.%02d", (int)phrase.startTimeMinute, (int)phrase.startTimeSecond, (int)phrase.startTime10Millisecond];
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

- (void)songPlayerChangeTIme:(NSString *)currentTimeAndTotalTime {
    self.playTimeLabel.text = currentTimeAndTotalTime;
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
