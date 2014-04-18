//
//  Book.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 14-4-15.
//  Copyright (c) 2014年 Yangyang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Section;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * book_id;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSNumber * last_update_time;
@property (nonatomic, retain) id cover;
@property (nonatomic, retain) NSSet *relationship;
@end

@interface Book (CoreDataGeneratedAccessors)

- (void)addRelationshipObject:(Section *)value;
- (void)removeRelationshipObject:(Section *)value;
- (void)addRelationship:(NSSet *)values;
- (void)removeRelationship:(NSSet *)values;

@end
