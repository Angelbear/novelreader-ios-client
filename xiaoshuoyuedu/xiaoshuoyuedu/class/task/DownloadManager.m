//
//  DownloadManager.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-16.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "DownloadManager.h"
#import "Common.h"
#import "DataBase.h"
#import "Book.h"
#import "Section.h"

@implementation DownloadManager

- (id) init {
    self = [super init];
    if (self) {
        _client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/", SERVER_HOST]]];
        [_client.operationQueue setMaxConcurrentOperationCount: MAX_CONCURRENT_REQUEST_NUM];
    }
    return self;
}

+ (DownloadManager*) init_instance {
    static DownloadManager* _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[DownloadManager alloc] init];
    });
    return _instance;
}

- (AFJSONRequestOperation*) queryDownloadTask:(NOVEL_DOWNLOAD_TASK_TYPE) type url:(NSString*) url {    
    NSArray* operations = [_client.operationQueue operations];
    for (AFJSONRequestOperation* operation in operations) {
        if ([operation.request.URL.absoluteString isEqualToString:url]) {
            return operation;
        }
    }
    return nil;
}

- (BOOL) cancelDownloadTask:(NOVEL_DOWNLOAD_TASK_TYPE) type url:(NSString*) url {
    NSArray* operations = [_client.operationQueue operations];
    for (AFJSONRequestOperation* operation in operations) {
        if ([operation.request.URL.absoluteString isEqualToString:url]) {
            [operation cancel];
            return YES;
        }
    }
    return NO;
}

- (AFJSONRequestOperation*) addDownloadTask:(NOVEL_DOWNLOAD_TASK_TYPE) type url:(NSString*)url success:(DownloadSuccessBlock)blockSuccess failure:(DownloadFailureBlock)blockFailure {
    NSURL *uri = [NSURL URLWithString:url];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:uri];
    [request setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3" forHTTPHeaderField:@"User-Agent"];
    [request setTimeoutInterval:20.0f];
    
    if ([self queryDownloadTask:type url:url] != nil) {
        return nil;
    }
    
    AFJSONRequestOperation* currentOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (blockSuccess) {
            blockSuccess(request, response, JSON);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        if (blockFailure) {
            blockFailure(request, response, JSON, error);
        }
    }];
    [_client enqueueHTTPRequestOperation:currentOperation];
    return currentOperation;
}

@end
