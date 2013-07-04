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
@implementation SectionReaderTableViewCellViewController
@end

@implementation SectionReaderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier fontSize:(CGFloat)size {
    SectionReaderTableViewCellViewController* controller = [[SectionReaderTableViewCellViewController alloc] initWithNibName:@"SectionReaderTableViewCell" bundle:nil];
    
    self = (SectionReaderTableViewCell*)controller.view;
    if (self) {
        UIColor* brown = [UIColor colorWithRed:64.0/256.0 green:45.0/256.0 blue:23.0/256.0 alpha:1.0f];
        self.textView.textColor = brown;
        self.fontButton.imageView.image = [UIImage imageNamed:@"AAglyp"];
        [self.fontButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        self.fontButton.hidden = YES;
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

- (IBAction)topOnReturnToLibraryButton:(id)sender {
    [self.delegate clickBacktoBookShelfButton:sender];
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
