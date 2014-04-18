//
//  BookInfoViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-25.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "BookInfoViewController.h"
#import "Common.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Section.h"
#import "AppDelegate.h"
#import "DownloadManager.h"
#import <AsyncImageView/AsyncImageView.h>

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
    CGRect deviceFrame = isiPad ? CGRectMake(0, 0, 540, 620) : ((delegate.orientation == UIInterfaceOrientationPortrait) ? [UIScreen mainScreen].bounds : CGRectRotate([UIScreen mainScreen].bounds));
    
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.coverImageView.activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
    self.authorNameLabel.frame = CGRectMake(20.0f + self.coverImageView.frame.size.width + 20.0f, 20.0f,deviceFrame.size.width - self.coverImageView.frame.size.width - 40.0f , self.authorNameLabel.frame.size.height);
    self.siteNameLabel.frame = CGRectMake(20.0f + self.coverImageView.frame.size.width + 20.0f, self.authorNameLabel.frame.origin.y + self.authorNameLabel.frame.size.height + 10.0f,deviceFrame.size.width - self.coverImageView.frame.size.width - 40.0f , self.siteNameLabel.frame.size.height);
    self.downloadButton.frame = CGRectSetXY(20.0f + self.coverImageView.frame.size.width + 20.0f, self.coverImageView.frame.origin.y + self.coverImageView.frame.size.height - self.downloadButton.frame.size.height, self.downloadButton.frame);
    self.readButton.frame = self.downloadButton.frame;

    self.descriptionView.frame = CGRectMake(10.0f, self.coverImageView.frame.origin.y + self.coverImageView.frame.size.height + 10.0f, deviceFrame.size.width - 20.0f, deviceFrame.size.height - self.coverImageView.frame.size.height - 40.0f - [[self.navigationController navigationBar] frame].size.height - 20.0f);

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self adjustView];
}

- (void) onDismiss {
    [self.parentViewController dismissViewControllerAnimated:NO completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.coverImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 100.0f, 140.0f)];
    [self.view addSubview:self.coverImageView];
    
    [self adjustView];
    [self.downloadButton setHidden:YES];
    [self.readButton removeFromSuperview];
    self.title = self.bookName;
    self.descriptionView.font = isiPad ? [UIFont systemFontOfSize:20.0f] : [UIFont systemFontOfSize:16.0f];
    self.authorNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"authorplaceholder", @""), self.authorName];
    self.siteNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"fromplaceholder", @""), self.fromSite];
    
    if (isiPad) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                              target:self
                                                                                                              action:@selector(onDismiss)];
    }

    NSString* searchUrl = [NSString stringWithFormat:@"http://%@/note/get_book_info?from=%@&url=%@", SERVER_HOST, self.fromSite, [URLUtils uri_encode:self.bookUrl]];
    __unsafe_unretained BookInfoViewController* weakReferenceSelf = self;
    [[DownloadManager init_instance] addDownloadTask:NOVEL_DOWNLOAD_TASK_TYPE_BOOK_INFO url:searchUrl piority:NSOperationQueuePriorityVeryHigh success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (JSON != nil && weakReferenceSelf != nil) {
            weakReferenceSelf.bookInfo = JSON;
            if ([[JSON objectForKey:@"description"] isKindOfClass:[NSString class]]) {
                weakReferenceSelf.descriptionView.text = [JSON objectForKey:@"description"];
            } else {
                weakReferenceSelf.descriptionView.text = NSLocalizedString(@"none", @"");
            }
            if ([[JSON objectForKey:@"img"] isKindOfClass:[NSString class]]) {
                [weakReferenceSelf.coverImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[JSON objectForKey:@"img"]]] placeholderImage:self.placeHolderImage  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                }];
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
    __unsafe_unretained BookInfoViewController* weakReferenceSelf = self;
    NSString* searchUrl = [NSString stringWithFormat:@"http://%@/note/retrieve_sections?from=%@&url=%@", SERVER_HOST, self.fromSite, [URLUtils uri_encode:self.bookModel.url]];
    [[DownloadManager init_instance] addDownloadTask:NOVEL_DOWNLOAD_TASK_TYPE_BOOK_INFO url:searchUrl piority:NSOperationQueuePriorityVeryHigh success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (JSON != nil && weakReferenceSelf !=nil) {
            NSUInteger book_id = [[DataBase get_database_instance] insertBook:weakReferenceSelf.bookModel];
            weakReferenceSelf.bookModel.book_id = @(book_id);
            
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
    [self onDismiss];
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate switchToReader:self.bookModel];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
