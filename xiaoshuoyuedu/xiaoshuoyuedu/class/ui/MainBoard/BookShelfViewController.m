//
//  BookShelfViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-28.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "BookShelfViewController.h"
#import "DataBase.h"
#import "Book.h"
#import "Section.h"
#import "Common.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "BookView.h"
#import "BookShelfCellView.h"
#import "BelowBottomView.h"



@interface BookShelfViewController ()
@property(nonatomic, assign) NSUInteger _completedDownloadBooks;
@property(nonatomic, strong) NSMutableArray* _activeDownloadClients;
@end

@implementation BookShelfViewController
@synthesize bookShelfView = _bookShelfView;

- (id) init
{
    self = [super init];
    self.isRefreshing = NO;
    self._completedDownloadBooks = 0;
    self._activeDownloadClients = [NSMutableArray arrayWithCapacity:0];
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) stopAllDownloadTask {
    for (BookView* bookView in self.bookShelfView.visibleBookViews) {
        [bookView endDownload];
    }
    for (AFHTTPClient* client in self._activeDownloadClients) {
        [[client operationQueue] cancelAllOperations];
    }
    [self._activeDownloadClients removeAllObjects];
}

- (void) checkUpdateForAllBooks {
    [self showHUDWithCancel:@"正在更新书籍"];
    self._completedDownloadBooks = 0;
    [self._activeDownloadClients removeAllObjects];
    __weak BookShelfViewController* weakReferenceSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSString* baseURL = [NSString stringWithFormat:@"http://%@/", SERVER_HOST];
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
        [client.operationQueue setMaxConcurrentOperationCount:1];
        [weakReferenceSelf._activeDownloadClients addObject:client];
         NSMutableArray *operations = [NSMutableArray array];
        for (Book* book in self.books) {
            NSString* downloadUrl = [NSString stringWithFormat:@"http://%@/note/retrieve_sections?from=%@&url=%@", SERVER_HOST, book.from, [URLUtils uri_encode:book.url]];
            NSURL *url = [NSURL URLWithString:downloadUrl];
            NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3" forHTTPHeaderField:@"User-Agent"];
            
            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                if (JSON != nil && weakReferenceSelf !=nil) {
                    for (int i = 0; i < [JSON count]; i++) {
                        id sec = [JSON objectAtIndex:i];
                        Section* section = [[Section alloc] init];
                        section.book_id = book.book_id;
                        section.url = [sec valueForKey:@"url"];
                        section.from = book.from;
                        section.name = [sec valueForKey:@"name"];
                        section.text = @"";
                        if ([[DataBase get_database_instance] getSectionByUrl:section.url] == nil) {
                            [[DataBase get_database_instance] insertSection:section];
                        }
                    }
                }

            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                
            }];
            [operations addObject:operation];
        }
        [client enqueueBatchOfHTTPRequestOperations:operations
                                      progressBlock:^(NSUInteger numberOfCompletedOperations, NSUInteger totalNumberOfOperations) {
                                          if (weakReferenceSelf) {
                                              [weakReferenceSelf.HUD setLabelText:[NSString stringWithFormat:@"正在更新书籍 %d/%d", numberOfCompletedOperations, totalNumberOfOperations]];
                                          }
                                      } completionBlock:^(NSArray *operations) {
                                              [weakReferenceSelf.HUD hide:YES];
                                              [weakReferenceSelf downloadAllSectionsOfAllBooks];
                                      }];

    });
}

