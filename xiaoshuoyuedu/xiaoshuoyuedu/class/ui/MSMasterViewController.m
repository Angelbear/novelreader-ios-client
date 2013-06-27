//
//  MSMasterViewController.m
//  MSNavigationPaneViewController
//
//  Created by Eric Horacek on 11/20/12.
//  Copyright (c) 2012-2013 Monospace Ltd. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MSMasterViewController.h"
#import "MSExampleTableViewController.h"
#import "SearchBookViewController.h"
#import "RankViewController.h"
#import "CategoryViewController.h"

NSString * const MSMasterViewControllerCellReuseIdentifier = @"MSMasterViewControllerCellReuseIdentifier";

typedef NS_ENUM(NSUInteger, MSMasterViewControllerTableViewSectionType) {
    MSMasterViewControllerTableViewSectionTypeLocal,
    MSMasterViewControllerTableViewSectionTypeList,
    MSMasterViewControllerTableViewSectionTypeMore,
    MSMasterViewControllerTableViewSectionTypeCount
};

@interface MSMasterViewController () <MSNavigationPaneViewControllerDelegate>

@property (nonatomic, strong) NSDictionary *paneViewControllerTitles;
@property (nonatomic, strong) NSDictionary *paneViewControllerClasses;
@property (nonatomic, strong) NSDictionary *paneViewControllerAppearanceTypes;
@property (nonatomic, strong) NSDictionary *sectionTitles;
@property (nonatomic, strong) NSArray *tableViewSectionBreaks;

@end

@implementation MSMasterViewController

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationPaneViewController.delegate = self;
    
    // Default to the "None" appearance type
    [self transitionToViewController:MSPaneViewControllerTypeBookShelf];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.navigationControllers removeAllObjects];
}

#pragma mark - MSMasterViewController

- (void)initialize
{
    self.paneViewControllerType = NSUIntegerMax;
    self.paneViewControllerTitles = @{
        @(MSPaneViewControllerTypeBookShelf) : @"BookShelf",
        @(MSPaneViewControllerTypeRank) : @"Rank",
        @(MSPaneViewControllerTypeCategory) : @"Category",
        @(MSPaneViewControllerTypeSearch) : @"Search",
        @(MSPaneViewControllerTypeMore) : @"More",
    };
    self.paneViewControllerClasses = @{
        @(MSPaneViewControllerTypeBookShelf) : MSExampleTableViewController.class,
        @(MSPaneViewControllerTypeRank) : RankViewController.class,
        @(MSPaneViewControllerTypeCategory) : CategoryViewController.class,
        @(MSPaneViewControllerTypeSearch) : SearchBookViewController.class,
        @(MSPaneViewControllerTypeMore) : MSExampleTableViewController.class,
    };

    self.sectionTitles = @{
        @(MSMasterViewControllerTableViewSectionTypeLocal) : @"Local",
        @(MSMasterViewControllerTableViewSectionTypeList) : @"List",
        @(MSMasterViewControllerTableViewSectionTypeMore) : @"More",
    };
    
    self.tableViewSectionBreaks = @[
        @(MSPaneViewControllerTypeRank),
        @(MSPaneViewControllerTypeMore),
        @(MSPaneViewControllerTypeCount)
    ];
    
    self.navigationControllers = [[NSMutableDictionary alloc] initWithCapacity:MSPaneViewControllerTypeCount];
}

- (MSPaneViewControllerType)paneViewControllerTypeForIndexPath:(NSIndexPath *)indexPath
{
    MSPaneViewControllerType paneViewControllerType;
    if (indexPath.section == 0) {
        paneViewControllerType = indexPath.row;
    } else {
        paneViewControllerType = ([self.tableViewSectionBreaks[(indexPath.section - 1)] integerValue] + indexPath.row);
    }
    NSAssert(paneViewControllerType < MSPaneViewControllerTypeCount, @"Invalid Index Path");
    return paneViewControllerType;
}

- (void)transitionToViewController:(MSPaneViewControllerType)paneViewControllerType
{
    if (paneViewControllerType == self.paneViewControllerType) {
        [self.navigationPaneViewController setPaneState:MSNavigationPaneStateClosed animated:YES completion:nil];
        return;
    }
    
    BOOL animateTransition = self.navigationPaneViewController.paneViewController != nil;
    
    UINavigationController *paneNavigationViewController = nil;
    if ( [self.navigationControllers objectForKey:@(paneViewControllerType)] != nil) {
        id viewController = [self.navigationControllers objectForKey:@(paneViewControllerType)];
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            paneNavigationViewController = (UINavigationController*) viewController;
        }
    }
    if (paneNavigationViewController == nil) {
        Class paneViewControllerClass = self.paneViewControllerClasses[@(paneViewControllerType)];
        NSParameterAssert([paneViewControllerClass isSubclassOfClass:UIViewController.class]);
        UIViewController* paneViewController = (UIViewController *)[[paneViewControllerClass alloc] init];
        paneViewController.navigationItem.title = self.paneViewControllerTitles[@(paneViewControllerType)];
        paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:paneViewController];
        [self.navigationControllers setValue:paneNavigationViewController forKey:@(paneViewControllerType)];
    }
    
    [self.navigationPaneViewController setPaneViewController:paneNavigationViewController animated:animateTransition completion:nil];
    
    self.paneViewControllerType = paneViewControllerType;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MSMasterViewControllerTableViewSectionTypeCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.tableViewSectionBreaks[section] integerValue];
    } else {
        return ([self.tableViewSectionBreaks[section] integerValue] - [self.tableViewSectionBreaks[(section - 1)] integerValue]);
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sectionTitles[@(section)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSMasterViewControllerCellReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MSMasterViewControllerCellReuseIdentifier];
    }
    MSPaneViewControllerType paneViewControllerType = [self paneViewControllerTypeForIndexPath:indexPath];
    cell.textLabel.text = self.paneViewControllerTitles[@(paneViewControllerType)];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSPaneViewControllerType paneViewControllerType = [self paneViewControllerTypeForIndexPath:indexPath];
    [self transitionToViewController:paneViewControllerType];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MSNavigationPaneViewControllerDelegate

- (void)navigationPaneViewController:(MSNavigationPaneViewController *)navigationPaneViewController didUpdateToPaneState:(MSNavigationPaneState)state
{
    // Ensure that the pane's table view can scroll to top correctly
    self.tableView.scrollsToTop = (state == MSNavigationPaneStateOpen);
}

@end
