//
//  SectionReaderTableViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "SectionReaderTableViewController.h"
#import "SectionReaderTableViewCell.h"
#import "Section.h"
#import "FontUtils.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import "DataBase.h"
#import "Common.h"
#import "Bookmark.h"
#import <WEPopover/WEPopoverController.h>
#import "FontMenuViewController.h"
#import "ReaderCacheManager.h"
#import "DownloadManager.h"
@interface SectionReaderTableViewController ()

@property (nonatomic, strong) NSArray* splitInfo;
@property (nonatomic, assign) CGSize contentSize;
@end

@implementation SectionReaderTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init {
    self = [super initWithStyle:UITableViewStylePlain];
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CGRect deviceRect = delegate.currentWindow.screen.bounds;
    _initialized = NO;
    self.contentSize = CGSizeMake(deviceRect.size.width , deviceRect.size.height - 47.0f);
    self.splitInfo = [NSArray arrayWithObject:[NSArray arrayWithObjects:[NSNumber numberWithInt: 0], [NSNumber numberWithInt:0], nil]];
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"font-size"] != nil) {
        _fontSize = [[NSUserDefaults standardUserDefaults] floatForKey:@"font-size"];
    } else {
        [[NSUserDefaults standardUserDefaults] setFloat:DEFAULT_FONT_SIZE forKey:@"font-size"];
        _fontSize = DEFAULT_FONT_SIZE;
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"font-name"] != nil) {
        _fontName = [[NSUserDefaults standardUserDefaults] objectForKey:@"font-name"];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[UIFont systemFontOfSize:DEFAULT_FONT_SIZE].fontName forKey:@"font-name"];
        _fontName = [UIFont systemFontOfSize:DEFAULT_FONT_SIZE].fontName;
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    _themeIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"theme"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.pagingEnabled = YES;
    self.tableView.bounces = NO;
    self.tableView.alwaysBounceVertical = YES;
    
    UISwipeGestureRecognizer* swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didDragOnTableView:)];
    
    [swipeLeftGesture setDirection: UISwipeGestureRecognizerDirectionRight];
    [swipeLeftGesture setDelegate:self];
    [self.tableView addGestureRecognizer:swipeLeftGesture];
    
    if (self.section.text !=nil && [self.section.text length] > 0) {
        [self prepareForRead];
    } 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - custom functions


- (void)success:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response data:(id)JSON {
    [super success:request withReponse:response data:JSON];
    SectionReaderTableViewController* _self = (SectionReaderTableViewController*)_weakReferenceSelf;
    if (JSON != nil && _self != nil) {
        _self.section.text = [JSON objectForKey:@"text"];
        _self.bookmark.offset = 0;
        [DataBase updateBookMark:_self.bookmark];
        [DataBase updateSection:_self.section];
        [_self prepareForRead];
    }
}

- (void)failure:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response error:(NSError*)error data:(id)JSON {
    [super failure:request withReponse:response error:error data:JSON];

    SectionReaderTableViewController* _self = (SectionReaderTableViewController*)_weakReferenceSelf;
    if ( _self != nil && [_self.section.from isEqualToString:@"lixiangwenxue"] && error.code!= -999) {
        NSArray *parts = [_self.section.url componentsSeparatedByString:@"/"];
        NSString *filename = [parts objectAtIndex:[parts count]-1];
        NSUInteger section_id = [[filename stringByReplacingOccurrencesOfString:@".html" withString:@""] integerValue];
        section_id++;
        NSString* newPath = [NSString stringWithFormat:@"%@%d.html", [_self.section.url substringToIndex:[_self.section.url rangeOfString:filename options:NSBackwardsSearch].location] , section_id];
       NSString* searchUrl = [NSString stringWithFormat:@"http://%@/note/get_section?from=%@&url=%@", SERVER_HOST, self.section.from, [URLUtils uri_encode:newPath]];
        [_self loadJSONRequest:searchUrl type:NO];
    } else {
       if (_self.section.text == nil || _self.section.text.length == 0) {
           SectionReaderTableViewCell* cell = [[_self.tableView visibleCells] objectAtIndex:0];
           [cell setNovelText:@""];
       }
    }
}


