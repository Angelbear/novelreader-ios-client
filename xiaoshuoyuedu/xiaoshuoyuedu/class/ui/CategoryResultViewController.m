//
//  CategoryResultViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-27.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "CategoryResultViewController.h"
#import "Common.h"
#import <AFNetworking/AFNetworking.h>
#import "BookInfoViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
@implementation CategoryResultViewController

- (id) initWithType:(NSUInteger)type source:(NSString*) from name:(NSString*)name
{
    self = [super init];
    self.type = type;
    self.fromSource = from;
    self.name = name;
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.name;
}

- (void) retrieveRankInfo:(NSUInteger) pageNo {
    __unsafe_unretained CategoryResultViewController* weakReferenceSelf = self;
    NSString* searchUrl = [NSString stringWithFormat:@"http://%@/category/get_category?page=%d&type=%d&from=%@", SERVER_HOST, pageNo, self.type, self.fromSource];
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
        [MBProgressHUD hideHUDForView:weakReferenceSelf.navigationController.view animated:YES];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"failure %@", [error localizedDescription]);
        [self.refreshControl endRefreshing];
        [self.spinner stopAnimating];
        [MBProgressHUD hideHUDForView:weakReferenceSelf.navigationController.view animated:YES];
    }];
    [operation start];
    if (pageNo == 0) {
        [self.refreshControl beginRefreshing];
    }
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
}

@end
