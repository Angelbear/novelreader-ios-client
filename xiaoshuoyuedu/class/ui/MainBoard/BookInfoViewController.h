//
//  BookInfoViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-25.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageView/AsyncImageView.h>
#import "Book.h"

@interface BookInfoViewController : UIViewController

- (id) initWithBookName:(NSString*)name author:(NSString*)author source:(NSString*)from url:(NSString*)url;
- (IBAction) clickDownloadBook:(id)sender;
- (IBAction) clickReadBook:(id)sender;

@property(nonatomic, strong) IBOutlet UILabel* authorNameLabel;
@property(nonatomic, strong) IBOutlet UILabel* siteNameLabel;
@property(nonatomic, strong) AsyncImageView* coverImageView;
@property(nonatomic, strong) IBOutlet UITextView* descriptionView;
@property(nonatomic, strong) IBOutlet UIButton* downloadButton;
@property(nonatomic, strong) IBOutlet UIButton* readButton;
@property(nonatomic, strong) Book* bookModel;
@property(nonatomic, strong) id bookInfo;
@end
