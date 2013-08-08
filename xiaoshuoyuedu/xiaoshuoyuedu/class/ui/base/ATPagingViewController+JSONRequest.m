//
//  ATPagingViewController+JSONRequest.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-7.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "ATPagingViewController+JSONRequest.h"

@implementation ATPagingViewController (JSONRequest)
__weak ATPagingViewController* _weakReferenceSelf;

AFJSONRequestOperation* _currentOperation;

-(void) setCurrentOperation:(AFJSONRequestOperation*)opertation
{
    _currentOperation = opertation;
}

-(AFJSONRequestOperation*) currentOperation
{
    return _currentOperation;
}


MBProgressHUD* _HUD;

-(void) setHUD:(MBProgressHUD *)HUD
{
    _HUD = HUD;
}

-(MBProgressHUD*) HUD
{
    return _HUD;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.pagingView.delegate == nil)
        self.pagingView.delegate = self;
    _weakReferenceSelf = self;
}

- (void) loadJSONRequest:(NSString *)searchUrl type:(NOVEL_DOWNLOAD_TASK_TYPE)type {
    self.currentOperation = [[DownloadManager init_instance] addDownloadTask:type url:searchUrl piority:NSOperationQueuePriorityVeryHigh success:^void(NSURLRequest *request, NSHTTPURLResponse *response, id data) {
        [self success:request withReponse:response data:data];
    } failure:^void(NSURLRequest *request, NSHTTPURLResponse *response, id data, NSError *error) {
        [self failure:request withReponse:response error:error data:data];
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
            self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        [self.HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelOperation:)]];
    } else {
        [self.HUD setHidden:NO];
    }
}


- (void)success:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response data:(id)JSON {
    [self.HUD setHidden:YES];
}
- (void)failure:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response error:(NSError*)error data:(id)JSON {
    [self.HUD setHidden:YES];
}

@end
