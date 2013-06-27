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
    self = [super initWithNibName:@"RankViewController" bundle:nil];
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
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             @"Monthly",
                                             @"Weekly",
                                             @"Daily",
                                             nil]];
    [segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 180, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.selectedSegmentIndex = 0;
    
    [self.navigationItem setTitleView:segmentedControl];
    
    self.spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [self retrieveRankInfo:1];
       // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) retrieveRankInfo:(NSUInteger) pageNo {
    __unsafe_unretained RankViewController* weakReferenceSelf = self;
    NSString* searchUrl = [NSString stringWithFormat:@"http://%@/rank/get_rank?page=%d&from=lixiangwenxue", SERVER_HOST, pageNo];
    NSLog(@"%@", searchUrl);
    NSURL *url = [NSURL URLWithString:searchUrl];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3" forHTTPHeaderField:@"User-Agent"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (JSON != nil && weakReferenceSelf !=nil) {
            [self.searchResult addObjectsFromArray:JSON];
            self.currentPage = pageNo;
            [weakReferenceSelf.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
        [self.spinner stopAnimating];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"failure %@", [error localizedDescription]);
        [self.refreshControl endRefreshing];
        [self.spinner stopAnimating];
    }];
    [operation start];
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
    if (self.currentPage < MAX_LOAD_PAGE_NO) {
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
            cell.textLabel.text = @"加载更多";
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentPage > 0 && self.currentPage < MAX_LOAD_PAGE_NO && indexPath.row == [self.searchResult count]) {
        //[self retrieveRankInfo:self.currentPage+1];
    }
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
