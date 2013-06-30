//
//  FontUtils.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FontUtils : NSObject
+ (NSArray*) findPageSplits:(NSString*)string size:(CGSize)size font:(UIFont*)font;
@end
