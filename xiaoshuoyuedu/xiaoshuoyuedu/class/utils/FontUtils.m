//
//  FontUtils.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "FontUtils.h"
#import <CoreText/CoreText.h>
#import "Common.h"

@implementation FontUtils

#define kFudgeFactor 16.0
#define kGapFactor 8.0
#define kMaxFieldHeight 9999.0

+ (CGFloat)stringSize:(NSString*)text font:(UIFont*)_font atWidth:(CGFloat)width
{
    NSMutableAttributedString* _string = [[NSMutableAttributedString alloc] initWithString:text];
    CTTextAlignment alignment = kCTJustifiedTextAlignment;
    
    CGFloat paragraphSpacing = 0.0;
    CGFloat paragraphSpacingBefore = 0.0;
    CGFloat firstLineHeadIndent = 0.0;
    CGFloat headIndent = 0.0;
    
    CTParagraphStyleSetting settings[] =
    {
        {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment},
        {kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &firstLineHeadIndent},
        {kCTParagraphStyleSpecifierHeadIndent, sizeof(CGFloat), &headIndent},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing},
        {kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore},
    };
    
    CTParagraphStyleRef style;
    style = CTParagraphStyleCreate(settings, sizeof(settings)/sizeof(CTParagraphStyleSetting));
    
    if (NULL == style) {
        // error...
        return 0.0;
    }
    
    [_string addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSObject*)style, (NSString*)kCTParagraphStyleAttributeName, nil]
                     range:NSMakeRange(0, [_string length])];
    
    CFRelease(style);
    
    if (nil == _font) {
        _font = [UIFont systemFontOfSize:DEFAULT_FONT_SIZE];
    }
    
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)_font.fontName, _font.pointSize, NULL);
    [_string addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSObject*)fontRef, (NSString*)kCTFontAttributeName, nil]
                     range:NSMakeRange(0, [_string length])];

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_string);
    CGSize targetSize = CGSizeMake(width - 16.0f, CGFLOAT_MAX);
    CGSize fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [_string length]), NULL, targetSize, NULL);
    CFRelease(framesetter);
    return fitSize.height;
}

#define TEST_CHINISE_CHARACTER @"永"

+ (NSArray*) findPageSplits:(NSString*)string size:(CGSize)size font:(UIFont*)font {
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:32];
    CGSize test_size = [TEST_CHINISE_CHARACTER sizeWithFont:font];
    NSUInteger prediect_columns = (int)(size.width / test_size.width);
    CGFloat height = size.height;
    CFRange r = {0, 0};
    NSInteger str_len = [string length];
    NSUInteger round = 0;
    NSUInteger calcAPICallNum = 0;
    do {
        CGFloat calcHeight;
        NSUInteger count = 0;
        while (r.location < str_len && [string characterAtIndex:r.location] == '\n') {
            r.location ++;
        }
        do {
            //count+= MAX(prediect_columns, (int)(prediect_columns* prediect_rows / pow(4, round + 1) ));
            count+=prediect_columns;
            if (r.location + count > str_len) {
                break;
            }
            calcHeight = [FontUtils stringSize:[string substringWithRange:NSMakeRange(r.location, count)] font:font atWidth:size.width];
            //[UITextView heightWithText:[string substringWithRange:NSMakeRange(r.location, count)] font:font atWidth:size.width];
            calcAPICallNum ++;
        } while ( calcHeight < height );
        
        if (r.location + count > str_len) {
            count = str_len - r.location;
        }
        
        calcHeight = [FontUtils stringSize:[string substringWithRange:NSMakeRange(r.location, count)] font:font atWidth:size.width];
        //[UITextView heightWithText:[string substringWithRange:NSMakeRange(r.location, count)] font:font atWidth:size.width];
        calcAPICallNum ++;
        
        if (calcHeight > height) {            
            do {
                count--;
                calcHeight = [FontUtils stringSize:[string substringWithRange:NSMakeRange(r.location, count)] font:font atWidth:size.width];
                //[UITextView heightWithText:[string substringWithRange:NSMakeRange(r.location, count)] font:font atWidth:size.width];
                calcAPICallNum ++;
            } while (calcHeight > height);
        }
        
        [result addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:r.location], [NSNumber numberWithInt:count], nil]];
        r.location += count;
        count = 0;
        round ++;
    } while (r.location < str_len);
    NSLog(@"calcAPICallNum %d", calcAPICallNum);
    return result;
}

@end
