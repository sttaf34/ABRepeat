//
//  SongCell.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/4/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (void)playingIndicatorWorking:(BOOL)isWorking;

@end
