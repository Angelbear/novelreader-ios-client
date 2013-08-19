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
             @"NSUserDefaultOrientationLocked": @YES,
             @"NSUserDefaultFixedOrientation" : @(1),
             @"NSUserDefaultFontSize": @(DEFAULT_FONT_SIZE),
             @"NSUserDefaultFontName" : @"Helvetica",
             @"NSUserDefaultThemeIndex": @0,
             @"NSUserDefaultTextOrientation": @0,
             @"NSUserDefaultLocaleSettings": @1,
             @"NSUserDefaultBrightness": @(1.0f),
             };
}


@end
