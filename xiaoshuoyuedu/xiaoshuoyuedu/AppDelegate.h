//
//  AppDelegate.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-21.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MSNavigationPaneViewController, MSReaderViewController;
@class Book;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MSNavigationPaneViewController *navigationPaneViewController;
@property (strong, nonatomic) MSNavigationPaneViewController *readerPaneViewController;
- (void) switchToReader:(Book*) book;
- (void) switchToNavitation;
- (void) openReaderPaneView;
@end