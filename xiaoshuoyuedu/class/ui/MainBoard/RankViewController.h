//
//  RankViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-27.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONRequestTableViewController.h"
@interface RankViewController : JSONRequestTableViewController
@property(nonatomic, strong) NSMutableArray* searchResult;
@property(nonatomic, strong) NSString* rankSource;
@property(nonatomic, strong) UIActivityIndicatorView *spinner;
@property(nonatomic, assign) NSUInteger currentPage;
@end
