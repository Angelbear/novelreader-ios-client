//
//  SectionReaderTableViewCell.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "SectionReaderTableViewCell.h"

@implementation SectionReaderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withContentSize:(CGRect) rect fontSize:(CGFloat)size {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.labelView = [[UILabel alloc] initWithFrame:rect];
        self.labelView.font = [UIFont systemFontOfSize:size];
        self.labelView.textColor = [UIColor colorWithRed:0.254f green:0.1875f blue:0.0976f alpha:1.0f];
        self.labelView.userInteractionEnabled = NO;
        self.labelView.lineBreakMode = NSLineBreakByWordWrapping;
        self.labelView.numberOfLines = 0;
        self.labelView.backgroundColor = [UIColor colorWithRed:0.777f green:0.75f blue:0.65625f alpha:1.0f];
        [self.contentView addSubview:self.labelView];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
