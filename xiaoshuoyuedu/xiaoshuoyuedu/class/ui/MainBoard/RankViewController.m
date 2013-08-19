//
//  RankViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-27.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "RankViewController.h"
#import "Common.h"
#import <AFNetworking/AFNetworking.h>
#import "BookInfoViewController.h"
@interface RankViewController ()

@end

#define MAX_LOAD_PAGE_NO 10

@implementation RankViewController

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
    self = [super initWithStyle:UITableViewStylePlain];
    self.currentPage = 0;
    self.searchResult = [[NSMutableArray alloc] init];
    return self;
}


- (void) segmentChanged:(UISegmentedControl*)sender {
}

- (void) pullRefresh:(UIRefreshControl*) sender {
    self.searchResult = [[NSMutableArray alloc] init];
    self.currentPage = 0;
    [self.tableView reloadData];
    [self retrieveRankInfo:1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullRefresh:) forControlEvents:UIControlEventValueChanged];
    
    self.spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [self retrieveRankInfo:1];
    self.title = NSLocalizedString(@"rank",@"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)success:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response data:(id)JSON {
    [super success:request withReponse:response data:JSON];
    RankViewController* _self = (RankViewController*)_weakReferenceSelf;
    if (JSON != nil && self !=nil) {
        [_self.searchResult addObjectsFromArray:JSON];
        self.currentPage++;
        [_self.tableView reloadData];
    }
    [_self.refreshControl endRefreshing];
    [_self.spinner stopAnimating];
}

- (void)failure:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response error:(NSError*)error data:(id)JSON {
    [super failure:request withReponse:response error:error data:JSON];
    RankViewController* _self = (RankViewController*)_weakReferenceSelf;
    [_self.refreshControl endRefreshing];
    [_self.spinner stopAnimating];
}

- (void) retrieveRankInfo:(NSUInteger) pageNo {
    NSString* searchUrl = [NSString stringWithFormat:@"http://%@/rank/get_rank?page=%d&from=lixiangwenxue", SERVER_HOST, pageNo];
    [self loadJSONRequest:searchUrl type:NOVEL_DOWNLOAD_TASK_TYPE_SEARCH];
    if (pageNo == 0) {
        [self.refreshControl beginRefreshing];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.currentPage > 0 && self.currentPage < MAX_LOAD_PAGE_NO) {
        return [self.searchResult count] + 1;
    } else {
        return [self.searchResult count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;
    if (self.currentPage < MAX_LOAD_PAGE_NO && indexPath.row == [self.searchResult count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RefreshTableCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RefreshTableCell"];
            cell.textLabel.text = NSLocalizedString(@"loadmore",@"");
            cell.accessoryView = self.spinner;
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text =  [NSString stringWithFormat:@"%@",[[self.searchResult objectAtIndex:indexPath.row] valueForKey:@"name"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[self.searchResult objectAtIndex:indexPath.row] valueForKey:@"author"]];
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
    if (self.currentPage == MAX_LOAD_PAGE_NO || indexPath.row != [self.searchResult count]) {
        id book = [self.searchResult objectAtIndex:indexPath.row];
        BookInfoViewController* infoViewController = [[BookInfoViewController alloc] initWithBookName:[book objectForKey:@"name"] author:[book objectForKey:@"author"] source:[book objectForKey:@"from"] url:[book objectForKey:@"url"]];
        [self.navigationController pushViewController:infoViewController animated:YES];
    } else {
        [self.spinner startAnimating];
        [self retrieveRankInfo:self.currentPage+1];
    }
}

@end
