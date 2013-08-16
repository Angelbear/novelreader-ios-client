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
#import "YLLabel.h"
@implementation FontUtils

#define kFudgeFactor 16.0
#define kGapFactor 8.0
#define kMaxFieldHeight 9999.0

+ (NSArray*) findPageSplits:(NSString*)string size:(CGSize)size font:(UIFont*)font vertical:(BOOL)vertical{
    YLLabel* label = [[YLLabel alloc] init];
    [label setFont:font];
    [label setText:string];
    [label setTextColor:[UIColor blackColor]];
    [label formatString];

    NSLog(@"findPageSplits %@", NSStringFromCGSize(size));
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)label.string);
    
    CGRect bounds;
    if (vertical) {
        bounds = CGRectMake(0, 0, size.width - kFudgeFactor, size.height);
    } else {
        bounds = CGRectMake(0, 0, size.width - kFudgeFactor, size.height);
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, bounds);
    
    NSMutableArray *clusterRanges = [NSMutableArray array];
    
	CFIndex location = 0;
	CFIndex length   = [string length];
	while (location < length) {
		CFRange stringRange = CFRangeMake(location, length-location);
		CFRange fitRange = CFRangeMake(0, 0);
        
        if (vertical) {
            CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, stringRange, NULL, CGSizeMake(CGFLOAT_MAX, size.height), &fitRange);
        } else {
            CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, stringRange, NULL, CGSizeMake(size.width - kFudgeFactor, CGFLOAT_MAX), &fitRange);
        }
        
        CFDictionaryRef attr = vertical ? (__bridge  CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCTFrameProgressionRightToLeft], @"CTFrameProgression", nil] : NULL;
        
		CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, fitRange, path, attr);

		CFRange factRange = CTFrameGetVisibleStringRange(frame);
        
        BOOL beginParagraph = (location == 0 || [string characterAtIndex:location - 1] == '\n');

        [clusterRanges addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:location], [NSNumber numberWithInt:factRange.length], [NSNumber numberWithBool:beginParagraph],nil]];
        location += factRange.length;
        
		CFRelease(frame);
	}
    
	CGPathRelease(path);
	CFRelease(frameSetter);
    
	return clusterRanges;
}

@end
