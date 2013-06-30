//
//  BookShelfViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-28.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "GSBookShelfView.h"

@class MyBelowBottomView;
@class BelowBottomView;
@class AboveTopView;

@interface BookShelfViewController : UIViewController <GSBookShelfViewDelegate, GSBookShelfViewDataSource> {
    GSBookShelfView *_bookShelfView;
    
    NSMutableArray *_bookStatus;
    BOOL _editMode;
    
    BelowBottomView *_belowBottomView;
    BelowBottomView* _aboveTopView;
    UISearchBar *_searchBar;
}
@property(nonatomic, strong) NSMutableArray* books;
@property(nonatomic, strong) UIBarButtonItem* editButton;
@property(nonatomic, strong) UIBarButtonItem* doneButton;
@property(nonatomic, strong) UIBarButtonItem* refreshButton;
@property(nonatomic, strong) MBProgressHUD* HUD;
@property(nonatomic, assign) NSUInteger isRefreshing;
@end
