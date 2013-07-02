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

#define DEFAULT_FONT_SIZE 20.0f

- (id) init {
    self = [super initWithStyle:UITableViewStylePlain];
    CGRect deviceRect = [ UIScreen mainScreen ].bounds;
    //CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
    self.contentSize = CGSizeMake(deviceRect.size.width , deviceRect.size.height - 35.0f);
    self.splitInfo = [NSArray arrayWithObject:[NSArray arrayWithObjects:[NSNumber numberWithInt: 0], [NSNumber numberWithInt:0], nil]];
    return self;
}

- (void) reloadSection {
    __weak SectionReaderTableViewController* weakReferenceSelf = self;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/note/get_section?from=%@&url=%@", SERVER_HOST, self.section.from, [URLUtils uri_encode:self.section.url]]];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3" forHTTPHeaderField:@"User-Agent"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (JSON != nil) {
            self.section.text = [JSON objectForKey:@"text"];
            self.section.name = [JSON objectForKey:@"title"];
            [DataBase updateSection:self.section];
            [MBProgressHUD hideHUDForView:weakReferenceSelf.navigationController.view animated:YES];
            [weakReferenceSelf prepareForRead];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [MBProgressHUD hideHUDForView:weakReferenceSelf.navigationController.view animated:YES];
    }];
    [operation start];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
}


- (void) prepareForRead {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        self.section.text =  [self.section.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        self.splitInfo = [FontUtils findPageSplits:self.section.text size:self.contentSize font:[UIFont fontWithName:@"FZLTHJW--GB1-0" size:DEFAULT_FONT_SIZE]];
        NSUInteger indexForJump = 0;
        for (indexForJump = 0; indexForJump < [self.splitInfo count]; indexForJump++) {
            if (self.bookmark.offset < [[[self.splitInfo objectAtIndex:indexForJump] objectAtIndex:0] intValue]) {
                indexForJump --;
                break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat height = MIN(indexForJump, [self.splitInfo count] - 1) * [ UIScreen mainScreen ].bounds.size.height;
            [self.tableView reloadData];
            [self performSelector:@selector(setContentOffset:) withObject:@(height) afterDelay:1.0];
        });
    });
}

- (void)backToBookShelf:(id)sender {
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate switchToNavitation];
}

-(void) setContentOffset:(NSNumber*)height {
    [self.tableView setContentOffset:CGPointMake(0.0f, [height floatValue]) animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    /*
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(backToBookShelf:)];
    self.navigationItem.leftBarButtonItem = backBtn;
    [self.tableView addGestureRecognizer:tap];
     */
    [self.tableView setScrollEnabled:NO];
    
    self.tableView.bounces = YES;
    self.tableView.alwaysBounceVertical = YES;
    
    UISwipeGestureRecognizer* swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didDragOnTableView:)];
    
    [swipeUpGesture setDirection: UISwipeGestureRecognizerDirectionUp];
    [self.tableView addGestureRecognizer:swipeUpGesture];
    
    
    UISwipeGestureRecognizer* swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didDragOnTableView:)];
    
    [swipeDownGesture setDirection: UISwipeGestureRecognizerDirectionDown];
    [self.tableView addGestureRecognizer:swipeDownGesture];
    
    UISwipeGestureRecognizer* swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didDragOnTableView:)];
 
    [swipeLeftGesture setDirection: UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:swipeLeftGesture];
    
    UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didDragOnTableView:)];
    
    [swipeRightGesture setDirection: UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:swipeRightGesture];

    
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];

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
    CGPoint touchLocation = [recognizer locationInView:self.view];
    if (   touchLocation.x > self.contentSize.width / 3.0f
        && touchLocation.x < self.contentSize.width * 2.0f / 3.0f
        ) {
        if ([[[self navigationController] navigationBar] isHidden]) {
            [[self navigationController] setNavigationBarHidden:NO animated:YES];
        } else {
            [[self navigationController] setNavigationBarHidden:YES animated:YES];
        }
    }

}

-(void) autoSaveBookmark:(NSUInteger)index {
    self.bookmark.section_id = self.section.section_id;
    NSArray* split = [self.splitInfo objectAtIndex:index];
    self.bookmark.offset = [[split objectAtIndex:0] intValue];
    [DataBase updateBookMark:self.bookmark];
}

-(void) didDragOnTableView:(UISwipeGestureRecognizer*) recognizer {
    NSIndexPath* path = [self.tableView.indexPathsForVisibleRows objectAtIndex:0 ];
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate openReaderPaneView];
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self backToBookShelf:nil];
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        if (path.row > 0) {
            NSIndexPath* newPath = [NSIndexPath indexPathForRow:path.row - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:newPath  atScrollPosition:UITableViewScrollPositionTop animated:YES];
            [self autoSaveBookmark:newPath.row];
        }
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        if (path.row < [self tableView:self.tableView numberOfRowsInSection:0] - 1) {
            NSIndexPath* newPath = [NSIndexPath indexPathForRow:path.row +1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            [self autoSaveBookmark:newPath.row];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SectionReaderTableViewCell *cell = (SectionReaderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SectionReaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier fontSize:DEFAULT_FONT_SIZE];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
     }
    NSArray* split = [self.splitInfo objectAtIndex:indexPath.row];

    [cell.textView setText:[self.section.text substringWithRange:NSMakeRange([[split objectAtIndex:0] intValue], [[split objectAtIndex:1] intValue])]];
    cell.labelView.text = self.section.name;
    cell.indexView.text = [NSString stringWithFormat:@"第%d/%d页", indexPath.row + 1, [self.splitInfo count]];
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dataComps = [gregorianCal components: (NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                  fromDate: [NSDate date]];
 
    cell.timeView.text = [NSString stringWithFormat:@"%02d:%02d", [dataComps hour], [dataComps minute]];
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
