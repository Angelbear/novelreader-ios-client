//
//  Bookmark.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 14-4-16.
//  Copyright (c) 2014年 Yangyang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Bookmark : NSManagedObject

@property (nonatomic, retain) NSNumber * book_id;
@property (nonatomic, retain) NSNumber * section_id;
@property (nonatomic, retain) NSNumber * offset;
@property (nonatomic, retain) NSNumber * book_mark_id;
@property (nonatomic, retain) NSNumber * default_bookmark;
@property (nonatomic, retain) NSNumber * last_update_time;

@end
