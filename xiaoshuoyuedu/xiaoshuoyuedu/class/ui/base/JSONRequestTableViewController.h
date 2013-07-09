//
//  JSONRequestTableViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-8.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface JSONRequestTableViewController : UITableViewController {
    __weak JSONRequestTableViewController* _weakReferenceSelf;
}
@property(nonatomic, strong) AFJSONRequestOperation *currentOperation;
@property(nonatomic, strong) MBProgressHUD* HUD;
- (void)loadJSONRequest:(NSString*)url;
- (void)success:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response data:(id)JSON;
- (void)failure:(NSURLRequest *)request withReponse:(NSHTTPURLResponse*)response error:(NSError*)error data:(id)JSON;
@end
