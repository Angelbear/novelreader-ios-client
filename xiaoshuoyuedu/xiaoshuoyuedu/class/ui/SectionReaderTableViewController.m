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
    CGRect deviceRect = [ UIScreen mainScreen ].bounds;
    _initialized = NO;
    self.contentSize = CGSizeMake(deviceRect.size.width , deviceRect.size.height - 35.0f);
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

    return self;
}

- (void) reloadSection {
    __weak SectionReaderTableViewController* weakReferenceSelf = self;
    self.section.text = nil;
    self.splitInfo = [NSArray arrayWithObject:[NSArray arrayWithObjects:[NSNumber numberWithInt: 0], [NSNumber numberWithInt:0], nil]];
    [self.tableView reloadData];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/note/get_section?from=%@&url=%@", SERVER_HOST, self.section.from, [URLUtils uri_encode:self.section.url]]];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3" forHTTPHeaderField:@"User-Agent"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (JSON != nil) {
            self.section.text = [JSON objectForKey:@"text"];
            self.section.name = [JSON objectForKey:@"title"];
            [DataBase updateSection:self.section];
            [MBProgressHUD hideHUDForView:weakReferenceSelf.view animated:YES];
            [weakReferenceSelf prepareForRead];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [MBProgressHUD hideHUDForView:weakReferenceSelf.view animated:YES];
    }];
    [operation start];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}


- (void) prepareForRead {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        self.section.text = [NSString stringWithFormat:@"    %@", [self.section.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.splitInfo = [FontUtils findPageSplits:self.section.text size:self.contentSize font:[UIFont fontWithName:_fontName size:_fontSize]];
            _initialized = NO;
            [self.tableView reloadData];
        });
    });
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

#pragma WEPopoverControllerDelegate 
- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController {
    
}
- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController {
    return YES;
}

#pragma FontMenuDelegate
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
- (void) changeTheme:(NSString*) themeName {
    
}


-(void) setContentOffset:(NSNumber*)height {
    [self.tableView setContentOffset:CGPointMake(0.0f, [height floatValue]) animated:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_initialized) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            NSUInteger indexForJump = 0;
            for (indexForJump = 0; indexForJump < [self.splitInfo count]; indexForJump++) {
                if (self.bookmark.offset < [[[self.splitInfo objectAtIndex:indexForJump] objectAtIndex:0] intValue]) {
                    indexForJump --;
                    break;
                }
            }
            CGFloat height = MIN(indexForJump, [self.splitInfo count] - 1) * [ UIScreen mainScreen ].bounds.size.height;
            dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView setContentOffset:CGPointMake(0.0f, height) animated:NO];
            });
           _initialized = YES;
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.tableView addGestureRecognizer:tap];
    
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
    } else {
        [self reloadSection];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer {
    SectionReaderTableViewCell *cell = (SectionReaderTableViewCell*)[[self.tableView visibleCells] objectAtIndex:0];
    CGPoint touchLocation = [recognizer locationInView:cell.textView];
    if (   touchLocation.x > self.contentSize.width / 3.0f
        && touchLocation.x < self.contentSize.width * 2.0f / 3.0f
        && touchLocation.y > self.contentSize.height / 3.0f
        && touchLocation.y < self.contentSize.height * 2.0f / 3.0f
        ) {
        SectionReaderTableViewCell *cell = (SectionReaderTableViewCell*)[[self.tableView visibleCells] objectAtIndex:0];
        [cell toggleShowMenu:recognizer];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SectionReaderTableViewCell *cell = (SectionReaderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SectionReaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier fontSize:_fontSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
     }
    NSArray* split = [self.splitInfo objectAtIndex:indexPath.row];
    
    cell.textView.font = [UIFont fontWithName:_fontName size:_fontSize];
    [cell.textView setText:[self.section.text substringWithRange:NSMakeRange([[split objectAtIndex:0] intValue], [[split objectAtIndex:1] intValue])]];
    cell.labelView.text = self.section.name;
    cell.indexView.text = [NSString stringWithFormat:@"第%d/%d页", indexPath.row + 1, [self.splitInfo count]];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ UIScreen mainScreen ].bounds.size.height;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
