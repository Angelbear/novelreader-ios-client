//
//  ATPagingViewController+JSONRequest.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-7.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "ATPagingView.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "DownloadManager.h"

@interface ATPagingViewController (JSONRequest) 
@property(nonatomic, strong) AFJSONRequestOperation *currentOperation;
@property(nonatomic, strong) MBProgressHUD* HUD;
- (void)loadJSONRequest:(NSString *)searchUrl  type:(NOVEL_DOWNLOAD_TASK_TYPE)type;
- (void)showHUDWithCancel;
- (void)success:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response data:(id)JSON;
- (void)failure:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response error:(NSError*)error data:(id)JSON;
@end
