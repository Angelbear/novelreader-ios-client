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
#import "GVUserDefaults+Properties.h"

@interface YLLabel(Private)
@end

@implementation YLLabel

@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize beginParagraph = _beginParagraph;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _vertical = NO;
        _userDefaults = [GVUserDefaults standardUserDefaults];
        _beginParagraph = YES;
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
    
    CFDictionaryRef attr = _vertical ? (__bridge  CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCTFrameProgressionRightToLeft], @"CTFrameProgression", nil] : NULL;
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [_string length]), path, attr);
    CFRelease(path);
    
    CTFrameDraw(frame, ctx);
    CFRelease(frame);
    CFRelease(frameSetter);
}

- (void)setText:(NSString *)text
{
    _text = text;
    _string = [[NSMutableAttributedString alloc] initWithString:text];
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
}

- (void)formatString
{
    if (nil == _font) {
        _font = [UIFont systemFontOfSize:DEFAULT_FONT_SIZE];
    }
    
    CTTextAlignment alignment = kCTJustifiedTextAlignment;
    
    CGFloat paragraphSpacing = 0.0;
    CGFloat paragraphSpacingBefore = 0.0;
    CGFloat firstLineHeadIndent = _font.pointSize * 2;
    CGFloat headIndent = 0.0;
    CGFloat lineSpaceing = 0.0;
    
    CTParagraphStyleSetting settings[] =
    {
        {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment},
        {kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &firstLineHeadIndent},
        {kCTParagraphStyleSpecifierHeadIndent, sizeof(CGFloat), &headIndent},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing},
        {kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpaceing},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpaceing},
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpaceing},
    };
    
    CTParagraphStyleRef style;
    style = CTParagraphStyleCreate(settings, sizeof(settings)/sizeof(CTParagraphStyleSetting));
    
    if (NULL == style) {
        return;
    }
    
    
    if (_beginParagraph) {
        [_string addAttribute:(NSString*)kCTParagraphStyleAttributeName value:(__bridge id)style range:NSMakeRange(0, [_string length])];
    } else if ([_string length] > 0 ){
        [_string addAttribute:(NSString*)kCTParagraphStyleAttributeName value:(__bridge id)style range:NSMakeRange(0, [_string length] - 1)];
    }
    CFRelease(style);

    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)_font.fontName, _font.pointSize, NULL);
    [_string addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, [_string length])];

    
    CGColorRef colorRef = _textColor.CGColor;
    [_string addAttribute:(NSString*)kCTForegroundColorAttributeName value:(__bridge id)colorRef range:NSMakeRange(0, [_string length])];

    
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateCurrentVersion;
    callbacks.dealloc = deallocationCallback;
    callbacks.getAscent = getAscentCallback;
    callbacks.getDescent = getDescentCallback;
    callbacks.getWidth = getWidthCallback;
    
    NSDictionary* attribs = [NSDictionary dictionaryWithObjectsAndKeys:@(_font.lineHeight),@"height",@(_font.pointSize),@"width", nil];
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (void *)CFBridgingRetain(attribs));
    [_string addAttribute:(NSString*)kCTRunDelegateAttributeName value:(__bridge id)delegate range:NSMakeRange(0, [_string length])];
    CFRelease(delegate);
    
    CTGlyphInfoRef glyphInfo = CTGlyphInfoCreateWithCharacterIdentifier(kCGFontIndexMax, kCTAdobeGB1CharacterCollection, (__bridge CFStringRef)(_text));
    [_string addAttribute:(NSString *)kCTGlyphInfoAttributeName value:(__bridge id)glyphInfo range:NSMakeRange(0, [_string length])];
    CFRelease(glyphInfo);
    
    [_string addAttribute:(NSString*)kCTLigatureAttributeName value:@(YES) range:NSMakeRange(0, [_string length])];
    
    if (_vertical) {
        [_string addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], (NSString*)kCTVerticalFormsAttributeName,
                                                                          [NSNumber numberWithBool:YES], (NSString*)kCTLigatureAttributeName, nil]
                         range:NSMakeRange(0, [_string length])];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void deallocationCallback( void* ref )
{
    CFBridgingRelease(ref);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//height of object
CGFloat getAscentCallback( void *ref )
{
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat getDescentCallback( void *ref)
{
    return 0.0f;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//width of object
CGFloat getWidthCallback( void* ref )
{
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@end
