/*
 GSBookShelfCellView.m
 BookShelf
 
 Created by Xinrong Guo on 12-2-23.
 Copyright (c) 2012 FoOTOo. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 Neither the name of the project's author nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "BookShelfCellView.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"

@implementation BookShelfCellView

@synthesize reuseIdentifier;

static UIImage *shadingImage = nil;
static UIImage *woodImage = nil;
static UIImage *shelfImageProtrait = nil;
static UIImage *shelfImageLandscape = nil;

+ (UIImage *)shadingImage {
    if (shadingImage == nil) {
        CGFloat scale = isRetina ? 2.0f : 1.0f;
        
        CGRect deviceFrame = [UIScreen mainScreen].bounds;
        
        UIGraphicsBeginImageContext(CGSizeMake(deviceFrame.size.width * scale, CELL_HEIGHT * scale));
        UIImage *shadingImageToDraw = isiPad ? [UIImage imageNamed:@"Side Shading-iPad"] : [UIImage imageNamed:@"Side Shading-iPhone"];
        [shadingImageToDraw drawInRect:CGRectMake(0, 0, shadingImageToDraw.size.width * scale, shadingImageToDraw.size.height * scale)];
        
        CGAffineTransform ctm1 = CGAffineTransformMakeScale(-1.0f, 1.0f);
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), ctm1);
        [shadingImageToDraw drawInRect:CGRectMake(0- deviceFrame.size.width * scale, 0, shadingImageToDraw.size.width * scale, shadingImageToDraw.size.height * scale)];
        shadingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        shadingImage = [UIImage imageWithCGImage:shadingImage.CGImage scale:scale orientation:UIImageOrientationUp];
    }
    return shadingImage;
}

+ (UIImage *)woodImage {
    if (woodImage == nil) {
        CGFloat scale = isRetina ? 2.0f : 1.0f;
        CGRect deviceFrame = [UIScreen mainScreen].bounds;
        
        UIGraphicsBeginImageContext(CGSizeMake(deviceFrame.size.width * scale, CELL_HEIGHT * scale));
        UIImage *woodImageToDraw = [UIImage imageNamed:@"WoodTile"];
        [woodImageToDraw drawInRect:CGRectMake(0, 0, woodImageToDraw.size.width * scale, woodImageToDraw.size.width * scale)];
        woodImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        woodImage = [UIImage imageWithCGImage:woodImage.CGImage scale:scale orientation:UIImageOrientationUp];
    }
    return woodImage;
}

+ (UIImage *)shelfImageProtrait {
    if (shelfImageProtrait == nil) {
        shelfImageProtrait = [UIImage imageNamed:@"Shelf"];
    }
    return shelfImageProtrait;
}

+ (UIImage *)shelfImageLandscape {
    if (shelfImageLandscape == nil) {
        shelfImageLandscape = [UIImage imageNamed:@"Shelf-Landscape"];
    }
    return shelfImageLandscape;
}



- (UIImage *)partOfImage:(UIImage *)image rect:(CGRect)rect {
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.width));
    [image drawInRect:rect];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}



- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _shelfImageView = [[UIImageView alloc] initWithImage:[BookShelfCellView shelfImageProtrait]];
        
        _shelfImageViewLandscape = [[UIImageView alloc] initWithImage:[BookShelfCellView shelfImageLandscape]];
        
        _woodImageView = [[UIImageView alloc] initWithImage:[BookShelfCellView woodImage]];
        
        _shadingImageView = [[UIImageView alloc] initWithImage:[BookShelfCellView shadingImage]];
    
        [self addSubview:_woodImageView];
        [self addSubview:_shadingImageView];
        [self addSubview:_shelfImageView];
        [self addSubview:_shelfImageViewLandscape];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_shadingImageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    CGRect deviceFrame = [UIScreen mainScreen].bounds;
    if (self.frame.size.width <= deviceFrame.size.width) {
        [_shelfImageView setHidden:NO];
        [_shelfImageViewLandscape setHidden:YES];
    }
    else {
        [_shelfImageView setHidden:YES];
        [_shelfImageViewLandscape setHidden:NO];
    }
    [_shelfImageView setFrame:CGRectMake(0, 130 - 23, self.frame.size.width, _shelfImageView.frame.size.height)];
    [_shelfImageViewLandscape setFrame:CGRectMake(0, 130 - 23, self.frame.size.width, _shelfImageViewLandscape.frame.size.height)];

}

@end
