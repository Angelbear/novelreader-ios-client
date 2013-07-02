//
//  SectionReaderTableViewCell.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "SectionReaderTableViewCell.h"
@implementation SectionReaderTableViewCellViewController
@end

@implementation SectionReaderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier fontSize:(CGFloat)size {
    SectionReaderTableViewCellViewController* controller = [[SectionReaderTableViewCellViewController alloc] initWithNibName:@"SectionReaderTableViewCell" bundle:nil];
    
    self = (SectionReaderTableViewCell*)controller.view;
    if (self) {
        self.textView.font = [UIFont fontWithName:@"FZLTHJW--GB1-0" size:size];
        self.textView.textColor = [UIColor colorWithRed:64.0/256.0 green:45.0/256.0 blue:23.0/256.0 alpha:1.0f];
        //self.textView.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
        [self setRestorationIdentifier:reuseIdentifier];
    }
    return self;
}

- (void) reloadSection {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
