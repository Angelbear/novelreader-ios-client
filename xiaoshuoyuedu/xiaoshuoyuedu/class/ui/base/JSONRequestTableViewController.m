//
//  JSONRequestTableViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-8.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "JSONRequestTableViewController.h"

@interface JSONRequestTableViewController ()

@end

@implementation JSONRequestTableViewController

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
    _weakReferenceSelf = self;
}

- (void) loadJSONRequest:(NSString *)searchUrl type:(NOVEL_DOWNLOAD_TASK_TYPE)type {
    self.currentOperation = [[DownloadManager init_instance] addDownloadTask:type url:searchUrl success:^void(NSURLRequest *request, NSHTTPURLResponse *response, id data) {
        [_weakReferenceSelf success:request withReponse:response data:data];
    } failure:^void(NSURLRequest *request, NSHTTPURLResponse *response, id data, NSError *error) {
        [_weakReferenceSelf failure:request withReponse:response error:error data:data];
    }];
    [self showHUDWithCancel];
}

- (void) cancelOperation:(id)sender {
    [self.currentOperation cancel];
    [self.HUD setHidden:YES];
}

- (void)showHUDWithCancel {
    if (self.HUD == nil) {
        if (self.navigationController != nil) {
            self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        } else {
            self.HUD = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        }
        [self.HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelOperation:)]];
    } else {
        [self.HUD setHidden:NO];
    }
}


- (void)success:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response data:(id)JSON {
    [_weakReferenceSelf.HUD setHidden:YES];
}
- (void)failure:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response error:(NSError*)error data:(id)JSON {
    [_weakReferenceSelf.HUD setHidden:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
