//
//  SongCell.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/4/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "SongCell.h"

static const CGFloat kBarMaxY = 28;
static const CGFloat kBarMinY = 14;
static const CGFloat kBarMaxHeight = 16;
static const CGFloat kBarMinHeight = 2;

static const CGFloat kAnimationSettingMinDuration = 0.4;
static const CGFloat kAnimationSettingMinDelay = 0.2;
static const NSUInteger kAnimationSettingRandomCount = 6;
static const CGFloat kAnimationSettingRandomDistance = 0.05;

@interface SongCell ()

@property (weak, nonatomic) IBOutlet UIImageView *leftBar;
@property (weak, nonatomic) IBOutlet UIImageView *centerBar;
@property (weak, nonatomic) IBOutlet UIImageView *rightBar;

@property (assign, nonatomic) BOOL isAnimation;

@end

@implementation SongCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _isAnimation = NO;
    }
    return self;
}

- (CGFloat)randomDuration {
    return kAnimationSettingMinDuration + (arc4random() % kAnimationSettingRandomCount) * kAnimationSettingRandomDistance;
}

- (CGFloat)randomDelay {
    return kAnimationSettingMinDelay + (arc4random() % kAnimationSettingRandomCount) * kAnimationSettingRandomDistance;
}

- (void)playingIndicatorWorking:(BOOL)isWorking {
    NSArray *bars = @[self.leftBar, self.centerBar, self.rightBar];
    if (isWorking) {
        self.isAnimation = YES;

        for (UIImageView *bar in bars) {
            [UIView animateWithDuration:[self randomDuration]
                                  delay:[self randomDelay]
                                options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                             animations:^{
                                 bar.frame = CGRectMake(bar.frame.origin.x, kBarMinY,
                                                        bar.frame.size.width, kBarMaxHeight);
                             } completion:nil];
        }
    } else {
        if (!self.isAnimation) return;
        self.isAnimation = NO;

        for (UIImageView *bar in bars) {
            // アニメーション途中の値にしてしまう
            CALayer *layer = bar.layer.presentationLayer;
            bar.frame = CGRectMake(bar.frame.origin.x, layer.position.y - layer.frame.size.height * 0.5,
                                   bar.frame.size.width, layer.frame.size.height);

            [bar.layer removeAllAnimations];

            [UIView animateWithDuration:[self randomDuration]
                                  delay:[self randomDelay]
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                bar.frame = CGRectMake(bar.frame.origin.x, kBarMaxY, bar.frame.size.width, kBarMinHeight);
            } completion:nil];
        }
    }
}

@end
