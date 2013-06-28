//
//  BookItemTableViewCell.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-28.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "BookItemTableViewCell.h"

@implementation BookItemTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.dlProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.dlProgress.frame = CGRectMake(self.frame.size.width-150, 20, 140, 9);
        self.dlProgress.progress = 0.0;
        [self.contentView addSubview:self.dlProgress];
    }
    return self;
}

- (void) setProgress:(CGFloat)process {
    self.dlProgress.progress = process;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
