//
//  SectionReaderTableViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Section, Bookmark;
@interface SectionReaderTableViewController : UITableViewController
@property (nonatomic, strong) Section* section;
@property (nonatomic, strong) Bookmark* bookmark;
@end
