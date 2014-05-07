//
//  SongViewController.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/1/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongViewController : UIViewController

@property (nonatomic, strong) NSURL *songURL;
@property (nonatomic, strong) NSArray *phrases;

@end
