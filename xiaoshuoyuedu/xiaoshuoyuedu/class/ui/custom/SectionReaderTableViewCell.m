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
        CGRect deviceFrame = [UIScreen mainScreen].bounds;
        self.fontButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.fontButton.frame = CGRectMake(self.frame.origin.x + deviceFrame.size.width - 40, self.frame.origin.y, 20, 30.0f);
        [self.fontButton setImage:[UIImage imageNamed:@"AAglyp"] forState:UIControlStateNormal];
        [self.fontButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.fontButton addTarget:self action:@selector(tapOnFontSelectButton:) forControlEvents:UIControlEventTouchUpInside];
        self.fontButton.hidden = YES;
        
        
        self.mirrorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.mirrorButton.frame = CGRectMake(self.frame.origin.x + 20.0f, self.frame.origin.y, 20.0f, 30.0f);
        [self.mirrorButton setImage:[UIImage imageNamed:@"airplay"] forState:UIControlStateNormal];
        [self.mirrorButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.mirrorButton addTarget:self action:@selector(tapOnAirMirrorButton:) forControlEvents:UIControlEventTouchUpInside];
        self.mirrorButton.hidden = YES;
        
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + 20.0f, deviceFrame.size.width, deviceFrame.size.height - 35.0f)];
        self.textView.editable = NO;
        self.textView.userInteractionEnabled = NO;
        self.textView.scrollEnabled = NO;
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.contentInset = UIEdgeInsetsZero;
        self.textView.textAlignment = NSTextAlignmentLeft;
        self.textView.userInteractionEnabled = NO;
        
        [self addSubview:self.textView];
        [self addSubview:self.fontButton];
        [self addSubview:self.mirrorButton];
        
        [self setRestorationIdentifier:reuseIdentifier];
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


- (void)tapOnFontSelectButton:(id)sender {
    [self.delegate clickFontMenuButton:sender];
}

- (void)tapOnAirMirrorButton:(id)sender {
   
}

- (void) toggleShowMenu:(id) sender {
    _menuMode = !_menuMode;
    if (_menuMode) {
        self.labelView.hidden = YES;
        self.fontButton.hidden = NO;
        self.mirrorButton.hidden = NO;
    } else {
        self.labelView.hidden = NO;
        self.fontButton.hidden = YES;
        self.mirrorButton.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
