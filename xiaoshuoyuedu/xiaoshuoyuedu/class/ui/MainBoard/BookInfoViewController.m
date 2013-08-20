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
#import "DataBase.h"
#import "Section.h"
#import "AppDelegate.h"
#import "DownloadManager.h"
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
    self.placeHolderImage = [UIImage imageNamed:@"placeholder"];
    self.bookModel = [[Book alloc] init];
    return self;
}

- (void) adjustView {
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CGRect deviceFrame = (delegate.orientation == UIInterfaceOrientationPortrait) ? [UIScreen mainScreen].bounds : CGRectRotate([UIScreen mainScreen].bounds);
    self.view.frame = deviceFrame;
    self.coverImageView.frame = CGRectMake(20.0f, 20.0f, 100.0f, 300.0f);
    self.coverImageView.layer.borderWidth = 1;
    self.bookNameLabel.frame = CGRectSetXY(20.0f + self.coverImageView.frame.size.width + 20.0f, 20.0f, self.bookNameLabel.frame);
    self.authorNameLabel.frame = CGRectSetXY(20.0f + self.coverImageView.frame.size.width + 20.0f, self.bookNameLabel.frame.origin.y + self.bookNameLabel.frame.size.height + 10.0f, self.authorNameLabel.frame);
    self.siteNameLabel.frame = CGRectSetXY(20.0f + self.coverImageView.frame.size.width + 20.0f, self.authorNameLabel.frame.origin.y + self.authorNameLabel.frame.size.height + 10.0f, self.siteNameLabel.frame);;

}

- (void) onDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self adjustView];
    [self.downloadButton setHidden:YES];
    [self.readButton removeFromSuperview];
    self.bookNameLabel.text = self.bookName;
    self.descriptionView.font = isiPad ? [UIFont systemFontOfSize:20.0f] : [UIFont systemFontOfSize:14.0f];
    self.authorNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"authorplaceholder", @""), self.authorName];
    self.siteNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"fromplaceholder", @""), self.fromSite];
    self.title = self.bookName;
    
    if (self.navigationController!=nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                                              target:self
                                                                                                              action:@selector(onDismiss)];
    }

    NSString* searchUrl = [NSString stringWithFormat:@"http://%@/note/get_book_info?from=%@&url=%@", SERVER_HOST, self.fromSite, [URLUtils uri_encode:self.bookUrl]];
    __unsafe_unretained BookInfoViewController* weakReferenceSelf = self;
    [[DownloadManager init_instance] addDownloadTask:NOVEL_DOWNLOAD_TASK_TYPE_BOOK_INFO url:searchUrl piority:NSOperationQueuePriorityVeryHigh success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (JSON != nil) {
            weakReferenceSelf.bookInfo = JSON;
            if ([[JSON objectForKey:@"description"] isKindOfClass:[NSString class]]) {
                weakReferenceSelf.descriptionView.text = [JSON objectForKey:@"description"];
            } else {
                weakReferenceSelf.descriptionView.text = NSLocalizedString(@"none", @"");
            }
            if ([[JSON objectForKey:@"img"] isKindOfClass:[NSString class]]) {
                [weakReferenceSelf.coverImageView setURL:[NSURL URLWithString:[JSON objectForKey:@"img"]] fillType:UIImageResizeFillTypeFitIn options:WTURLImageViewOptionShowActivityIndicator | WTURLImageViewOptionsLoadDiskCacheInBackground placeholderImage:self.placeHolderImage failedImage:weakReferenceSelf.placeHolderImage diskCacheTimeoutInterval:30];
            } else {
                [weakReferenceSelf.coverImageView setImage:weakReferenceSelf.placeHolderImage];
            }
            
            NSString* url = [JSON objectForKey:@"url"];
            Book* book = [[DataBase get_database_instance] getBookByUrl:url];
            if (book != nil) {
                weakReferenceSelf.bookModel = book;
                [weakReferenceSelf.downloadButton removeFromSuperview];
                [weakReferenceSelf.view addSubview:self.readButton];
            } else {
                [weakReferenceSelf.downloadButton setHidden:NO];
            }
        }
        [MBProgressHUD hideHUDForView:weakReferenceSelf.view animated:YES];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, id data, NSError *error) {
        [MBProgressHUD hideHUDForView:weakReferenceSelf.view animated:YES];
    }];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    if ([self.currentOperation isExecuting]) {
        [self.currentOperation cancel];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

#pragma button touch event handler

- (IBAction) clickDownloadBook:(id)sender {
    if (self.bookInfo == nil) {
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    // Step 1: Insert book info into db
    self.bookModel.name = self.bookName;
    self.bookModel.from = self.fromSite;
    self.bookModel.author = self.authorName;
    self.bookModel.url   = [self.bookInfo objectForKey:@"url"];
    if ([self.coverImageView image] != nil) {
        self.bookModel.cover = [self.coverImageView image];
    } else {
        self.bookModel.cover = self.placeHolderImage;
    }
    
    // Step 2: Download section info
    __weak BookInfoViewController* weakReferenceSelf = self;
    NSString* searchUrl = [NSString stringWithFormat:@"http://%@/note/retrieve_sections?from=%@&url=%@", SERVER_HOST, self.fromSite, [URLUtils uri_encode:self.bookModel.url]];
    [[DownloadManager init_instance] addDownloadTask:NOVEL_DOWNLOAD_TASK_TYPE_BOOK_INFO url:searchUrl piority:NSOperationQueuePriorityVeryHigh success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (JSON != nil && weakReferenceSelf !=nil) {
            NSUInteger book_id = [[DataBase get_database_instance] insertBook:weakReferenceSelf.bookModel];
            weakReferenceSelf.bookModel.book_id = book_id;
            
            NSMutableArray* sections = [[NSMutableArray alloc] init];
            for (int i = 0; i < [JSON count]; i++) {
                id sec = [JSON objectAtIndex:i];
                Section* section = [[Section alloc] init];
                section.book_id = weakReferenceSelf.bookModel.book_id;
                section.url = [sec valueForKey:@"url"];
                section.from = weakReferenceSelf.fromSite;
                section.name = [sec valueForKey:@"name"];
                section.text = @"";
                section.from = weakReferenceSelf.fromSite;
                [sections addObject:section];
            }
            
            if ([sections count] > 0) {
                [[DataBase get_database_instance] insertSections:sections];
                [[DataBase get_database_instance] createDefaultBookMark:weakReferenceSelf.bookModel];
                [self.downloadButton removeFromSuperview];
                [self.view addSubview:self.readButton];
            } else {
                [[DataBase get_database_instance] deleteBook:weakReferenceSelf.bookModel];
            }
        }
        [MBProgressHUD hideHUDForView:weakReferenceSelf.view animated:YES];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, id data, NSError *error) {
        [MBProgressHUD hideHUDForView:weakReferenceSelf.view animated:YES];
    }];
}

- (IBAction) clickReadBook:(id)sender {
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate switchToReader:self.bookModel];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
