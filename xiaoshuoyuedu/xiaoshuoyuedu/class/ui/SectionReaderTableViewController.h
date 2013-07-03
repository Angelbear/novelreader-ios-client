//
//  SectionReaderTableViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bookmark.h"
#import "SectionReaderTableViewCell.h"
#import <WEPopover/WEPopoverController.h>
#import "FontMenuViewController.h"
@class Section;
@interface SectionReaderTableViewController : UITableViewController<SectionReaderMenuDelegate, FontMenuDelegate, UIPopoverControllerDelegate, WEPopoverControllerDelegate> {
    BOOL _initialized;
    CGFloat _fontSize;
}
@property (nonatomic, strong) Section* section;
@property (nonatomic, strong) Bookmark* bookmark;
@property (nonatomic, strong) UIPopoverController* popupController;
@property (nonatomic, strong) WEPopoverController* wePopupController;
@end
