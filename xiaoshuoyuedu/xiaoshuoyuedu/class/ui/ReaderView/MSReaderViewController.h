//
//  MSReaderViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ViewDeck/IIViewDeckController.h>
#import "ReaderPagingViewController.h"
@class Book, Bookmark, IIViewDeckController, SectionReaderTableViewController;
@interface MSReaderViewController : UITableViewController<IIViewDeckControllerDelegate, ChangeSectionDelegate,UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, weak) IIViewDeckController *deckViewController;
@property (nonatomic, strong) ReaderPagingViewController* currentReaderViewController;
@property (nonatomic, strong) Book* book;
@property (nonatomic, strong) Bookmark* bookmark;
@property (nonatomic, strong) UISearchBar* searchBar;
@property (nonatomic, strong) UISearchDisplayController* strongSearchDisplayController;
- (void) loadBook:(Book*) book;
@end
