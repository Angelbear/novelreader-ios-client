//
//  Section.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 14-4-15.
//  Copyright (c) 2014年 Yangyang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Section : NSManagedObject

@property (nonatomic, retain) NSNumber * book_id;
@property (nonatomic, retain) NSNumber * section_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * last_update_time;

@end
