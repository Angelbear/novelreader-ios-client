//
//  SectionReaderTableViewCell.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontMenuViewController.h"

@class WEPopoverController;
@protocol SectionReaderMenuDelegate <NSObject>
- (void) clickFontMenuButton:(id) sender;
- (void) clickBacktoBookShelfButton:(id) sender;
@end

@interface SectionReaderTableViewCellViewController : UIViewController

@end

@interface SectionReaderTableViewCell : UITableViewCell
{
    BOOL _menuMode;
}
@property(nonatomic, weak) id<SectionReaderMenuDelegate> delegate;
@property(nonatomic, strong) IBOutlet UIView* contentView;
@property(nonatomic, strong) UITextView* textView;
@property(nonatomic, strong) IBOutlet UILabel* labelView;
@property(nonatomic, strong) IBOutlet UILabel* indexView;
@property(nonatomic, strong) IBOutlet UILabel* timeView;
@property(nonatomic, strong) UIButton* fontButton;
@property(nonatomic, strong) UIButton* mirrorButton;
@property(nonatomic, strong) WEPopoverController* popup;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier fontSize:(CGFloat)size;
- (void) toggleShowMenu:(id) sender;
@end
