//
//  SectionReaderTableViewCell.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontMenuViewController.h"
#import "YLLabel.h"
#import <QBKOverlayMenuView/QBKOverlayMenuView.h>

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

@interface SectionReaderTableViewCell : UITableViewCell<QBKOverlayMenuViewDelegate, UIGestureRecognizerDelegate>
{
    BOOL _menuMode;
}
@property(nonatomic, weak) id<SectionReaderMenuDelegate> delegate;
@property(nonatomic, strong) IBOutlet UIView* content;
@property(nonatomic, strong) UITextView* textView;
@property(nonatomic, strong) YLLabel* textLabelView;
@property(nonatomic, strong) IBOutlet UILabel* labelView;
@property(nonatomic, strong) IBOutlet UILabel* indexView;
@property(nonatomic, strong) IBOutlet UILabel* timeView;
@property(nonatomic, strong) IBOutlet UIButton* fontButton;
@property(nonatomic, strong) IBOutlet UIButton* refreshButton;
@property(nonatomic, strong) IBOutlet UIButton* mirrorButton;
@property(nonatomic, strong) IBOutlet UIButton* infoButton;
@property(nonatomic, strong) IBOutlet UIView* downloadPanel;
@property(nonatomic, strong) IBOutlet UIButton* downloadButton;
@property(nonatomic, strong) IBOutlet UIButton* downloadLaterButton;
@property(nonatomic, strong) IBOutlet UIView* dropDownMenuView;
@property(nonatomic, strong) IBOutlet UIToolbar* dropDownMenuToolbar;
@property(nonatomic, strong) UITapGestureRecognizer* tapRecognizer;
@property(nonatomic, strong) WEPopoverController* popup;
@property(nonatomic, strong) QBKOverlayMenuView* menuView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier fontSize:(CGFloat)size;
- (void) setNovelText:(NSString*)text;
- (void) showMenu:(BOOL)state;
- (void) setMenuState:(BOOL)state;
@end

@interface SectionReaderTableViewCellViewController : UIViewController
@property(nonatomic, strong) IBOutlet SectionReaderTableViewCell* cellView;
@end
