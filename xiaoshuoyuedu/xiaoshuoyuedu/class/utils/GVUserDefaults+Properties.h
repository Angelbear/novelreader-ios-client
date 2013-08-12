//
//  GVUserDefaults+Properties.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-12.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "GVUserDefaults.h"

@interface GVUserDefaults (Properties)
@property (nonatomic) BOOL orientationLocked;
@property (nonatomic) NSUInteger fixedOrientation;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic, weak) NSString* fontName;
@property (nonatomic) NSInteger themeIndex;
@end
