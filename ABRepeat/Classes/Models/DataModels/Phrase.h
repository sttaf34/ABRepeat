//
//  Phrase.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/8/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Song;

@interface Phrase : NSManagedObject

@property (nonatomic, retain) NSNumber * startTime;
@property (nonatomic, retain) Song *song;

@end
