//
//  AppDelegate.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-21.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookView.h"
#import "MSViewDeckController.h"
#import "GVUserDefaults+Properties.h"
@class MSMainPaneViewController, MSReaderViewController, Book, BookView, SectionReaderTableViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BookView* _bookView;
    UIInterfaceOrientation _orientation;
    BOOL _isReading;
    GVUserDefaults* _userDefaults;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MSMainPaneViewController *navigationPaneViewController;
@property (strong, nonatomic) MSViewDeckController* readerDeckController;
@property (strong, nonatomic) BookView* currentBookView;
@property (nonatomic, assign) BOOL isReading;
@property (nonatomic, assign) UIInterfaceOrientation orientation;

- (void) switchToReader:(Book*) book;
- (void) switchToReader:(Book*) book fromBookView:(BookView*)view;
- (void) switchToNavitation;
- (BOOL) isReaderRightPanelOpen;
- (BOOL) openReaderRightPanel;
@end