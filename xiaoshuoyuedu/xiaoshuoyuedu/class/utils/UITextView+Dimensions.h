//
//  UITextView+Dimensions.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-1.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Dimensions)
+ (CGFloat)heightWithText:(NSString *)text font:(UIFont *)font atWidth:(CGFloat)width;
@end
