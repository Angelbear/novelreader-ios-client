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
#import "Book.h"
#import "AppDelegate.h"
#import "DataBase.h"
#import "Bookmark.h"
#import "Section.h"
#import <QuartzCore/QuartzCore.h>
@implementation BookView

@synthesize image = _image;
@synthesize cover = _cover;
@synthesize reuseIdentifier;
@synthesize edited = _edited;
@synthesize index = _index;
@synthesize label = _label;
@synthesize downloadProgressView = _downloadProgressView;
@synthesize badge = _badge;
@synthesize content = _content;

- (id)initWithFrame:(CGRect)frame book:(Book*)book withCaller:(id<DeleteBookDelegate>) caller
{
    self = [super initWithFrame:frame];
    if (self) {
        self.book = book;
        _deleteMode = NO;
        _edited = NO;
        
        _delegate = caller;
        
        [self setBackgroundColor:[UIColor clearColor]];
        _cover = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cover setFrame:frame];
        //[_button setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [_cover.imageView setContentMode:UIViewContentModeScaleToFill];
        [_cover addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_cover setImage:book.cover forState:UIControlStateNormal];
        _cover.imageView.layer.cornerRadius = 3;
        _cover.imageView.layer.masksToBounds = YES;
        CALayer* containerLayer = [CALayer layer];
        containerLayer.shadowColor = [UIColor blackColor].CGColor;
        containerLayer.shadowRadius = 1.f;
        containerLayer.shadowOffset = CGSizeMake(0.f, 1.f);
        containerLayer.shadowOpacity = 1.f;
        [containerLayer addSublayer:_cover.imageView.layer];
        [_cover.layer addSublayer:containerLayer];
        [self addSubview:_cover];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_deleteButton setHidden:YES];
        _deleteButton.backgroundColor = [UIColor clearColor];
        
        _deleteButton.frame = CGRectMake(frame.origin.x - 25, frame.origin.y - 25, 50, 50);
        _deleteButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [_deleteButton setImage:[UIImage imageNamed:@"shelf_delete"] forState:UIControlStateNormal];
        [_cover addSubview:_deleteButton];

        _label = [[UILabel alloc] initWithFrame:CGRectMake(_cover.imageView.frame.origin.x, _cover.imageView.frame.origin.y + _cover.imageView.frame.size.height - 20, _cover.imageView.frame.size.width, 20)];
        _label.backgroundColor = [UIColor colorWithRed:0.26f green:0.50f blue:0.678 alpha:0.95];
        _label.text = book.name;
        _label.font = [UIFont systemFontOfSize:13.0f];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        [_cover addSubview:_label];
        
        _downloadProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _downloadProgressView.frame = CGRectMake(_cover.imageView.frame.origin.x, _cover.imageView.frame.origin.y + _cover.imageView.frame.size.height - 13 , _cover.imageView.frame.size.width, 5);
        _downloadProgressView.progress = 0.0f;
        _downloadProgressView.hidden = YES;
        [_cover addSubview:_downloadProgressView];
    
        _badge = [CustomBadge customBadgeWithString:@"0" withStringColor:[UIColor whiteColor] withInsetColor:[UIColor redColor] withBadgeFrame:YES withBadgeFrameColor:[UIColor whiteColor] withScale:1.0f withShining:YES];
        [self refreshBadgeNumber];
        [_cover addSubview:_badge];
        
    }
    return self;
}

- (void) dismissNewBadge {
    [_badge setHidden:YES];
}


- (void) refreshBadgeNumber {
    Bookmark* bookmark = [DataBase getDefaultBookmarkForBook:self.book];
    NSMutableArray* sections = [DataBase getAllSectionsOfBook:self.book];
    
    NSUInteger unreadCount = [sections count];
    for (Section* sec in sections) {
        if (bookmark.section_id == sec.section_id) {
            break;
        }
        unreadCount--;
    }
    
    if (unreadCount > 0) {
        NSString* numberStr = [NSString stringWithFormat:@"%d", unreadCount];
        _badge = [CustomBadge customBadgeWithString:numberStr withStringColor:[UIColor whiteColor] withInsetColor:[UIColor redColor] withBadgeFrame:YES withBadgeFrameColor:[UIColor whiteColor] withScale:1.0f withShining:YES];
        _badge.frame = CGRectMake(_cover.frame.origin.x + _cover.frame.size.width - _badge.frame.size.width / 2, _cover.frame.origin.y - _badge.frame.size.height / 2 , _badge.frame.size.width, _badge.frame.size.height);
        _badge.hidden = NO;
    } else {
        _badge.hidden = YES;
    }

}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSTimeInterval system = [[NSProcessInfo processInfo] systemUptime];
    
    if (system - event.timestamp > 0.01) {
        if (!_deleteButton.clipsToBounds && !_deleteButton.hidden && _deleteButton.alpha > 0 && event.type == UIEventTypeTouches) {
            CGPoint subPoint = [_deleteButton convertPoint:point fromView:self];
            if(subPoint.x > 0 && subPoint.y > 0 && subPoint.x < _deleteButton.frame.size.width && subPoint.y <  _deleteButton.frame.size.height) {
                [_deleteButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }

    // use this to pass the 'touch' onward in case no subviews trigger the touch
    return [super hitTest:point withEvent:event];
}

- (void)setImage:(UIImage *)image {
    if ([_image isEqual:image]) {
        return;
    }
    _image = image;
    
    [_cover setImage:_image forState:UIControlStateNormal];
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

- (void) beginDownload {
    _downloadProgressView.progress = 0.0f;
    [_downloadProgressView setHidden:NO];
}

- (void) endDownload {
    [_downloadProgressView setHidden:YES];
}


- (void)deleteButtonClicked:(id)sender {
    if (!_deleteMode) {
        _deleteMode = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除书籍" message:@"确认删除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: break;
        case 1:
            if (_delegate && [_delegate respondsToSelector:@selector(deleteBook:withBookView:)]) {
                [_delegate deleteBook:self.book withBookView:self];
            }
            break;
    }
}

- (void)buttonClicked:(id)sender {
    if (!_edited) {
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate switchToReader:self.book fromBookView:self];
    }
}

@end
