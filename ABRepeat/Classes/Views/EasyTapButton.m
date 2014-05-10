//
//  EasyTapButton.m
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/10/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import "EasyTapButton.h"

@implementation EasyTapButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect tappableBounds = CGRectMake(self.bounds.origin.x - self.tappableInsets.left,
                                       self.bounds.origin.y - self.tappableInsets.top,
                                       self.bounds.size.width + self.tappableInsets.left + self.tappableInsets.right,
                                       self.bounds.size.height + self.tappableInsets.top + self.tappableInsets.bottom);
    return CGRectContainsPoint(tappableBounds, point);
}

@end