- (void) downloadAllSectionsOfAllBooks {
    [self showHUDWithCancel:@"正在更新章节"];
    self._completedDownloadBooks = 0;
    [self._activeDownloadClients removeAllObjects];
    __weak BookShelfViewController* weakReferenceSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSString* baseURL = [NSString stringWithFormat:@"http://%@/", SERVER_HOST];
        for (Book* book in self.books) {
            NSMutableArray* allSections = [[DataBase get_database_instance] getAllSectionsOfBook:book];
            NSMutableArray* downloadedSections = [[DataBase get_database_instance] getDownloadedSectionsOfBook:book];
            NSMutableArray* notDownloadedSections = [[DataBase get_database_instance] getNotDownloadedSectionsOfBook:book limit:[allSections count]];
            if ([notDownloadedSections count] == 0) {
                continue;
            }
            
            NSUInteger index = [weakReferenceSelf.books indexOfObject:book];
            // FIXME:
            BookView* bookView = (BookView*)[weakReferenceSelf.bookShelfView.visibleBookViews objectAtIndex:index];
            dispatch_async(dispatch_get_main_queue(), ^{
                [bookView beginDownload];
            });
            AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
            [client.operationQueue setMaxConcurrentOperationCount:1];
            [weakReferenceSelf._activeDownloadClients addObject:client];
  
            NSMutableArray *operations = [NSMutableArray array];
            for (Section *sec in notDownloadedSections) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/note/get_section?from=%@&url=%@", SERVER_HOST, sec.from, [URLUtils uri_encode:sec.url]]];

                NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
                [request setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3" forHTTPHeaderField:@"User-Agent"];
                
                AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    if (JSON != nil) {
                        sec.text = [JSON objectForKey:@"text"];
                        sec.name = [JSON objectForKey:@"title"];
                        [[DataBase get_database_instance] updateSection:sec];
                    }
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    
                }];
                [operations addObject:operation];
            }
            [client enqueueBatchOfHTTPRequestOperations:operations
                  progressBlock:^(NSUInteger numberOfCompletedOperations, NSUInteger totalNumberOfOperations) {
                      if (weakReferenceSelf) {
                          bookView.downloadProgressView.progress = (CGFloat)(numberOfCompletedOperations + [downloadedSections count]) / (CGFloat)([allSections count]);
                      }
                      if (numberOfCompletedOperations == totalNumberOfOperations) {
                          [bookView endDownload];
                      }
                  } completionBlock:^(NSArray *operations) {
                      weakReferenceSelf._completedDownloadBooks++;
                      if (weakReferenceSelf._completedDownloadBooks == [weakReferenceSelf.books count]) {
                          [weakReferenceSelf refresh:nil];
                      }
            }];
        }
        
    });
}


- (void)showHUDWithCancel:(NSString*) title {
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.labelText = title;
    [self.HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refresh:)]];
}

