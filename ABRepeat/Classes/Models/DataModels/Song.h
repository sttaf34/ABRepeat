//
//  Song.h
//  ABRepeat
//
//  Created by Shinichi Kawamura on 5/8/14.
//  Copyright (c) 2014 Shinichi Kawamura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Phrase;

@interface Song : NSManagedObject

@property (nonatomic, retain) NSString * songURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *phrases;
@end

@interface Song (CoreDataGeneratedAccessors)

- (void)addPhrasesObject:(Phrase *)value;
- (void)removePhrasesObject:(Phrase *)value;
- (void)addPhrases:(NSSet *)values;
- (void)removePhrases:(NSSet *)values;

@end
