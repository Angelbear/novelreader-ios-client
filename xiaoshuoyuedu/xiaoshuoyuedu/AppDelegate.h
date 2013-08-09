//
//  AppDelegate.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-21.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookView.h"
#import "RemoteControlViewController.h"
#import "MSViewDeckController.h"
@class MSNavigationPaneViewController, MSReaderViewController, Book, BookView, SectionReaderTableViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BookView* _bookView;
    CGPoint _bookViewOrignCenter;
    UIModalTransitionStyle _modalTransitionStyle;
    BOOL _isReading;
}
@property (strong, nonatomic) NSMutableArray *windows;
@property (strong, nonatomic) UIWindow *currentWindow;
@property (strong, nonatomic) UIWindow *mainWindow;
@property (strong, nonatomic) UIViewController* containerViewController;
@property (strong, nonatomic) MSNavigationPaneViewController *navigationPaneViewController;
@property (strong, nonatomic) NSMutableArray* readerDeckControllers;
@property (strong, nonatomic) MSViewDeckController* readerDeckController;
@property (strong, nonatomic) RemoteControlViewController* remoteControllViewController;
@property (strong, nonatomic) BookView* currentBookView;
@property (nonatomic, assign) CGPoint bookViewOrignCenter;
@property (nonatomic, assign) BOOL isReading;
@property (nonatomic, assign) UIModalTransitionStyle modalTransitionStyle;
- (void) switchToReader:(Book*) book;
- (void) switchToReader:(Book*) book fromBookView:(BookView*)view;
- (void) switchToNavitation;
- (BOOL) isReaderRightPanelOpen;
- (BOOL) openReaderRightPanel;
- (void) switchToWindow:(UIWindow*) window;
@end