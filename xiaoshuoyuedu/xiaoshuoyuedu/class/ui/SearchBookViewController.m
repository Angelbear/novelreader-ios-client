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

@interface SearchBookViewController ()

@end

@implementation SearchBookViewController

- (NSString*) uri_encode:(NSString*) str {
    NSString* encoded = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                         kCFAllocatorDefault,
                                                         (__bridge CFStringRef)str,
                                                         NULL,
                                                         (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                         kCFStringEncodingUTF8));
	return encoded;
}

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return 0;
    } else if(tableView == self.searchDisplayController.searchResultsTableView && searchResult != nil) {
        return [searchResult count];
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
    
    if(tableView == self.searchDisplayController.searchResultsTableView && searchResult != nil) {
        cell.textLabel.text =  [[searchResult objectAtIndex:indexPath.row] valueForKey:@"name"];
        cell.detailTextLabel.text = [[searchResult objectAtIndex:indexPath.row] valueForKey:@"from"];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - UISearchBar delegate

id searchResult;

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    __unsafe_unretained SearchBookViewController* weakReferenceSelf = self;
    NSString* searchUrl = [NSString stringWithFormat:@"http://xiaoshuoyuedu.sinaapp.com/note/search_novel?key_word=%@", [self uri_encode:[self.searchDisplayController.searchBar text]]];
    NSLog(@"%@", searchUrl);
    NSURL *url = [NSURL URLWithString:searchUrl];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3" forHTTPHeaderField:@"User-Agent"];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (JSON != nil && weakReferenceSelf !=nil) {
            NSSortDescriptor *sortName = [[NSSortDescriptor alloc] initWithKey:@"from" ascending:YES];
            NSArray *sortDescArray = [NSArray arrayWithObjects:sortName, nil];            
            [JSON sortedArrayUsingDescriptors:sortDescArray];
            searchResult = JSON;
            [weakReferenceSelf.searchDisplayController.searchResultsTableView reloadData];
        }
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"failure %@", [error localizedDescription]);
        [MBProgressHUD hideHUDForView:weakReferenceSelf.navigationController.view animated:YES];
    }];
    [operation start];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
}

@end
