/*
 GSBookView.m
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

#import "BookView.h"

@implementation BookView

@synthesize image = _image;
@synthesize button = _button;
@synthesize reuseIdentifier;
@synthesize edited = _edited;
@synthesize index = _index;

- (id)initWithFrame:(CGRect)frame book:(Book*)book
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setFrame:frame];
        [_button setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [_button.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_deleteButton setHidden:YES];
        _deleteButton.contentMode = UIViewContentModeCenter;
        [_deleteButton setImage:[UIImage imageNamed:@"shelf_delete"] forState:UIControlStateNormal];
        _deleteButton.frame = CGRectMake(frame.origin.x + frame.size.width - 40, frame.origin.y - 40, 80, 80);
        _deleteButton.imageEdgeInsets = UIEdgeInsetsMake(25, 25, 25, 25);
        [_button addSubview:_deleteButton];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    if ([_image isEqual:image]) {
        return;
    }
    _image = image;
    
    [_button setImage:_image forState:UIControlStateNormal];
}

- (void)setEdited:(BOOL)edited {
    _edited = edited;
    if (_edited) {
        [_deleteButton setHidden:NO];
    }
    else {
        [_deleteButton setHidden:YES];
    }
}

- (void)deleteButtonClicked:(id)sender {
    NSLog(@"deleteButtonClicked");
}

- (void)buttonClicked:(id)sender {
}

@end
