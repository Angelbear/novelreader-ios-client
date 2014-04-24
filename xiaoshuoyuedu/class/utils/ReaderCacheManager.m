//
//  ReaderCacheManager.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-7.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "ReaderCacheManager.h"


@implementation ReaderCacheManager

- (id) init {
    self = [super init];
    if (self) {
        _cache = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return self;
}

+ (ReaderCacheManager*) init_instance {
    static ReaderCacheManager* _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ReaderCacheManager alloc] init];
    });
    return _instance;
}

- (void) clearAllSplitInfos {
    [_cache removeAllObjects];
}

- (void) deleteSplitInfo:(Section* )section {
    [_cache removeObjectForKey:section.url];
}

- (void) addSplitInfo:(Section* )section splitInfo:(NSArray*)splitInfo {
    [_cache setObject:splitInfo forKey:section.url];
}

- (NSArray*) getSplitInfo:(Section* )section {
    return [_cache objectForKey:section.url];
}

@end
