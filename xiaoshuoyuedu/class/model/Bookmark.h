//
//  Bookmark.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-1.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bookmark : NSObject
@property(nonatomic, assign) NSUInteger bookmark_id;
@property(nonatomic, assign) NSUInteger book_id;
@property(nonatomic, assign) NSUInteger section_id;
@property(nonatomic, assign) NSUInteger offset;
@property(nonatomic, assign) NSUInteger default_bookmark;
@property(nonatomic, assign) NSUInteger last_update_time;
@end
