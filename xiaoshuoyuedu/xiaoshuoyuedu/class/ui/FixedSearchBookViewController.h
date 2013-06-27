//
//  FixedSearchBookViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-27.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FixedSearchBookViewController : UITableViewController
@property(nonatomic, strong) NSString* savedSearchTerm;
@property(nonatomic, strong) id searchResult;
@property(nonatomic, strong) NSCountedSet* sectionResult;
@end
