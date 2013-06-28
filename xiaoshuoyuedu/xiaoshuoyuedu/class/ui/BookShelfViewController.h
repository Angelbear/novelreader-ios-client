//
//  BookShelfViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-28.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookShelfViewController : UITableViewController
@property(nonatomic, strong) NSMutableArray* books;
@property(nonatomic, strong) UIBarButtonItem* editButton;
@property(nonatomic, strong) UIBarButtonItem* doneButton;
@property(nonatomic, strong) UIActivityIndicatorView *spinner;
@property(nonatomic, assign) NSUInteger isRefreshing;
@end
