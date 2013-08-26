//
//  SectionPageView.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-7.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontMenuViewController.h"
#import "ReaderTextLabel.h"

@class WEPopoverController;
@protocol SectionReaderMenuDelegate <NSObject>
- (void) toggleMenuState:(BOOL) state;
- (void) clickFontMenuButton:(id) sender;
- (void) clickBacktoBookShelfButton:(id) sender;
- (void) clickRefreshButton:(id)sender;
- (void) clickDownloadLaterButton:(id)sender;
- (void) clickInfoButton:(id)sender;
- (void) moveToNextPage;
- (void) moveToPrevPage;
- (void) moveToNextSection;
- (void) moveToPrevSection;
@end

@interface SectionPageView : UIView<UIGestureRecognizerDelegate>
{
    BOOL _menuMode;
}
@property(nonatomic, unsafe_unretained) id<SectionReaderMenuDelegate> delegate;
@property(nonatomic, strong) IBOutlet ReaderTextLabel* textLabelView;
@property(nonatomic, strong) IBOutlet UILabel* labelView;
@property(nonatomic, strong) IBOutlet UILabel* indexView;
@property(nonatomic, strong) IBOutlet UILabel* timeView;
@property(nonatomic, strong) IBOutlet UIView* downloadPanel;
@property(nonatomic, strong) IBOutlet UIButton* downloadButton;
@property(nonatomic, strong) IBOutlet UIButton* downloadLaterButton;
@property(nonatomic, strong) IBOutlet UIToolbar* dropDownMenuToolbar;
@property(nonatomic, strong) IBOutlet UIBarButtonItem* deviceOrientationItem;
@property(nonatomic, strong) UITapGestureRecognizer* tapRecognizer;
@property(nonatomic, strong) IBOutlet UIView* blackView;
@property(nonatomic, strong) UIView* statusBackgroundView;
@property(nonatomic, strong) WEPopoverController* popup;
- (void) setNovelText:(NSString*)text;
- (void) setBeginParagraph:(BOOL)beginParagraph;
- (void) showMenu:(BOOL)state;
- (void) setMenuState:(BOOL)state;
- (void) toggleShowMenu:(id) sender;
@end

@interface SectionPageViewController : UIViewController
@property(nonatomic, strong) IBOutlet SectionPageView* contentView;
@end

