//
//  ReaderPagingView.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-7.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "ReaderPagingViewController.h"
#import "SectionPageView.h"
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
#import <QuartzCore/QuartzCore.h>
#import "ATPagingView.h"

@interface ReaderPagingViewController ()

@property (nonatomic, strong) NSArray* splitInfo;
@end

@implementation ReaderPagingViewController

- (id) init {
    self = [super init];
    if (self) {
        _initialized = NO;
        self.userDefaults = [GVUserDefaults standardUserDefaults];
        self.splitInfo = [NSArray arrayWithObject:[NSArray arrayWithObjects:[NSNumber numberWithInt: 0], [NSNumber numberWithInt:0], [NSNumber numberWithBool:NO], nil]];
    }
    return self;
};

- (void) viewDidLoad {
    [super viewDidLoad];
    self.pagingView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.pagingView.horizontal = NO;
    self.pagingView.gapBetweenPages = 0.0f;
    self.pagingView.recyclingEnabled = NO;
    self.pagingView.pagesToPreload = 0;
    
    FontMenuViewController* fontMenuViewController = [[FontMenuViewController alloc] initWithNibName:@"FontMenuViewController" bundle:nil];
    fontMenuViewController.delegate = self;
    self.wePopupController = [[WEPopoverController alloc] initWithContentViewController:fontMenuViewController];
    self.wePopupController.delegate = self;
    self.wePopupController.popoverContentSize = fontMenuViewController.view.frame.size;
    
    UISwipeGestureRecognizer* swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didDragOnTableView:)];
    
    [swipeLeftGesture setDirection: UISwipeGestureRecognizerDirectionRight];
    [swipeLeftGesture setDelegate:self];
    [self.pagingView addGestureRecognizer:swipeLeftGesture];

    if (self.section.text !=nil && [self.section.text length] > 0) {
        [self prepareForRead];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return self.userDefaults.fixedOrientation;
}

- (BOOL)shouldAutorotate {
    return (self.userDefaults.orientationLocked == NO);
}

- (NSUInteger)supportedInterfaceOrientations {
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    SectionPageView* page = (SectionPageView*)[self.pagingView viewForPageAtIndex:self.pagingView.firstVisiblePageIndex];
    _menuMode = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [page showMenu:NO];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    /*
    CGFloat width = (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) ?  [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;
    SectionPageView* page = (SectionPageView*)[self.pagingView viewForPageAtIndex:self.pagingView.firstVisiblePageIndex];
    [UIView beginAnimations:@"orientation" context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:self];
    page.dropDownMenuToolbar.frame = CGRectMake(0, 20.0f, width, 44.0f);
    [UIView commitAnimations];*/
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.pagingView reloadData];
    [[ReaderCacheManager init_instance] clearAllSplitInfos];
    [self prepareForRead];
}


#pragma mark - custom functions


- (void)success:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response data:(id)JSON {
    [super success:request withReponse:response data:JSON];
    if (JSON != nil) {
        self.section.text = [JSON objectForKey:@"text"];
        self.bookmark.offset = 0;
        [[DataBase get_database_instance] updateBookMark:self.bookmark];
        [[DataBase get_database_instance] updateSection:self.section];
        [self prepareForRead];
    }
}

- (void)failure:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response error:(NSError*)error data:(id)JSON {
    [super failure:request withReponse:response error:error data:JSON];
    
    if ( self != nil && [self.section.from isEqualToString:@"lixiangwenxue"] && error.code!= -999) {
        NSArray *parts = [self.section.url componentsSeparatedByString:@"/"];
        NSString *filename = [parts objectAtIndex:[parts count]-1];
        NSUInteger section_id = [[filename stringByReplacingOccurrencesOfString:@".html" withString:@""] integerValue];
        section_id++;
        NSString* newPath = [NSString stringWithFormat:@"%@%d.html", [self.section.url substringToIndex:[self.section.url rangeOfString:filename options:NSBackwardsSearch].location] , section_id];
        NSString* searchUrl = [NSString stringWithFormat:@"http://%@/note/get_section?from=%@&url=%@", SERVER_HOST, self.section.from, [URLUtils uri_encode:newPath]];
        [self loadJSONRequest:searchUrl type:NO];
    } else {
        if (self.section.text == nil || self.section.text.length == 0) {
            SectionPageView* view = (SectionPageView*)[self.pagingView viewForPageAtIndex:self.pagingView.firstVisiblePageIndex];
            [view setNovelText:@""];
        }
    }
}

