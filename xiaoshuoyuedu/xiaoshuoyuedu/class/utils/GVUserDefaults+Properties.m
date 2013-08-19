//
//  GVUserDefaults+Properties.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-12.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "GVUserDefaults+Properties.h"
#import "Common.h"
@implementation GVUserDefaults (Properties)
- (NSString *)transformKey:(NSString *)key {
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] uppercaseString]];
    return [NSString stringWithFormat:@"NSUserDefault%@", key];
}


- (NSDictionary *)setupDefaults {
    return @{
             @"orientationLocked": @YES,
             @"fixedOrientation" : @(1),
             @"fontSize": @(DEFAULT_FONT_SIZE),
             @"fontName" : @"Helvetica",
             @"themeIndex": @0,
             @"textOrientation": @0,
             @"localeSettings": @1,
             @"brightness": @(1.0f),
             };
}


@end
