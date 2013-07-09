//
//  SectionReaderTableViewCell.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "SectionReaderTableViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import <WEPopover/WEPopoverViewController.h>
#import <CoreText/CoreText.h>
@implementation SectionReaderTableViewCellViewController
@end

@implementation SectionReaderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier fontSize:(CGFloat)size {
    SectionReaderTableViewCellViewController* controller = [[SectionReaderTableViewCellViewController alloc] initWithNibName:@"SectionReaderTableViewCell" bundle:nil];
    
    self = (SectionReaderTableViewCell*)controller.view;
    if (self) {
        self.fontButton.imageView.image = [UIImage imageNamed:@"AAglyp"];
        [self.fontButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        self.fontButton.hidden = YES;
        [self setRestorationIdentifier:reuseIdentifier];
        self.textView.contentInset = UIEdgeInsetsZero;  
        _menuMode = NO;
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dataComps = [gregorianCal components: (NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                  fromDate: [NSDate date]];
    
    self.timeView.text = [NSString stringWithFormat:@"%02d:%02d", [dataComps hour], [dataComps minute]];
}


- (NSMutableAttributedString*) getTextContent:(NSString*)text {
    if (text==nil) {
        return nil;
    }
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] initWithString:text];
    CTFontRef helveticaBold = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName,self.font.pointSize,NULL);
    [string addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)helveticaBold range:NSMakeRange(0,[string length])];
    //设置字间距

    long number = 2;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
    [string addAttribute:(NSString *)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0,[string length])];
    CFRelease(num);

    //设置字体颜色
    [string addAttribute:(id)kCTForegroundColorAttributeName value:(id)(self.textColor.CGColor) range:NSMakeRange(0,[string length])];
    //创建文本对齐方式
    CTTextAlignment alignment = kCTLeftTextAlignment;
    CTParagraphStyleSetting alignmentStyle;
    alignmentStyle.spec = kCTParagraphStyleSpecifierAlignment;
    alignmentStyle.valueSize = sizeof(alignment);
    alignmentStyle.value = &alignment;
    //设置文本行间距
    CGFloat lineSpace = 5.0;
    CTParagraphStyleSetting lineSpaceStyle;
    lineSpaceStyle.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    lineSpaceStyle.valueSize = sizeof(lineSpace);
    lineSpaceStyle.value =&lineSpace;
    //设置文本段间距
    CGFloat paragraphSpacing = 5.0;
    CTParagraphStyleSetting paragraphSpaceStyle;
    paragraphSpaceStyle.spec = kCTParagraphStyleSpecifierParagraphSpacing;
    paragraphSpaceStyle.valueSize = sizeof(CGFloat);
    paragraphSpaceStyle.value = &paragraphSpacing;
    
    //创建设置数组
    CTParagraphStyleSetting settings[ ] ={alignmentStyle,lineSpaceStyle,paragraphSpaceStyle};
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings ,3);
    //给文本添加设置
    [string addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)style range:NSMakeRange(0 , [string length])];
    return string;
}

- (void) setTextContent:(NSString*)text {
    self.textView.attributedText = [self getTextContent:text];
}


- (IBAction)topOnFontSelectButton:(id)sender {
    [self.delegate clickFontMenuButton:sender];
}

- (void) toggleShowMenu:(id) sender {
    _menuMode = !_menuMode;
    if (_menuMode) {
        self.labelView.hidden = YES;
        self.fontButton.hidden = NO;
    } else {
        self.labelView.hidden = NO;
        self.fontButton.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