- (void) reloadSection {
    if (self.section != nil) {
        if (self.section.text == nil || self.section.text.length == 0) {
            self.splitInfo = [NSArray arrayWithObject:[NSArray arrayWithObjects:[NSNumber numberWithInt: 0], [NSNumber numberWithInt:0], [NSNumber numberWithBool:NO], nil]];
        }
        [[ReaderCacheManager init_instance] deleteSplitInfo:self.section.section_id];
        [self.pagingView reloadData];
        
        NSString* searchUrl = [NSString stringWithFormat:@"http://%@/note/get_section?from=%@&url=%@", SERVER_HOST, self.section.from, [URLUtils uri_encode:self.section.url]];
        [self loadJSONRequest:searchUrl type:NOVEL_DOWNLOAD_TASK_TYPE_SECTION];
    }
}

- (void) prepareForRead {
    if (self.section != nil && self.section.text != nil && self.section.text.length != 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            self.section.text = [[self.section.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSArray* cachedInfo = [[ReaderCacheManager init_instance] getSplitInfo:self.section.section_id];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (cachedInfo) {
                    self.splitInfo = cachedInfo;
                } else {
                    self.splitInfo = [FontUtils findPageSplits:self.section.text size:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - 35.0f) font:[UIFont fontWithName:self.userDefaults.fontName size:self.userDefaults.fontSize] vertical:(self.userDefaults.textOrientation == 1)];
                    [[ReaderCacheManager init_instance] addSplitInfo:self.section.section_id splitInfo:self.splitInfo];
                }
                _initialized = NO;
                [self jumpToBookmark];
                [self.pagingView reloadData];
            });
        });
    } else {
        _initialized = NO;
        self.splitInfo = [NSArray arrayWithObject:[NSArray arrayWithObjects:[NSNumber numberWithInt: 0], [NSNumber numberWithInt:0], [NSNumber numberWithBool:NO],nil]];
        [self.pagingView reloadData];
    }
}

- (void) moveToPrevPage {
    if (self.pagingView.currentPageIndex == 0) {
        [self.change_section_delegate prevSectionEnd];
    } else {
        [self.pagingView setCurrentPageIndex:self.pagingView.currentPageIndex - 1];
    }
}

- (void) moveToNextPage {
    if (self.pagingView.currentPageIndex == [self.splitInfo count] - 1) {
        [self.change_section_delegate nextSection];
    } else {
        [self.pagingView setCurrentPageIndex:self.pagingView.currentPageIndex + 1];
    }
}

- (void) moveToNextSection {
    [self.change_section_delegate nextSection];
}

- (void) moveToPrevSection {
    [self.change_section_delegate prevSectionBegin];
}

