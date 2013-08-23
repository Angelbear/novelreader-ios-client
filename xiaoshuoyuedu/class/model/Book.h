//
//  Book.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-28.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Book : NSObject
@property(nonatomic, assign) NSUInteger book_id;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* author;
@property(nonatomic, strong) NSString* from;
@property(nonatomic, strong) NSString* url;
@property(nonatomic, strong) UIImage* cover;
@property(nonatomic, assign) NSUInteger last_update_time;
@end
