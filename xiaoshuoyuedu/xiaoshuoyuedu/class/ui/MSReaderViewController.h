//
//  MSReaderViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ViewDeck/IIViewDeckController.h>
#import "SectionReaderTableViewController.h"

@class Book, Bookmark, IIViewDeckController, SectionReaderTableViewController;
@interface MSReaderViewController : UITableViewController<IIViewDeckControllerDelegate, ChangeSectionDelegate>

@property (nonatomic, weak) IIViewDeckController *deckViewController;
@property (nonatomic, weak) SectionReaderTableViewController* currentReaderViewController;
@property (nonatomic, strong) Book* book;
@property (nonatomic, strong) Bookmark* bookmark;
- (void) loadBook:(Book*) book;
@end
