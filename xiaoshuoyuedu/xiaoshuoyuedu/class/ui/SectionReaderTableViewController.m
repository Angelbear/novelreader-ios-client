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
@interface SectionReaderTableViewController ()

@property (nonatomic, strong) NSArray* splitInfo;
@property (nonatomic, assign) CGRect contentSize;
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

#define DEFAULT_FONT_SIZE 24.0f
#define MAX_HEIGHT_PIXEL 65535

- (id) init {
    self = [super initWithStyle:UITableViewStylePlain];
    CGRect deviceRect = [ UIScreen mainScreen ].bounds;
    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
    self.contentSize = CGRectMake(deviceRect.origin.x, deviceRect.origin.y, deviceRect.size.width, deviceRect.size.height - statusRect.size.height);
    return self;
}


- (void)backToBookShelf:(id)sender {
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate switchToNavitation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(backToBookShelf:)];
    self.navigationItem.leftBarButtonItem = backBtn;
    [self.tableView addGestureRecognizer:tap];
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
    
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\n+" options:0 error:NULL];
    NSString* str= [regex stringByReplacingMatchesInString:self.section.text options:0 range:NSMakeRange(0, [self.section.text length]) withTemplate:@"\n\n"];
    self.section.text = str;
    NSLog(@"%@",str);
    CGSize size = self.contentSize.size;
    self.splitInfo = [FontUtils findPageSplits:str size:size font:[UIFont systemFontOfSize:DEFAULT_FONT_SIZE]];
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
    if (   touchLocation.x > self.contentSize.size.width / 3.0f
        && touchLocation.x < self.contentSize.size.width * 2.0f / 3.0f
        ) {
        NSIndexPath* path = [self.tableView.indexPathsForVisibleRows objectAtIndex:0 ];
        [self.tableView scrollToRowAtIndexPath:path  atScrollPosition:UITableViewScrollPositionTop animated:NO];
        if ([[[self navigationController] navigationBar] isHidden]) {
            [[self navigationController] setNavigationBarHidden:NO animated:YES];
        } else {
            [[self navigationController] setNavigationBarHidden:YES animated:YES];
        }
    }

}

-(void) didDragOnTableView:(UISwipeGestureRecognizer*) recognizer {
    NSIndexPath* path = [self.tableView.indexPathsForVisibleRows objectAtIndex:0 ];
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate openReaderPaneView];
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        if (path.row > 0) {
            NSIndexPath* newPath = [NSIndexPath indexPathForRow:path.row - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:newPath  atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        if (path.row < [self tableView:self.tableView numberOfRowsInSection:0] - 1) {
            NSIndexPath* newPath = [NSIndexPath indexPathForRow:path.row +1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SectionReaderTableViewCell *cell = (SectionReaderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SectionReaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withContentSize:self.contentSize fontSize:DEFAULT_FONT_SIZE];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
     }
    NSArray* split = [self.splitInfo objectAtIndex:indexPath.row];
    [cell.labelView setText:[self.section.text substringWithRange:NSMakeRange([[split objectAtIndex:0] intValue], [[split objectAtIndex:1] intValue])]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.contentSize.size.height;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

@end
