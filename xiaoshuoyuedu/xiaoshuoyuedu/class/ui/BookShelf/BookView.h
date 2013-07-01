/*
 GSBookView.h
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

#import <UIKit/UIKit.h>
#import "GSBookView.h"
#import <CustomBadge/CustomBadge.h>
@class Book, BookView;

@protocol DeleteBookDelegate <NSObject>
- (void) deleteBook:(Book*)book withBookView:(BookView*)view;
@end

@interface BookView : UIView <GSBookView, UIAlertViewDelegate>{
    UIImage *_image;
    UIButton *_cover;
    UIButton *_deleteButton;
    UILabel *_label;
    UIProgressView* _downloadProgressView;
    CustomBadge *_badge;
    BOOL _deleteMode;
    UIView* _content;
    __weak id<DeleteBookDelegate> _delegate;
}

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, strong) UIButton *cover;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) CustomBadge *badge;
@property (nonatomic, strong) UIView* content;
@property (nonatomic, strong) UIProgressView* downloadProgressView;
@property (nonatomic, assign) BOOL edited;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) Book *book;

- (id)initWithFrame:(CGRect)frame book:(Book*)book withCaller:(id<DeleteBookDelegate>) caller;
- (void) beginDownload;
- (void) endDownload;
- (void) refreshBadgeNumber;
@end
