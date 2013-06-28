//
//  BookInfoViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-25.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WTURLImageView/WTURLImageView.h>
#import "Book.h"

@interface BookInfoViewController : UIViewController

- (id) initWithBookName:(NSString*)name author:(NSString*)author source:(NSString*)from url:(NSString*)url;
- (IBAction) clickDownloadBook:(id)sender;
- (IBAction) clickBookmarkBook:(id)sender;

@property(nonatomic, strong) IBOutlet UILabel* bookNameLabel;
@property(nonatomic, strong) IBOutlet UILabel* authorNameLabel;
@property(nonatomic, strong) IBOutlet UILabel* siteNameLabel;
@property(nonatomic, strong) IBOutlet WTURLImageView* coverImageView;
@property(nonatomic, strong) IBOutlet UITextView* descriptionView;
@property(nonatomic, strong) id bookInfo;
@end
