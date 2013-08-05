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
#import "JSONRequestTableViewController.h"
@class Section;

@protocol ChangeSectionDelegate
- (void) nextSection;
- (void) prevSectionEnd;
- (void) prevSectionBegin;
- (void) downloadLaterSections;
@end


@interface SectionReaderTableViewController : JSONRequestTableViewController<SectionReaderMenuDelegate, FontMenuDelegate, WEPopoverControllerDelegate, UIGestureRecognizerDelegate> {
    BOOL _initialized;
    NSString* _fontName;
    CGFloat _fontSize;
    NSUInteger _themeIndex;
    BOOL _menuMode;
}
@property (nonatomic, strong) Section* section;
@property (nonatomic, strong) Bookmark* bookmark;
@property (nonatomic, strong) WEPopoverController* wePopupController;
@property (nonatomic, weak) id<ChangeSectionDelegate> delegate;
- (void) prepareForRead;
- (void) reloadSection;
- (void) moveToNextPage;
- (void) moveToPrevPage;
@end
