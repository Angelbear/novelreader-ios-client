//
//  ReaderCacheManager.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-7.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReaderCacheManager : NSObject {
    NSMutableDictionary* _cache;
}
+ (ReaderCacheManager*) init_instance;
- (void) clearAllSplitInfos;
- (void) deleteSplitInfo:(NSUInteger)sectionId;
- (void) addSplitInfo:(NSUInteger)sectionId splitInfo:(NSArray*)splitInfo;
- (NSArray*) getSplitInfo:(NSUInteger)sectionId;
@end