- (void) reloadSection {
    if (self.section != nil) {
        if (self.section.text == nil || self.section.text.length == 0) {
            self.splitInfo = [NSArray arrayWithObject:[NSArray arrayWithObjects:[NSNumber numberWithInt: 0], [NSNumber numberWithInt:0], nil]];
        }
        [[ReaderCacheManager init_instance] deleteSplitInfo:self.section.section_id];
        [self.tableView reloadData];
        
        NSString* searchUrl = [NSString stringWithFormat:@"http://%@/note/get_section?from=%@&url=%@", SERVER_HOST, self.section.from, [URLUtils uri_encode:self.section.url]];
        [self loadJSONRequest:searchUrl type:NOVEL_DOWNLOAD_TASK_TYPE_SECTION];
    }
}

- (void) prepareForRead {
    if (self.section != nil && self.section.text != nil && self.section.text.length != 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        CGRect deviceRect = delegate.currentWindow.screen.bounds;
        self.contentSize = CGSizeMake(deviceRect.size.width , deviceRect.size.height - 47.0f);
        [self.tableView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            self.section.text = [NSString stringWithFormat:@"    %@", [self.section.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray* cachedInfo = [[ReaderCacheManager init_instance] getSplitInfo:self.section.section_id];
                if (cachedInfo) {
                    self.splitInfo = cachedInfo;
                } else {
                    self.splitInfo = [FontUtils findPageSplits:self.section.text size:self.contentSize font:[UIFont fontWithName:_fontName size:_fontSize]];
                    [[ReaderCacheManager init_instance] addSplitInfo:self.section.section_id splitInfo:self.splitInfo];
                }
                _initialized = NO;
                [self.tableView reloadData];
            });
        });
    } else {
        _initialized = NO;
        self.splitInfo = [NSArray arrayWithObject:[NSArray arrayWithObjects:[NSNumber numberWithInt: 0], [NSNumber numberWithInt:0], nil]];
        [self.tableView reloadData];
    }
}

- (void) moveToPrevPage {
    NSIndexPath* path = [self.tableView.indexPathsForVisibleRows objectAtIndex:0 ];
    if ( path.row == 0) {
        [self.delegate prevSection];
    } else {
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        CGFloat height = MAX(path.row - 1, 0) * delegate.currentWindow.screen.bounds.size.height;
        [self.tableView setContentOffset:CGPointMake(0.0f, height) animated:YES];
    }
}

- (void) moveToNextPage {
    NSIndexPath* path = [self.tableView.indexPathsForVisibleRows objectAtIndex:0 ];
    if (path.row == [self.splitInfo count] - 1) {
        [self.delegate nextSection];
    } else {
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        CGFloat height = MIN(path.row + 1, [self.splitInfo count] - 1) * delegate.currentWindow.screen.bounds.size.height;
        [self.tableView setContentOffset:CGPointMake(0.0f, height) animated:YES];
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        UISwipeGestureRecognizer* recognizer = (UISwipeGestureRecognizer*) gestureRecognizer;
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if (recognizer.direction == UISwipeGestureRecognizerDirectionRight && [delegate isReaderRightPanelOpen] == NO) {
            return YES;
        }
    }
    return NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath* path = [self.tableView.indexPathsForVisibleRows objectAtIndex:0 ];
    [self autoSaveBookmark:path.row];
}

-(void) autoSaveBookmark:(NSUInteger)index {
    self.bookmark.section_id = self.section.section_id;
    NSArray* split = [self.splitInfo objectAtIndex:index];
    self.bookmark.offset = [[split objectAtIndex:0] intValue];
    [DataBase updateBookMark:self.bookmark];
}

-(void) didDragOnTableView:(UISwipeGestureRecognizer*) recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if ([delegate isReaderRightPanelOpen] == NO) {
            [delegate switchToNavitation];
        }
    }
}

-(void) setContentOffset:(NSNumber*)height {
    [self.tableView setContentOffset:CGPointMake(0.0f, [height floatValue]) animated:NO];
}

