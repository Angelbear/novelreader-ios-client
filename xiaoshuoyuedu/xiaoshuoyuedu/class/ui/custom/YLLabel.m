//
//  YLLabel.m
//  YLLabelDemo
//
//  Created by Eric Yuan on 12-11-8.
//  Copyright (c) 2012年 YuanLi. All rights reserved.
//

#import "YLLabel.h"
#import <CoreText/CoreText.h>
#import "Common.h"
#import <QuartzCore/QuartzCore.h>

@interface YLLabel(Private)

- (void)formatString;

@end

@implementation YLLabel

@synthesize font = _font;
@synthesize textColor = _textColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self formatString];
    
    if (!_string || [_string length] == 0) {
        return;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);

    CGContextTranslateCTM(ctx,0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_string);
    
    CGRect bounds = self.bounds;
    bounds.origin.x = bounds.origin.x + 8;
    bounds.size.width = bounds.size.width - 16;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, bounds);
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [_string length]), path, NULL);
    CFRelease(path);
    
    CTFrameDraw(frame, ctx);
    CFRelease(frame);
    CFRelease(frameSetter);
}

- (void)setText:(NSString *)text
{
    _string = [[NSMutableAttributedString alloc] initWithString:text];
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
}

- (void)formatString
{
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
        return;
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
    
    CGColorRef colorRef = _textColor.CGColor;
    [_string addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSObject*)colorRef,(NSString*)kCTForegroundColorAttributeName, nil]
                     range:NSMakeRange(0, [_string length])];
}

@end
