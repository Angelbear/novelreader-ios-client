//
//  AppDelegate.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-21.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "AppDelegate.h"
#import "MSNavigationPaneViewController.h"
#import "MSMasterViewController.h"
#import "DataBase.h"
#import "Book.h"
#import "MSReaderViewController.h"
#import "MSNavigationPaneViewController+iBooksOpen.h"
#import "SectionReaderTableViewController.h"
#import <ViewDeck/IISideController.h>
#import "Common.h"
#import <Crashlytics/Crashlytics.h>
#import "ReaderCacheManager.h"

@interface AppDelegate ()
- (UIWindow *)  createWindowForScreen:(UIScreen *)screen;
- (void)        addViewController:(UIViewController *)controller toWindow:(UIWindow *)window;
- (void)        screenDidConnect:(NSNotification *) notification;
- (void)        screenDidDisconnect:(NSNotification *) notification;
@end


@implementation AppDelegate
@synthesize currentBookView =_bookView;
@synthesize bookViewOrignCenter = _bookViewOrignCenter;
@synthesize modalTransitionStyle = _modalTransitionStyle;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"8946d07e106863f557b755bb244b513a82a3f788"];
    
    UIWindow    *_window    = nil;
    NSArray     *_screens   = nil;
    
    self.windows = [[NSMutableArray alloc] init];
    
    self.remoteControllViewController = [[RemoteControlViewController alloc] initWithNibName:@"RemoteControlViewController" bundle:nil];
    _screens = [UIScreen screens];
    for (UIScreen *_screen in _screens){
        if (_screen == [UIScreen mainScreen]){
            _window = [self createWindowForScreen:_screen];
            
            self.currentWindow = _window;
            self.mainWindow = _window;
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            
            [DataBase initialize_database];
            if ([[UINavigationBar class]respondsToSelector:@selector(appearance)]) {
                [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation_bar_bg"] forBarMetrics:UIBarMetricsDefault];
            }
            
            CGRect deviceFrame = _screen.bounds;
            
            self.readerDeckControllers = [[NSMutableArray alloc] initWithCapacity:0];
            
            self.navigationPaneViewController = [[MSNavigationPaneViewController alloc] init];
            MSMasterViewController *masterViewController = [[MSMasterViewController alloc] init];
            masterViewController.navigationPaneViewController = self.navigationPaneViewController;
            self.navigationPaneViewController.masterViewController = masterViewController;
            self.navigationPaneViewController.view.frame = CGRectMake(0, 0, deviceFrame.size.width, deviceFrame.size.height);
            
            self.readerDeckController = [self createNewBookViewDeckController:_window];
            
            _window.rootViewController = self.navigationPaneViewController;
            [_window insertSubview:self.readerDeckController.view aboveSubview:self.navigationPaneViewController.view];


            
            [_window makeKeyAndVisible];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(screenDidConnect:)
												 name:UIScreenDidConnectNotification
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(screenDidDisconnect:)
												 name:UIScreenDidDisconnectNotification
											   object:nil];
    return YES;
}

- (IIViewDeckController*) createNewBookViewDeckController:(UIWindow*) window {
    CGRect deviceFrame = window.screen.bounds;
    MSReaderViewController *readerMasterViewController = [[MSReaderViewController alloc] init];
    
    CGFloat openSize = isiPad ? (deviceFrame.size.width / 2) : deviceFrame.size.width - 50;
    
    IISideController *constrainedRightController = [[IISideController alloc] initWithViewController:readerMasterViewController constrained:openSize];
   
    SectionReaderTableViewController* readerViewController = [[SectionReaderTableViewController alloc] init];
    
    IIViewDeckController* readerDeckController = [[IIViewDeckController alloc] initWithCenterViewController:readerViewController leftViewController:nil rightViewController:constrainedRightController];
    readerDeckController.openSlideAnimationDuration = 0.15f;
    readerDeckController.closeSlideAnimationDuration = 0.15f;
    readerDeckController.rightSize = deviceFrame.size.width  - openSize;
    readerDeckController.elastic = NO;
    
    readerMasterViewController.deckViewController = readerDeckController;
    readerMasterViewController.currentReaderViewController = readerViewController;
    
    readerDeckController.view.frame = CGRectMake(deviceFrame.size.width, 0, deviceFrame.size.width, deviceFrame.size.height);
    return readerDeckController;    
}

- (void) animationToReader:(BookView*)bookView {
    CGRect deviceFrame = self.currentWindow.screen.bounds;
    CGFloat statusHeight = isiOS7 ? 0 : 20;
    [UIView transitionWithView:self.currentWindow
                      duration:0.25f
                       options:UIViewAnimationOptionTransitionNone
                    animations:^
     {
         [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
         self.readerDeckController.view.frame = deviceFrame;
         self.navigationPaneViewController.view.frame = CGRectMake(-deviceFrame.size.width, statusHeight, deviceFrame.size.width, deviceFrame.size.height - statusHeight);
         
     }
    completion:^(BOOL finished){
        self.navigationPaneViewController.view.frame = CGRectMake(-deviceFrame.size.width - 40, statusHeight, deviceFrame.size.width, deviceFrame.size.height - statusHeight);
    }];
}

- (void) animationBack {
    CGFloat statusHeight = isiOS7 ? 0 : 20;
    CGRect deviceFrame = self.currentWindow.screen.bounds;
     self.navigationPaneViewController.view.frame = CGRectMake(-deviceFrame.size.width, statusHeight, deviceFrame.size.width, deviceFrame.size.height - statusHeight);
    [UIView transitionWithView:self.currentWindow
                      duration:0.25f
                       options:UIViewAnimationOptionTransitionNone
                    animations:^
     {
         self.navigationPaneViewController.view.frame = CGRectMake(0, statusHeight, deviceFrame.size.width,  deviceFrame.size.height - statusHeight);
         self.readerDeckController.view.frame = CGRectMake(deviceFrame.size.width, 0, deviceFrame.size.width, deviceFrame.size.height);
         
     }
    completion:^(BOOL finished){
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }];

}

- (IIViewDeckController* )findViewDeckController:(Book*) book {
    for (IIViewDeckController* viewDeckController in self.readerDeckControllers) {
        MSReaderViewController *readerMasterViewController = (MSReaderViewController*)viewDeckController.rightController;
        if (readerMasterViewController.book.book_id == book.book_id) {
            return viewDeckController;
        }
    }
    IIViewDeckController* viewDeckController = [self createNewBookViewDeckController:self.currentWindow];
    MSReaderViewController *readerMasterViewController = (MSReaderViewController*)viewDeckController.rightController;
    [self.readerDeckControllers addObject:viewDeckController];
    [readerMasterViewController loadBook:book];
    return viewDeckController;
}

- (void) switchToReader:(Book*) book {
    MSReaderViewController *readerMasterViewController = (MSReaderViewController*)self.readerDeckController.rightController;
    if (readerMasterViewController.book.book_id != book.book_id) {
       [readerMasterViewController loadBook:book];
    }
    [self animationToReader:nil];
}

- (void) switchToReader:(Book*) book fromBookView:(BookView*)view {
    self.currentBookView = view;
    MSReaderViewController *readerMasterViewController = (MSReaderViewController*)self.readerDeckController.rightController;
    if (readerMasterViewController.book.book_id != book.book_id) {
         [readerMasterViewController loadBook:book];
    }
    [self animationToReader:view];
}

- (void) switchToNavitation {
    [self animationBack];
}

- (BOOL) isReaderRightPanelOpen {
    return [self.readerDeckController isAnySideOpen];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
}

#pragma mark -
#pragma mark Private methods

- (UIWindow *) createWindowForScreen:(UIScreen *)screen {
    UIWindow    *_window    = nil;
    CGRect deviceFrame = screen.bounds;
    // Do we already have a window for this screen?
    for (UIWindow *window in self.windows){
        if (window.screen == screen){
            _window = window;
        }
    }
    // Still nil? Create a new one.
    if (_window == nil){
        _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, deviceFrame.size.width * 2, deviceFrame.size.height)];
        [_window setScreen:screen];
        [self.windows addObject:_window];
    }
    
    return _window;
}

