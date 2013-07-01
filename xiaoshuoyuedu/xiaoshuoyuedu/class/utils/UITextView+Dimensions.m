//
//  UITextView+Dimensions.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-1.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "UITextView+Dimensions.h"

@implementation UITextView (Dimensions)

static const CGFloat marginAdjustment = 16.0;

+ (CGFloat)heightWithText:(NSString *)text font:(UIFont *)font atWidth:(CGFloat)width
{
    CGSize bounds = CGSizeMake(width - marginAdjustment, CGFLOAT_MAX);
    
    CGSize size = [text sizeWithFont:font
                   constrainedToSize:bounds
                       lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.height + marginAdjustment;
}

@end
