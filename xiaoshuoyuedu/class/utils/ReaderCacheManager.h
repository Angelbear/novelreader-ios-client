//
//  ReaderCacheManager.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-7.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Section.h"

@interface ReaderCacheManager : NSObject {
    NSMutableDictionary* _cache;
}
+ (ReaderCacheManager*) init_instance;
- (void) clearAllSplitInfos;
- (void) deleteSplitInfo:(Section* )section;
- (void) addSplitInfo:(Section* )section splitInfo:(NSArray*)splitInfo;
- (NSArray*) getSplitInfo:(Section* )section;
@end