- (void) toggleMenuState:(BOOL) state {
    _menuMode = state;
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

- (void)pagingViewWillBeginMoving:(ATPagingView *)pagingView {
    if (_menuMode) {
        SectionPageView* page = (SectionPageView*)[self.pagingView viewForPageAtIndex:self.pagingView.firstVisiblePageIndex];
        [page toggleShowMenu:nil];
    }
}

- (void) jumpToBookmark {
    if (self.section != nil && self.section.text!=nil && [self.section.text length] > 0) {
        NSUInteger indexForJump = [self.splitInfo count] - 1;
        for (; indexForJump > 0; indexForJump--) {
            if (self.bookmark.offset >= [[[self.splitInfo objectAtIndex:indexForJump] objectAtIndex:0] intValue]) {
                break;
            }
        }
        [self.pagingView setCurrentPageIndex:indexForJump];
        _initialized = YES;
    }
}

- (void)pagesDidChangeInPagingView:(ATPagingView *)pagingView {

}

- (void)pagingViewDidEndMoving:(ATPagingView *)pagingView {
    [self autoSaveBookmark:self.pagingView.firstVisiblePageIndex];
}


-(void) autoSaveBookmark:(NSUInteger)index {
    self.bookmark.section_id = self.section.section_id;
    NSArray* split = [self.splitInfo objectAtIndex:index];
    self.bookmark.offset = [[split objectAtIndex:0] intValue];
    [[DataBase get_database_instance] updateBookMark:self.bookmark];
}

-(void) didDragOnTableView:(UISwipeGestureRecognizer*) recognizer {
    if (self.pagingView.horizontal == NO && recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if ([delegate isReaderRightPanelOpen] == NO) {
            if (_menuMode) {
                SectionPageView* page = (SectionPageView*)[self.pagingView viewForPageAtIndex:self.pagingView.firstVisiblePageIndex];
                [page toggleShowMenu:nil];
            }
            [delegate switchToNavitation];
        }
    }
}

#pragma mark - SectionReaderMenuDelegate

- (void) clickInfoButton:(id)sender {
    
}

- (void) clickRefreshButton:(id)sender {
    [self reloadSection];
}

- (void) clickDownloadLaterButton:(id)sender {
    [self reloadSection];
    [self.change_section_delegate downloadLaterSections];
}

- (UIView *)viewForBarItem:(UIBarButtonItem *)item inToolbar:(UIToolbar *)toolbar
{
    // NOTE: This relies on internal implementation
    // TODO: Better implementation for iOS5+
    
    // Sort toolbar subviews to match order of toolbar items
    NSArray *subviews = [toolbar.subviews sortedArrayUsingComparator:^NSComparisonResult(id view1, id view2) {
        return [view1 frame].origin.x - [view2 frame].origin.x;
    }];
    
    // NOTE: Not sure why but had to filter out UIImageView from toolbar subviews
    NSMutableArray *mutableSubviews = [[NSMutableArray alloc] init];
    for(UIView *subview in subviews) {
        if(![subview isKindOfClass:[UIImageView class]]) {
            [mutableSubviews addObject:subview];
        }
    }
    
    int itemIndex = [toolbar.items indexOfObject:item];
    int adjustedIndex = itemIndex;
    for(int i=0; i<itemIndex; i++) {
        UIBarButtonItem *anItem = [toolbar.items objectAtIndex:i];
        if(anItem.tag == -1) adjustedIndex--;
    }
    
    UIView *buttonView = [mutableSubviews objectAtIndex:adjustedIndex];
    return buttonView;
}

- (CGRect)rectForBarItem:(UIBarButtonItem *)item inToolbar:(UIToolbar *)toolbar toView:(UIView*)view
{
    UIView *buttonView = [self viewForBarItem:item inToolbar:toolbar];
    CGRect rect = [buttonView convertRect:buttonView.bounds toView:view];
    return rect;
}

- (void) clickFontMenuButton:(id) sender {
    SectionPageView *cell = (SectionPageView*)[self.pagingView viewForPageAtIndex:self.pagingView.firstVisiblePageIndex];
    UIBarButtonItem* source = (UIBarButtonItem*) sender;
    [self.wePopupController presentPopoverFromRect:[self rectForBarItem:source inToolbar:cell.dropDownMenuToolbar toView:self.view] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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
    [self prepareForRead];
}

- (void) decreaseFontSize {
    [self prepareForRead];
}

- (void) changeFont:(NSString*) fontName {
    self.userDefaults.fontName = fontName;
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self prepareForRead];
}

- (void) changeTheme:(NSUInteger) themeIndex {
    self.userDefaults.themeIndex = themeIndex;
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.pagingView reloadData];
}


- (void) changeTextOrientation:(NSInteger)textOrientation {
    self.userDefaults.textOrientation = textOrientation;
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[ReaderCacheManager init_instance] clearAllSplitInfos];
    [self prepareForRead];
}

- (void) changeBrightness:(CGFloat)brightness {
    self.userDefaults.brightness = brightness;
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.pagingView reloadData];
}

#pragma mark -
#pragma mark ATPagingViewDelegate methods

- (NSInteger)numberOfPagesInPagingView:(ATPagingView *)pagingView {
     return [self.splitInfo count];
}


- (UIView *)viewForPageInPagingView:(ATPagingView *)pagingView atIndex:(NSInteger)index {
    //[self adjustPagingViewFrame];
    SectionPageView *view = (SectionPageView*)[pagingView dequeueReusablePage];
    if (view == nil) {
        view = [[SectionPageView alloc] init];
    }
    view.backgroundColor = [THEME_COLORS objectAtIndex:self.userDefaults.themeIndex];
    view.textLabelView.textColor = [FONT_COLORS objectAtIndex:self.userDefaults.themeIndex];
    view.textLabelView.font = [UIFont fontWithName:self.userDefaults.fontName size:self.userDefaults.fontSize];
    view.textLabelView.vertical = (self.userDefaults.textOrientation == 1);
    NSArray* split = [self.splitInfo objectAtIndex:index];

    [view setBeginParagraph:[[split objectAtIndex:2] boolValue]];
    
    if (self.section.text != nil && self.section.text.length > 0) {
        [view setNovelText:[self.section.text substringWithRange:NSMakeRange([[split objectAtIndex:0] intValue], [[split objectAtIndex:1] intValue])]];
    } else {
        [view setNovelText:@""];
    }
    view.labelView.text = self.section.name;
    view.indexView.text = [NSString stringWithFormat:@"第%d/%d页", index + 1, [self.splitInfo count]];
    view.delegate = self;
    if (index == self.pagingView.firstVisiblePageIndex) {
        [view setMenuState:_menuMode];
    } else {
        [view setMenuState:NO];
    }

    
    return view;

}
@end
