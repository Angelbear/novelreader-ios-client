//
//  SearchBookViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-24.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchBookViewController : UITableViewController<UISearchBarDelegate>

@property(nonatomic, assign) BOOL searchWasActive;
@property(nonatomic, strong) NSString* savedSearchTerm;
@property(nonatomic, assign) NSUInteger savedScopeButtonIndex;
@property(nonatomic, strong) id searchResult;
@property(nonatomic, strong) NSCountedSet* sectionResult;
@end
