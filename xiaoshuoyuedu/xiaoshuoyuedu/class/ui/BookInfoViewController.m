//
//  BookInfoViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-25.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "BookInfoViewController.h"
#import "Common.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface BookInfoViewController ()

@property (nonatomic, strong) NSString* bookName;
@property (nonatomic, strong) NSString* authorName;
@property (nonatomic, strong) NSString* fromSite;
@property (nonatomic, strong) NSString* bookUrl;

@property (nonatomic, strong) UIImage* placeHolderImage;
@property (nonatomic, strong) AFJSONRequestOperation* currentOperation;

@end

@implementation BookInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithBookName:(NSString*)name author:(NSString*)author source:(NSString*)from url:(NSString*)url
{
    self = [super initWithNibName:@"BookInfoViewController" bundle:nil];
    self.bookName = name;
    self.fromSite = from;
    self.bookUrl = url;
    self.authorName = author;
    self.placeHolderImage = [UIImage imageNamed:@"placeholder.jpg"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bookNameLabel.text = self.bookName;
    self.authorNameLabel.text = [NSString stringWithFormat:@"作者：%@", self.authorName];
    self.siteNameLabel.text = [NSString stringWithFormat:@"来源：%@", self.fromSite];
    self.title = self.bookName;

    __unsafe_unretained BookInfoViewController* weakReferenceSelf = self;
    NSString* searchUrl = [NSString stringWithFormat:@"http://%@/note/get_book_info?from=%@&url=%@", SERVER_HOST, self.fromSite, [URLUtils uri_encode:self.bookUrl]];
    NSLog(@"%@", searchUrl);
    NSURL *url = [NSURL URLWithString:searchUrl];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3" forHTTPHeaderField:@"User-Agent"];
    self.currentOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (JSON != nil && weakReferenceSelf !=nil) {
            NSLog(@"%@", [JSON description]);
            if ([[JSON objectForKey:@"description"] isKindOfClass:[NSString class]]) {
                weakReferenceSelf.descriptionView.text = [JSON objectForKey:@"description"];
            } else {
                weakReferenceSelf.descriptionView.text = @"无";
            }
            if ([[JSON objectForKey:@"img"] isKindOfClass:[NSString class]]) {
                [self.coverImageView setURL:[NSURL URLWithString:[JSON objectForKey:@"img"]] fillType:UIImageResizeFillTypeFillIn options:WTURLImageViewOptionShowActivityIndicator | WTURLImageViewOptionsLoadDiskCacheInBackground placeholderImage:self.placeHolderImage failedImage:self.placeHolderImage diskCacheTimeoutInterval:30];
            } else {
                [self.coverImageView setImage:self.placeHolderImage];
            }
        }
        [MBProgressHUD hideHUDForView:weakReferenceSelf.navigationController.view animated:YES];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             NSLog(@"failure %@", [error localizedDescription]);
                                             [MBProgressHUD hideHUDForView:weakReferenceSelf.navigationController.view animated:YES];
                                         }];
    [self.currentOperation start];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

}

- (void) viewWillDisappear:(BOOL)animated {
    if ([self.currentOperation isExecuting]) {
        [self.currentOperation cancel];
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    }
}

#pragma button touch event handler

- (IBAction) clickDownloadBook:(id)sender {
    NSLog(@"clickDownloadBook");
}

- (IBAction) clickBookmarkBook:(id)sender {
    NSLog(@"clickBookmarkBook");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
