//
//  MSReaderViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNavigationPaneViewController.h"
@class Book, Bookmark, SectionReaderTableViewController;
@interface MSReaderViewController : UITableViewController

@property (nonatomic, weak) MSNavigationPaneViewController *navigationPaneViewController;
@property (nonatomic, strong) SectionReaderTableViewController* currentReaderViewController;
@property (nonatomic, strong) Book* book;
@property (nonatomic, strong) Bookmark* bookmark;
- (void) loadBook:(Book*) book;
@end
