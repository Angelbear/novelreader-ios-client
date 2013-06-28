//
//  BookItemTableViewCell.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-28.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookItemTableViewCell : UITableViewCell

@property(nonatomic, strong) UIProgressView *dlProgress;
- (void) setProgress:(CGFloat)process;
@end
