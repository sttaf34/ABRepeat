//
//  SongViewController.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/1/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "SongViewController.h"
#import "SongController.h"
#import "SongCell.h"
#import "Phrase.h"

@interface SongViewController () <SongControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) SongController *songController;
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

    self.songController = [[SongController alloc] initWithDelegate:self songURL:self.songURL phrases:self.phrases];
    [self.songController playPhraseAtIndex:0];

    [self updateVisibleCells];
    [self updateButtonsAndLabelsStatus];
}

- (void)dealloc {
    [self.songController stop];
}

- (void)updateButtonsAndLabelsStatus {
    if (self.songController.isRepeat) {
        self.repeatButton.alpha = 1.0;
    } else {
        self.repeatButton.alpha = 0.2;
    }
    self.playButton.selected = self.songController.isPlay;
    self.speedMinusButton.enabled = self.songController.isEnabledSpeedDown;
    self.speedPlusButton.enabled = self.songController.isEnabledSpeedUp;

    self.playSpeedLabel.text = [NSString stringWithFormat:@"%d%%", self.songController.playSpeed];
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.songController playPhraseAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self updateButtonsAndLabelsStatus];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songController.phrases.count;
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
    Phrase *phrase = self.songController.phrases[indexPath.row];
    cell.timeLabel.text = [NSString stringWithFormat:@"%0.2f", phrase.startTime];
    [cell playingIndicatorWorking:(indexPath.row == self.songController.playingIndex)];
}

- (void)updateVisibleCells {
    for (SongCell *cell in [self.tableView visibleCells]){
        [self updateCell:cell atIndexPath:[self.tableView indexPathForCell:cell]];
    }
}

#pragma mark - SongControllerDelegate

- (void)songControllerChangePhraseAtIndex:(NSUInteger)index {
    [self updateVisibleCells];
}

- (void)songControllerPlayerStop {
    [self updateButtonsAndLabelsStatus];
}

#pragma mark - ButtonCallback

- (IBAction)repeatButtonCallback:(id)sender {
    [self.songController repeatToggle];
    [self updateButtonsAndLabelsStatus];
}

- (IBAction)playButtonCallback:(id)sender {
    [self.songController playToggle];
    [self updateButtonsAndLabelsStatus];
}

- (IBAction)speedMinusButtonCallback:(id)sender {
    [self.songController speedDown];
    [self updateButtonsAndLabelsStatus];
}

- (IBAction)speedPlusButtonCallback:(id)sender {
    [self.songController speedUp];
    [self updateButtonsAndLabelsStatus];
}

@end