// an ivar for your class:
BOOL animating;

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         self.navigationItem.leftBarButtonItem.customView.transform = CGAffineTransformRotate(self.navigationItem.leftBarButtonItem.customView.transform, M_PI_2 );
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin {
    if (!animating) {
        animating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    animating = NO;
}

- (void) refresh:(id) sender {
    if (self.isRefreshing == YES) {
        [self stopSpin];
        [self stopAllDownloadTask];
        [self.HUD hide:YES];
        self.isRefreshing = NO;
    } else {
        self.isRefreshing = YES;
        [self checkUpdateForAllBooks];
        [self startSpin];
    }
}

- (void) enterEditMode:(id)sender {
    if (_editMode) {
        _editMode = NO;
        self.navigationItem.rightBarButtonItem = self.editButton;
        for (BookView *bookView in [_bookShelfView visibleBookViews]) {
            [bookView setEdited:NO];
        }
    }
    else {
        self.navigationItem.rightBarButtonItem = self.doneButton;
        _editMode = YES;
        for (BookView *bookView in [_bookShelfView visibleBookViews]) {
            [bookView setEdited:YES];
        }
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.books = [[DataBase get_database_instance] getAllBooks];
    [_bookShelfView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect deviceFrame = [UIScreen mainScreen].bounds;
    
    CGFloat width =  isLandscape ? deviceFrame.size.height : deviceFrame.size.width;
    CGFloat height =  isLandscape ? deviceFrame.size.width : deviceFrame.size.height;
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    [_searchBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    _belowBottomView = [[BelowBottomView alloc] initWithFrame:CGRectMake(0, 0, width, CELL_HEIGHT * 2)];
    [_belowBottomView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    _aboveTopView = [[BelowBottomView alloc] initWithFrame:CGRectMake(0, 0, width, CELL_HEIGHT * 2)];
    [_aboveTopView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    _bookShelfView = [[GSBookShelfView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [_bookShelfView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_bookShelfView setDataSource:self];
    
    [self.view addSubview:_bookShelfView];
    
    
    UIButton* refreshImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshImageButton setFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
    [refreshImageButton addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchDown];
    [refreshImageButton setImage:[UIImage imageNamed:@"bookshelf_update"] forState:UIControlStateNormal];
    
    
    UIButton *editImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editImageButton setFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
    [editImageButton addTarget:self action:@selector(enterEditMode:) forControlEvents:UIControlEventTouchUpInside];
    [editImageButton setImage:[UIImage imageNamed:@"bookshelf_edit"] forState:UIControlStateNormal];
    
    
    UIButton *doneImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneImageButton setFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
    [doneImageButton addTarget:self action:@selector(enterEditMode:) forControlEvents:UIControlEventTouchUpInside];
    [doneImageButton setImage:[UIImage imageNamed:@"bookshelf_ok"] forState:UIControlStateNormal];
    
    
    self.editButton = [[UIBarButtonItem alloc] initWithCustomView:editImageButton];
    self.doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneImageButton];
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    self.refreshButton = [[UIBarButtonItem alloc] initWithCustomView:refreshImageButton];
    [self.refreshButton setAction:@selector(refresh:)];
    self.navigationItem.leftBarButtonItem = self.refreshButton;
    
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [_bookShelfView oritationChangeReloadData];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
     [_bookShelfView didFinshRotation];
}

#pragma mark GSBookShelfViewDataSource

- (NSInteger)numberOfBooksInBookShelfView:(GSBookShelfView *)bookShelfView {
    return [self.books count];
}

- (NSInteger)numberOFBooksInCellOfBookShelfView:(GSBookShelfView *)bookShelfView {
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (UIDeviceOrientationIsLandscape(delegate.orientation)) {
        return isiPad ? 8 : (_bookShelfView.frame.size.width > 320.0f ? 4 : 3);
    }
    else {
        return isiPad ? 6 : 3;
    }
}

- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView bookViewAtIndex:(NSInteger)index {
    static NSString *identifier = @"bookView";
    Book* book = [self.books objectAtIndex:index];
    BookView *bookView = (BookView *)[bookShelfView dequeueReuseableBookViewWithIdentifier:identifier];
    if (bookView == nil) {
        bookView = [[BookView alloc] initWithFrame:CGRectMake(0, 0, 70, 100) book:book withCaller:self];
        bookView.reuseIdentifier = identifier;
    }
    [bookView setIndex:index];
    if (_editMode) {
        [bookView setEdited:YES];
    } else {
        [bookView setEdited:NO];
    }
    return bookView;
}

- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView cellForRow:(NSInteger)row {
    static NSString *identifier = @"cell";
    
    BookShelfCellView *cellView = (BookShelfCellView *)[bookShelfView dequeueReuseableCellViewWithIdentifier:identifier];
    if (cellView == nil) {
        cellView = [[BookShelfCellView alloc] initWithFrame:CGRectZero];
        [cellView setReuseIdentifier:identifier];
    }
    return cellView;
}

- (UIView *)aboveTopViewOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return _aboveTopView;
}

- (UIView *)belowBottomViewOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return _belowBottomView;
}

- (UIView *)headerViewOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return nil;
}

- (CGFloat)cellHeightOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return CELL_HEIGHT;
}

- (CGFloat)cellMarginOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 30.0f;
}

- (CGFloat)bookViewHeightOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 100.0f;
}

- (CGFloat)bookViewWidthOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 70.0f;
}

- (CGFloat)bookViewBottomOffsetOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return CELL_HEIGHT - 19.0f;
}

- (CGFloat)cellShadowHeightOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 55.0f;
}

- (void)bookShelfView:(GSBookShelfView *)bookShelfView moveBookFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    [self.books moveObjectFromIndex:fromIndex toIndex:toIndex];
    [_bookStatus moveObjectFromIndex:fromIndex toIndex:toIndex];
    
    
    BookView *bookView;
    bookView = (BookView *)[_bookShelfView bookViewAtIndex:toIndex];
    [bookView setIndex:toIndex];
    if (fromIndex <= toIndex) {
        for (int i = fromIndex; i < toIndex; i++) {
            bookView = (BookView *)[_bookShelfView bookViewAtIndex:i];
            [bookView setIndex:bookView.index - 1];
        }
    }
    else {
        for (int i = toIndex + 1; i <= fromIndex; i++) {
            bookView = (BookView *)[_bookShelfView bookViewAtIndex:i];
            [bookView setIndex:bookView.index + 1];
        }
    }
}

#pragma mark - BarButtonListener


#pragma mark - BookView Listener

- (void) deleteBook:(Book*)book withBookView:(BookView*)view {
    NSUInteger index = [self.books indexOfObject:book];
    NSIndexSet* set = [[NSIndexSet alloc] initWithIndex:index];
    if ([[DataBase get_database_instance] deleteBook:book] == YES) {
        [_bookShelfView removeBookViewsAtIndexs:set animate:YES];
        [self.books removeObject:book];
    }
}

@end
