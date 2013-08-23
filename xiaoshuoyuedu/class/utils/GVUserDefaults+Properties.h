//
//  GVUserDefaults+Properties.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-12.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "GVUserDefaults.h"

enum {
    LOCALE_ENGLISH = 1,
    LOCALE_CHINISE = 2,
    LOCALE_JAPANESE = 3,
} LOCALE_SETTINGS;

@interface GVUserDefaults (Properties)
@property (nonatomic) BOOL orientationLocked;
@property (nonatomic) NSUInteger fixedOrientation;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic, weak) NSString* fontName;
@property (nonatomic) NSInteger themeIndex;
@property (nonatomic) NSInteger textOrientation;
@property (nonatomic) CGFloat brightness;
- (NSDictionary *)setupDefaults;
@end