#pragma mark - SectionReaderMenuDelegate

- (void) clickInfoButton:(id)sender {
    
}

- (void) clickRefreshButton:(id)sender {
    [self reloadSection];
}

- (void) clickDownloadLaterButton:(id)sender {
    [self reloadSection];
    [self.delegate downloadLaterSections];
}

- (void) clickFontMenuButton:(id) sender {
    FontMenuViewController* fontMenuViewController = [[FontMenuViewController alloc] initWithNibName:@"FontMenuViewController" bundle:nil];
    fontMenuViewController.delegate = self;
    SectionReaderTableViewCell *cell = (SectionReaderTableViewCell*)[[self.tableView visibleCells] objectAtIndex:0];
    self.wePopupController = [[WEPopoverController alloc] initWithContentViewController:fontMenuViewController];
    self.wePopupController.delegate = self;
    self.wePopupController.popoverContentSize = fontMenuViewController.view.frame.size;
    UIView* source = (UIView*) sender;
    [self.wePopupController presentPopoverFromRect:source.frame inView:cell permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) clickBacktoBookShelfButton:(id) sender {
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate switchToNavitation];
}

#pragma mark - WEPopoverControllerDelegate 
- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController {
    
}
- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController {
    return YES;
}

#pragma mark - FontMenuDelegate
- (void) increaseFontSize {
    _fontSize =  [[NSUserDefaults standardUserDefaults] floatForKey:@"font-size"];
    [self prepareForRead];
}

- (void) decreaseFontSize {
    _fontSize =  [[NSUserDefaults standardUserDefaults] floatForKey:@"font-size"];
    [self prepareForRead];
}

- (void) changeFont:(NSString*) fontName {
    _fontName = fontName;
    [self prepareForRead];
}

- (void) changeTheme:(NSUInteger) themeIndex {
    _themeIndex = themeIndex;
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_initialized) {
        if (self.section != nil && self.section.text!=nil && [self.section.text length] > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                NSUInteger indexForJump = 0;
                for (indexForJump = 0; indexForJump < [self.splitInfo count]; indexForJump++) {
                    if (self.bookmark.offset < [[[self.splitInfo objectAtIndex:indexForJump] objectAtIndex:0] intValue]) {
                        indexForJump --;
                        break;
                    }
                }
                AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                CGFloat height = MIN(indexForJump, [self.splitInfo count] - 1) * delegate.currentWindow.screen.bounds.size.height;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView setContentOffset:CGPointMake(0.0f, height) animated:NO];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
               _initialized = YES;
            });
        } else {
            SectionReaderTableViewCell* readerCell = (SectionReaderTableViewCell*)cell;
            [readerCell setNovelText:@""];
            _initialized = YES;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.splitInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell-%lf-%lf",  delegate.currentBookView.bounds.size.width,  delegate.currentBookView.bounds.size.height];
    
    SectionReaderTableViewCell *cell = (SectionReaderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SectionReaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier fontSize:_fontSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
     }
    NSArray* split = [self.splitInfo objectAtIndex:indexPath.row];
    
    cell.content.backgroundColor = [THEME_COLORS objectAtIndex:_themeIndex];
    //cell.textView.textColor = [FONT_COLORS objectAtIndex:_themeIndex];
    //cell.textView.font = [UIFont fontWithName:_fontName size:_fontSize];
    cell.textLabelView.textColor = [FONT_COLORS objectAtIndex:_themeIndex];
    cell.textLabelView.font = [UIFont fontWithName:_fontName size:_fontSize];
    
    if (self.section.text != nil && self.section.text.length > 0) {
        [cell setNovelText:[self.section.text substringWithRange:NSMakeRange([[split objectAtIndex:0] intValue], [[split objectAtIndex:1] intValue])]];
    }
    cell.labelView.text = self.section.name;
    cell.indexView.text = [NSString stringWithFormat:@"第%d/%d页", indexPath.row + 1, [self.splitInfo count]];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return delegate.currentWindow.screen.bounds.size.height;
}

@end
