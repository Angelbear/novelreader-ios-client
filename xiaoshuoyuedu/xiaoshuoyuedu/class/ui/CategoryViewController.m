//
//  CategoryViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-27.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "CategoryViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "BookInfoViewController.h"
#import "Common.h"
#import "CategoryResultViewController.h"

@interface CategoryViewController ()

@end

@implementation CategoryViewController

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
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self retrieveCategoryInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)success:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response data:(id)JSON {
    [super success:request withReponse:response data:JSON];
    CategoryViewController* _self = (CategoryViewController*)_weakReferenceSelf;
    if (JSON != nil && _self !=nil) {
        _self.searchResult = JSON;
        [_self.tableView reloadData];
    }
}


- (void) retrieveCategoryInfo {
    NSString* searchUrl = [NSString stringWithFormat:@"http://%@/category/get_category_info?from=lixiangwenxue", SERVER_HOST];
    [self loadJSONRequest:searchUrl];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text =  [NSString stringWithFormat:@"%@",[[self.searchResult objectAtIndex:indexPath.row] valueForKey:@"name"]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger type = [[[self.searchResult objectAtIndex:indexPath.row] valueForKey:@"type"] intValue];
    CategoryResultViewController* cat = [[CategoryResultViewController alloc] initWithType:type source:@"lixiangwenxue" name:[[self.searchResult objectAtIndex:indexPath.row] valueForKey:@"name"]];
    [self.navigationController pushViewController:cat animated:YES];
}

@end
