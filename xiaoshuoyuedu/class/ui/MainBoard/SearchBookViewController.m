//
//  SearchBookViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-24.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "SearchBookViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "BookInfoViewController.h"
#import "DownloadManager.h"
#import "Common.h"

@interface SearchBookViewController ()

@end

@implementation SearchBookViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    self = [super initWithNibName:@"SearchBookViewController" bundle:nil];
    self.savedScopeButtonIndex = 0;
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.savedSearchTerm)
    {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:self.savedSearchTerm];
        [self searchBarSearchButtonClicked:self.searchDisplayController.searchBar];
        self.savedSearchTerm = nil;
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
    if (tableView == self.tableView) {
        return 1;
    } else if(tableView == self.searchDisplayController.searchResultsTableView && self.sectionResult != nil) {
        return [self.sectionResult count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return 0;
    } else if(tableView == self.searchDisplayController.searchResultsTableView && self.sectionResult != nil) {
        return [self.sectionResult countForObject:[[self.sectionResult allObjects] objectAtIndex:section]];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return @"";
    } else if(tableView == self.searchDisplayController.searchResultsTableView && self.sectionResult != nil) {
        return [[self.sectionResult allObjects] objectAtIndex:section];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = tableView == self.tableView ?  @"SearchBookTableView" : @"SearchBookTableViewSearch";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if(tableView == self.searchDisplayController.searchResultsTableView && self.searchResult != nil) {
        NSString* from =  [[self.sectionResult allObjects] objectAtIndex:indexPath.section];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(from == %@)", from];
        id item = [[self.searchResult filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row];
        cell.textLabel.text =  [NSString stringWithFormat:@"%@",[item valueForKey:@"name"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [item valueForKey:@"author"]];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* from =  [[self.sectionResult allObjects] objectAtIndex:indexPath.section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(from == %@)", from];
    id book = [[self.searchResult filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row];
    BookInfoViewController* infoViewController = [[BookInfoViewController alloc] initWithBookName:[book objectForKey:@"name"] author:[book objectForKey:@"author"] source:[book objectForKey:@"from"] url:[book objectForKey:@"url"]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    if (isiPad) {
        [infoViewController setModalPresentationStyle:UIModalPresentationFormSheet];
        UINavigationController *modalViewController = [[UINavigationController alloc] initWithRootViewController:infoViewController];
        [modalViewController setModalPresentationStyle:UIModalPresentationFormSheet];
        [self presentViewController:modalViewController animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:infoViewController animated:YES];
    }
}

#pragma mark - UISearchBar delegate

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    __unsafe_unretained SearchBookViewController* weakReferenceSelf = self;
    NSString* searchUrl = [NSString stringWithFormat:@"http://%@/note/search_novel?key_word=%@", SERVER_HOST, [URLUtils uri_encode:[self.searchDisplayController.searchBar text]]];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text]; 
    [[DownloadManager init_instance] addDownloadTask:NOVEL_DOWNLOAD_TASK_TYPE_SEARCH url:searchUrl piority:NSOperationQueuePriorityVeryHigh success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (JSON != nil && weakReferenceSelf !=nil) {
            NSSortDescriptor *sortName = [[NSSortDescriptor alloc] initWithKey:@"from" ascending:NO];
            NSArray *sortDescArray = [NSArray arrayWithObjects:sortName, nil];
            [JSON sortedArrayUsingDescriptors:sortDescArray];
            self.searchResult = JSON;
            self.sectionResult = [NSCountedSet setWithArray:[self.searchResult valueForKey:@"from"]];
            [weakReferenceSelf.searchDisplayController.searchResultsTableView reloadData];
        }
        [MBProgressHUD hideHUDForView:weakReferenceSelf.navigationController.view animated:YES];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, id data, NSError *error) {
        [MBProgressHUD hideHUDForView:weakReferenceSelf.navigationController.view animated:YES];
    }];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    self.savedScopeButtonIndex = selectedScope;
}

@end
