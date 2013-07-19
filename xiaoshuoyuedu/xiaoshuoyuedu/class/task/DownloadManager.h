//
//  DownloadManager.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-16.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>


typedef NS_ENUM(NSInteger, NOVEL_DOWNLOAD_TASK_TYPE) {
    NOVEL_DOWNLOAD_TASK_TYPE_SEARCH = 0,
    NOVEL_DOWNLOAD_TASK_TYPE_BOOK,
    NOVEL_DOWNLOAD_TASK_TYPE_SECTION,
    NOVEL_DOWNLOAD_TASK_TYPE_BOOK_INFO,

};

typedef void (^DownloadSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id data);
typedef void (^DownloadFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id data, NSError* error);

@interface DownloadManager : NSObject {
    AFHTTPClient* _client;
}
+ (DownloadManager*) init_instance;
- (AFJSONRequestOperation*) queryDownloadTask:(NOVEL_DOWNLOAD_TASK_TYPE) type url:(NSString*) url;
- (BOOL) cancelDownloadTask:(NOVEL_DOWNLOAD_TASK_TYPE) type url:(NSString*) url;
- (AFJSONRequestOperation*) addDownloadTask:(NOVEL_DOWNLOAD_TASK_TYPE)type url:(NSString*)url success:(DownloadSuccessBlock)blockSuccess failure:(DownloadFailureBlock)blockFailure;
@end
