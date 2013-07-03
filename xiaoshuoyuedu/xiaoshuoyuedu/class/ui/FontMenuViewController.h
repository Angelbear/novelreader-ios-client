//
//  FontMenuViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-3.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FontMenuDelegate <NSObject>
- (void) increaseFontSize;
- (void) decreaseFontSize;
- (void) changeFont:(NSString*) fontName;
- (void) changeTheme:(NSString*) themeName;
@end

@interface FontMenuViewController : UIViewController<UITableViewDelegate, UITableViewDelegate>
{
    NSString* _fontName;
    CGFloat _fontSize;
    NSUInteger _selectedIndex;
}
@property (nonatomic, strong) IBOutlet UIButton* brightButton;
@property (nonatomic, strong) IBOutlet UIButton* fontButton;
@property (nonatomic, strong) IBOutlet UIButton* themeButton;
@property (nonatomic, strong) IBOutlet UIButton* decButton;
@property (nonatomic, strong) IBOutlet UIButton* incButton;
@property (nonatomic, strong) IBOutlet UISlider* brightSlider;
@property (nonatomic, weak) id<FontMenuDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView* fontSelectView;
@end
