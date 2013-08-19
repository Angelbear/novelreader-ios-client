//
//  YLLabel.h
//  YLLabelDemo
//
//  Created by Eric Yuan on 12-11-8.
//  Copyright (c) 2012年 YuanLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVUserDefaults+Properties.h"
@interface ReaderTextLabel : UIView
{
    NSString* _text;
    NSMutableAttributedString* _string;
    UIFont* _font;
    UIColor* _textColor;
    BOOL _vertical;
    GVUserDefaults* _userDefaults;
    BOOL _beginParagraph;
}

@property (nonatomic, strong)NSMutableAttributedString* string;
@property (nonatomic, strong)UIFont* font;
@property (nonatomic, strong)UIColor* textColor;
@property (nonatomic, assign)BOOL beginParagraph;
@property (nonatomic, assign)BOOL vertical;

- (void)setText:(NSString*)text;
- (void)formatString;
@end
