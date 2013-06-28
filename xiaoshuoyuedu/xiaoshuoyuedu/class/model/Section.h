//
//  Section.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-28.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Section : NSObject
@property(nonatomic, assign) NSUInteger section_id;
@property(nonatomic, assign) NSUInteger book_id;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* text;
@property(nonatomic, strong) NSString* from;
@property(nonatomic, assign) NSUInteger last_update_time;
@end
