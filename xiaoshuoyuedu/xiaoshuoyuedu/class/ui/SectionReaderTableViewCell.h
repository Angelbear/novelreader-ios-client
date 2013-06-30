//
//  SectionReaderTableViewCell.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SectionReaderTableViewCell : UITableViewCell
@property(nonatomic, strong) UILabel* labelView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withContentSize:(CGRect) rect fontSize:(CGFloat)size;
@end
