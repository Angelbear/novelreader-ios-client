//
//  FontUtils.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "FontUtils.h"
#import <CoreText/CoreText.h>
#import "UITextView+Dimensions.h"

@implementation FontUtils

/*
+ (NSArray*) findPageSplits:(NSString*)string size:(CGSize)size font:(UIFont*)font
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:32];
    CTFontRef fnt = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize,NULL);
    CFAttributedStringRef str = CFAttributedStringCreate(kCFAllocatorDefault,
                                                         (CFStringRef)string,
                                                         (CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fnt,kCTFontAttributeName,nil]);
    CTFramesetterRef fs = CTFramesetterCreateWithAttributedString(str);
    CFRange r = {0,0};
    CFRange res = {0,0};
    size.height -= [font lineHeight];
    NSInteger str_len = [string length];
    do {
        CTFramesetterSuggestFrameSizeWithConstraints(fs,r, NULL, size, &res);
        [result addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:r.location], [NSNumber numberWithInt:res.length], nil]];
        r.location += res.length;
    } while(r.location < str_len);
    CFRelease(fs);
    CFRelease(str);
    CFRelease(fnt);
    return result;
}*/
 

+ (NSArray*) findPageSplits:(NSString*)string size:(CGSize)size font:(UIFont*)font {
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:32];
    CGFloat height = size.height;
    CFRange r = {0, 0};
    NSInteger str_len = [string length];
    NSUInteger count = 0;
    do {
        CGFloat calcHeight;
        while (r.location < str_len && [string characterAtIndex:r.location] == '\n') {
            r.location ++;
        }
        do {
            count++;
            if (r.location + count > str_len) {
                break;
            }
            calcHeight = [UITextView heightWithText:[string substringWithRange:NSMakeRange(r.location, count)] font:font atWidth:size.width];
        } while ( calcHeight < height);
        count--;
        [result addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:r.location], [NSNumber numberWithInt:count], nil]];
        r.location += count;
        count = 0;
    } while (r.location < str_len);
    return result;
}

@end
