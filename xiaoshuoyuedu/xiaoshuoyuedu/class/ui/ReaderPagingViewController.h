//
//  ReaderPagingView.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-7.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "ATPagingView.h"
#import <WEPopover/WEPopoverController.h>
#import "FontMenuViewController.h"
#import "JSONRequestTableViewController.h"
#import "SectionPageView.h"

@class Section, Bookmark;

@protocol ChangeSectionDelegate
- (void) nextSection;
- (void) prevSectionEnd;
- (void) prevSectionBegin;
- (void) downloadLaterSections;
@end

@interface ReaderPagingViewController : ATPagingViewController<SectionReaderMenuDelegate, FontMenuDelegate, WEPopoverControllerDelegate, UIGestureRecognizerDelegate>
{
    BOOL _initialized;
    NSString* _fontName;
    CGFloat _fontSize;
    NSUInteger _themeIndex;
    BOOL _menuMode;
}
@property (nonatomic, strong) Section* section;
@property (nonatomic, strong) Bookmark* bookmark;
@property (nonatomic, strong) WEPopoverController* wePopupController;
@property (nonatomic, weak) id<ChangeSectionDelegate> change_section_delegate;
- (void) prepareForRead;
- (void) reloadSection;
- (void) moveToNextPage;
- (void) moveToPrevPage;
@end
