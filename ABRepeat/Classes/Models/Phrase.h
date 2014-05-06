//
//  Phrase.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/2/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Phrase : NSObject

@property (nonatomic, assign) CGFloat startTime;

- (id)initWithStartTime:(CGFloat)startTime;

@end
