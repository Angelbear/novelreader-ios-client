//
//  SectionReaderTableViewCell.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SectionReaderTableViewCellViewController : UIViewController

@end

@interface SectionReaderTableViewCell : UITableViewCell
@property(nonatomic, strong) IBOutlet UITextView* textView;
@property(nonatomic, strong) IBOutlet UILabel* labelView;
@property(nonatomic, strong) IBOutlet UILabel* indexView;
@property(nonatomic, strong) IBOutlet UILabel* timeView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier fontSize:(CGFloat)size;
@end
