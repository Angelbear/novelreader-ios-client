//
//  WindowSelectViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-11.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "WindowSelectViewController.h"
#import "AppDelegate.h"
@interface WindowSelectViewController ()

@end

@implementation WindowSelectViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _windows = delegate.windows;
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
    return [_windows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIWindow* window = [_windows objectAtIndex:indexPath.row];
    if (delegate.currentWindow == window) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (window.screen == [UIScreen mainScreen]) {
        cell.textLabel.text = @"本机";
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"外接屏幕%d", indexPath.row];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIWindow* window = [_windows objectAtIndex:indexPath.row];
    if (delegate.currentWindow != window) {
        [delegate switchToWindow:window];
    }
}

@end
