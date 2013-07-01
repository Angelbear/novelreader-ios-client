//
//  MSReaderViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "MSReaderViewController.h"
#import "DataBase.h"
#import "Section.h"
#import "Book.h"
#import "SectionReaderTableViewController.h"
@interface MSReaderViewController () <MSNavigationPaneViewControllerDelegate>
@property(nonatomic, strong) NSMutableArray* sections;
@property(nonatomic, assign) NSUInteger readingSection;
@end

@implementation MSReaderViewController

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
    self.readingSection = 0;
    return self;
}


- (void) viewWillAppear:(BOOL)animated {
    self.sections = [DataBase getAllSectionsOfBook:self.book];
    [self.tableView reloadData];
    [self transitionToViewController:[self.sections objectAtIndex:0]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationPaneViewController.delegate = self;
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
    return [self.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.book.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    Section * sec = [self.sections objectAtIndex:indexPath.row];
    cell.textLabel.text = sec.name;
    if (sec.text !=nil && [sec.text length] > 0) {
        cell.imageView.image = [UIImage imageNamed:@"checkmark"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"sync"];
    }
    
    if (self.readingSection == indexPath.row) {
        cell.imageView.image = [UIImage imageNamed:@"checkmark-current"];
    }

    return cell;
}


- (void)transitionToViewController:(Section*) section {
    BOOL animateTransition = self.navigationPaneViewController.paneViewController != nil;

    SectionReaderTableViewController* paneViewController = [[SectionReaderTableViewController alloc] init];
    paneViewController.navigationItem.title = section.name;
    [paneViewController setSection:section];
    UINavigationController* paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:paneViewController];

    [self.navigationPaneViewController setPaneViewController:paneNavigationViewController animated:animateTransition completion:nil];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Section* section = [self.sections objectAtIndex:indexPath.row];
    [self transitionToViewController:section];
    self.readingSection = indexPath.row;
    [self.tableView reloadData];
}

#pragma mark - MSNavigationPaneViewControllerDelegate

- (void)navigationPaneViewController:(MSNavigationPaneViewController *)navigationPaneViewController didUpdateToPaneState:(MSNavigationPaneState)state
{
    self.tableView.scrollsToTop = (state == MSNavigationPaneStateOpen);
}

@end