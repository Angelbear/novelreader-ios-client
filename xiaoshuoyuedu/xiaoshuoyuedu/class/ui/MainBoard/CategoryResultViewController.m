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
    NSString* searchUrl = [NSString stringWithFormat:@"http://%@/category/get_category?page=%d&type=%d&from=%@", SERVER_HOST, pageNo, self.type, self.fromSource];
    [self loadJSONRequest:searchUrl type:NOVEL_DOWNLOAD_TASK_TYPE_SEARCH];
    if (pageNo == 0) {
        [self.refreshControl beginRefreshing];
    }
}

@end