- (void) addViewController:(UIViewController *)controller toWindow:(UIWindow *)window {
    [window setRootViewController:controller];
    [window setHidden:NO];
}

- (void) switchToWindow:(UIWindow*) window {
    if (window == self.mainWindow) {
        [self.remoteControllViewController removeFromParentViewController];
    } else {
        self.mainWindow.rootViewController = self.remoteControllViewController;
        [self.mainWindow makeKeyAndVisible];
    }
    [self.navigationPaneViewController removeFromParentViewController];
    [self.readerDeckController removeFromParentViewController];
    
    CGRect deviceFrame = window.screen.bounds;
    self.navigationPaneViewController.view.frame = CGRectMake(-deviceFrame.size.width -40 , 0, deviceFrame.size.width, deviceFrame.size.height);
    
    self.readerDeckController.view.frame =  CGRectMake(0, 0, deviceFrame.size.width, deviceFrame.size.height);
    
    
    window.rootViewController = self.navigationPaneViewController;
    [window insertSubview:self.readerDeckController.view aboveSubview:self.navigationPaneViewController.view];
    
    self.currentWindow = window;
    [window makeKeyAndVisible];
    
    [[ReaderCacheManager init_instance] clearAllSplitInfos];
    [self switchToReader:self.currentBookView.book];
     SectionReaderTableViewController* sectionReader = (SectionReaderTableViewController*)self.readerDeckController.centerController;
    [sectionReader prepareForRead];
}

- (void) screenDidConnect:(NSNotification *) notification {
    UIScreen                    *_screen            = nil;
    UIWindow                    *_window            = nil;
    
    NSLog(@"Screen connected");
    _screen = [notification object];
    _window = [self createWindowForScreen:_screen];
    [self.windows addObject:_window];

    return;
}

- (void) screenDidDisconnect:(NSNotification *) notification {
    UIScreen    *_screen    = nil;
    
    NSLog(@"Screen disconnected");
    int windowIndex = -1;
    _screen = [notification object];
    for (UIWindow *_window in self.windows){
        if (_window.screen == _screen){
            windowIndex = [self.windows indexOfObject:_window];
        }
    }
    if (windowIndex >= 0) {
        [self.windows removeObjectAtIndex:windowIndex];
    }
    return;
}

@end
