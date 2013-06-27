//
//  FixedSearchBookViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-27.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "FixedSearchBookViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "BookInfoViewController.h"
#import "Common.h"
@interface FixedSearchBookViewController ()

@end

@implementation FixedSearchBookViewController

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
    self = [super initWithNibName:@"FixedSearchBookViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.savedSearchTerm)
    {
        self.title = [NSString stringWithFormat:@"搜索结果：%@", self.savedSearchTerm];
        [self searchBook:self.savedSearchTerm];
    }
}

- (void) searchBook:(NSString *)searchKey {
    __unsafe_unretained FixedSearchBookViewController* weakReferenceSelf = self;
    NSString* searchUrl = [NSString stringWithFormat:@"http://%@/note/search_novel?key_word=%@", SERVER_HOST, [URLUtils uri_encode:self.savedSearchTerm]];
    NSLog(@"%@", searchUrl);
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    NSURL *url = [NSURL URLWithString:searchUrl];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3" forHTTPHeaderField:@"User-Agent"];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (JSON != nil && weakReferenceSelf !=nil) {
            NSSortDescriptor *sortName = [[NSSortDescriptor alloc] initWithKey:@"from" ascending:NO];
            NSArray *sortDescArray = [NSArray arrayWithObjects:sortName, nil];
            [JSON sortedArrayUsingDescriptors:sortDescArray];
            self.searchResult = JSON;
            self.sectionResult = [NSCountedSet setWithArray:[self.searchResult valueForKey:@"from"]];
            [weakReferenceSelf.searchDisplayController.searchResultsTableView reloadData];
        }
        [MBProgressHUD hideHUDForView:weakReferenceSelf.navigationController.view animated:YES];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             NSLog(@"failure %@", [error localizedDescription]);
                                             [MBProgressHUD hideHUDForView:weakReferenceSelf.navigationController.view animated:YES];
                                         }];
    [operation start];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.sectionResult != nil) {
        return [self.sectionResult count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( self.sectionResult != nil) {
        return [self.sectionResult countForObject:[[self.sectionResult allObjects] objectAtIndex:section]];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.sectionResult != nil) {
        return [[self.sectionResult allObjects] objectAtIndex:section];
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier =  @"FixedSearchBookViewController";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if(self.searchResult != nil) {
        NSString* from =  [[self.sectionResult allObjects] objectAtIndex:indexPath.section];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(from == %@)", from];
        id item = [[self.searchResult filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row];
        cell.textLabel.text =  [NSString stringWithFormat:@"%@",[item valueForKey:@"name"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [item valueForKey:@"author"]];
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
    NSString* from =  [[self.sectionResult allObjects] objectAtIndex:indexPath.section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(from == %@)", from];
    id book = [[self.searchResult filteredArrayUsingPredicate:predicate] objectAtIndex:indexPath.row];
    BookInfoViewController* infoViewController = [[BookInfoViewController alloc] initWithBookName:[book objectForKey:@"name"] author:[book objectForKey:@"author"] source:[book objectForKey:@"from"] url:[book objectForKey:@"url"]];
    [self.navigationController pushViewController:infoViewController animated:YES];
}

@end
