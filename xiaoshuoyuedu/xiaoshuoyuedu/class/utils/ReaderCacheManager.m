//
//  ReaderCacheManager.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-7.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "ReaderCacheManager.h"

@implementation ReaderCacheManager
ReaderCacheManager* _instance;

- (id) init {
    self = [super init];
    if (self) {
        _cache = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return self;
}

+ (ReaderCacheManager*) init_instance {
    if (_instance == nil) {
        _instance = [[ReaderCacheManager alloc] init];
    }
    return _instance;
}

- (void) clearAllSplitInfos {
    [_cache removeAllObjects];
}

- (void) deleteSplitInfo:(NSUInteger)sectionId {
    [_cache removeObjectForKey:@(sectionId)];
}

- (void) addSplitInfo:(NSUInteger)sectionId splitInfo:(NSArray*)splitInfo {
    [_cache setObject:splitInfo forKey:@(sectionId)];
}

- (NSArray*) getSplitInfo:(NSUInteger)sectionId {
    return [_cache objectForKey:@(sectionId)];
}

@end
