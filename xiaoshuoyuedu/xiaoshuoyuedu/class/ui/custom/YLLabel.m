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
@synthesize vertical = _vertical;

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
    
    CFDictionaryRef attr = _vertical ? (__bridge  CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCTFrameProgressionRightToLeft], (NSString*)kCTFrameProgressionAttributeName, nil] : NULL;
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

- (CTGlyphInfoRef)getGlyphInfoRef {
    NSString* language =  (__bridge NSString *)CFStringTokenizerCopyBestStringLanguage((CFStringRef)_text, CFRangeMake(0, _text.length));
    if ([language isEqualToString:@"ja"]) {
        return CTGlyphInfoCreateWithCharacterIdentifier(kCGFontIndexMax, kCTCharacterCollectionAdobeJapan1, (__bridge CFStringRef)(_text));
    } else if ([language isEqualToString:@"zh-Hans"]) {
        return CTGlyphInfoCreateWithCharacterIdentifier(kCGFontIndexMax, kCTCharacterCollectionAdobeCNS1, (__bridge CFStringRef)(_text));
    }
    return NULL;
}

- (void)formatString
{
    if (nil == _font) {
        _font = [UIFont systemFontOfSize:DEFAULT_FONT_SIZE];
    }
    
    CTTextAlignment alignment = kCTJustifiedTextAlignment;
    
    CGFloat paragraphSpacing = 0.0;
    CGFloat paragraphSpacingBefore = 0.0;
    CGFloat firstLineHeadIndent = _vertical ? 0.0 : _font.pointSize * 2;
    CGFloat headIndent = 0.0;
    CGFloat lineSpaceing = 2.0;
    CGFloat leading = _font.lineHeight - _font.ascender + _font.descender;
    
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
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &leading}
    };
    
    CTParagraphStyleRef style;
    style = CTParagraphStyleCreate(settings, sizeof(settings)/sizeof(CTParagraphStyleSetting));
    
    if (NULL == style) {
        return;
    }
    
    
    if (_beginParagraph) {
        [_string addAttribute:(NSString*)kCTParagraphStyleAttributeName value:(__bridge id)style range:NSMakeRange(0, [_string length])];
    } else if ([_string length] > 0 ){
        [_string addAttribute:(NSString*)kCTParagraphStyleAttributeName value:(__bridge id)style range:NSMakeRange(1, [_string length] - 1)];
    }
    CFRelease(style);

    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)_font.fontName, _font.pointSize, NULL);
    [_string addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, [_string length])];

    CGFloat wordSpacing = 2.0f;
    [_string addAttribute:(NSString*)kCTKernAttributeName value:@(wordSpacing) range:NSMakeRange(0, [_string length])];
    
    CGColorRef colorRef = _textColor.CGColor;
    [_string addAttribute:(NSString*)kCTForegroundColorAttributeName value:(__bridge id)colorRef range:NSMakeRange(0, [_string length])];
    
    
    CTGlyphInfoRef glyphInfo = [self getGlyphInfoRef];
    if (glyphInfo) {
        [_string addAttribute:(NSString *)kCTGlyphInfoAttributeName value:(__bridge id)glyphInfo range:NSMakeRange(0, [_string length])];
        CFRelease(glyphInfo);
    }
        
    [_string addAttribute:(NSString*)kCTLigatureAttributeName value:@(YES) range:NSMakeRange(0, [_string length])];
    
    if (_vertical) {
        [_string addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], (NSString*)kCTVerticalFormsAttributeName,
                                                                          [NSNumber numberWithBool:YES], (NSString*)kCTLigatureAttributeName, nil]
                         range:NSMakeRange(0, [_string length])];
    }
}

@end
