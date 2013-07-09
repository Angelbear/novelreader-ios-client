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

#define kFudgeFactor 16.0
#define kGapFactor 8.0
#define kMaxFieldHeight 9999.0

// recursive method called by the main API
+ (CFRange) sizeStringToFit:(NSString*)aString min:(int)aMin max:(int)aMax size:(CGSize)size font:(UIFont*)font
{
    if ((aMax-aMin) <= 1)
	{
        return CFRangeMake(0,   aMax);
	}
    
    int mean = (aMin + aMax)/2;
    NSString* subString = [aString substringToIndex:mean];
    
    //CGSize tallerSize = CGSizeMake(size.width - kFudgeFactor ,kMaxFieldHeight);
    //CGSize stringSize = [subString sizeWithFont:font constrainedToSize:tallerSize];
    CGFloat height = [UITextView heightWithText:subString font:font atWidth:size.width];
    
    if (height <= size.height - kGapFactor)
        return [FontUtils sizeStringToFit:aString min:mean max:aMax size:size font:font]; // too small
    else
        return [FontUtils sizeStringToFit:aString min:aMin max:mean size:size font:font];// too big
}

 + (CFRange)sizeStringToFit:(NSString*)aString size:(CGSize)size font:(UIFont*)font range:(CFRange)range
{
    NSString* subString = [aString substringWithRange:NSMakeRange(range.location, range.length)];
    //CGSize tallerSize = CGSizeMake(size.width - kFudgeFactor, kMaxFieldHeight);
    //CGSize stringSize = [subString sizeWithFont:font constrainedToSize:tallerSize];
     CGFloat height = [UITextView heightWithText:subString font:font atWidth:size.width];
    
    // if it fits, just return
    if (height < size.height - kGapFactor)
        return CFRangeMake(range.location, range.length);
    
    // too big - call the recursive method to size it
    CFRange calcRange = [FontUtils sizeStringToFit:aString min:0 max:[subString length] size:size font:font];
    return CFRangeMake(range.location, calcRange.length);
}

+ (NSArray*) findPageSplits2:(NSString*)string size:(CGSize)size font:(UIFont*)font {
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:32];
    NSInteger str_len = [string length];
    CFRange r = {0, str_len};
    do {
        while (r.location < str_len && [string characterAtIndex:r.location] == '\n') {
            r.location ++;
            r.length --;
        }
        CFRange q = [FontUtils sizeStringToFit:string size:size font:font range:r];
        [result addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:q.location], [NSNumber numberWithInt:q.length], nil]];
        r.location = q.location + q.length;
        r.length = str_len - r.location;
    } while (r.location < str_len);
    return result;
}


#define TEST_CHINISE_CHARACTER @"永"

+ (NSArray*) findPageSplits:(NSString*)string size:(CGSize)size font:(UIFont*)font {
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:32];
    CGSize test_size = [TEST_CHINISE_CHARACTER sizeWithFont:font];
    NSUInteger prediect_columns = (int)(size.width / test_size.width);
    //NSUInteger prediect_rows = (int)(size.height / test_size.height);
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
            calcHeight = [UITextView heightWithText:[string substringWithRange:NSMakeRange(r.location, count)] font:font atWidth:size.width];
            calcAPICallNum ++;
        } while ( calcHeight < height );
        
        if (r.location + count > str_len) {
            count = str_len - r.location;
        }
        
        calcHeight = [UITextView heightWithText:[string substringWithRange:NSMakeRange(r.location, count)] font:font atWidth:size.width];
        calcAPICallNum ++;
        
        if (calcHeight > height) {            
            do {
                count--;
                calcHeight = [UITextView heightWithText:[string substringWithRange:NSMakeRange(r.location, count)] font:font atWidth:size.width];
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
