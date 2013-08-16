//
//  AppDelegate.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-21.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "AppDelegate.h"
#import "MSMainPaneViewController.h"
#import "MSMasterViewController.h"
#import "DataBase.h"
#import "Book.h"
#import "BookView.h"
#import "MSReaderViewController.h"
#import <ViewDeck/IISideController.h>
#import "Common.h"
#import <Crashlytics/Crashlytics.h>
#import "ReaderCacheManager.h"
#import "ReaderPagingViewController.h"
#import "GVUserDefaults+Properties.h"

@interface AppDelegate ()
- (UIWindow *)  createWindowForScreen:(UIScreen *)screen;
- (void)        addViewController:(UIViewController *)controller toWindow:(UIWindow *)window;
- (void)        screenDidConnect:(NSNotification *) notification;
- (void)        screenDidDisconnect:(NSNotification *) notification;
@end


@implementation AppDelegate
@synthesize currentBookView =_bookView;
@synthesize isReading = _isReading;
@synthesize orientation = _orientation;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"8946d07e106863f557b755bb244b513a82a3f788"];
    
    UIWindow    *_window    = nil;
    NSArray     *_screens   = nil;
    _isReading = NO;
    
    _userDefaults = [GVUserDefaults standardUserDefaults];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    self.windows = [[NSMutableArray alloc] init];
    
    self.remoteControllViewController = [[RemoteControlViewController alloc] initWithNibName:@"RemoteControlViewController" bundle:nil];
    _screens = [UIScreen screens];
    for (UIScreen *_screen in _screens){
        if (_screen == [UIScreen mainScreen]){
            _window = [self createWindowForScreen:_screen];
            
            self.currentWindow = _window;
            self.mainWindow = _window;
         
            [[DataBase get_database_instance] initialize_database];
            if ([[UINavigationBar class]respondsToSelector:@selector(appearance)]) {
                [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation_bar_bg"] forBarMetrics:UIBarMetricsDefault];
            }
            
            self.navigationPaneViewController = [[MSMainPaneViewController alloc] init];
            MSMasterViewController *masterViewController = [[MSMasterViewController alloc] init];
            masterViewController.navigationPaneViewController = self.navigationPaneViewController;
            self.navigationPaneViewController.masterViewController = masterViewController;
            
            self.readerDeckController =  [[MSViewDeckController alloc] init];
            
            _window.rootViewController = self.navigationPaneViewController;
            
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object: nil];

    return YES;
}

- (void) rotateEnd {
     if (_orientation == UIInterfaceOrientationPortrait) {
         [self.readerDeckController didRotateFromInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
     } else {
         [self.readerDeckController didRotateFromInterfaceOrientation:UIInterfaceOrientationPortrait];
     }
}

- (void)forceLayout:(UIInterfaceOrientation)orientation
{
    CGRect deviceFrame = self.currentWindow.screen.bounds;
    if (_orientation != orientation) {
        if (orientation == UIInterfaceOrientationPortrait) {
            [self.readerDeckController willAnimateRotationToInterfaceOrientation:UIInterfaceOrientationPortrait duration:ROTATION_ANIMATION_TIME];
            [UIView beginAnimations:@"orientation" context:NULL];
            [UIView setAnimationDuration:ROTATION_ANIMATION_TIME];
            [UIView setAnimationDidStopSelector:@selector(rotateEnd)];
            [UIView setAnimationDelegate:self];
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait  animated:NO];
            [self.readerDeckController.view setTransform: CGAffineTransformMakeRotation(0.0f)];
            [self.readerDeckController.view setFrame:deviceFrame];
            [UIView commitAnimations];
        } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
            [self.readerDeckController willAnimateRotationToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:ROTATION_ANIMATION_TIME];
            [UIView beginAnimations:@"orientation" context:NULL];
            [UIView setAnimationDuration:ROTATION_ANIMATION_TIME];
            [UIView setAnimationDidStopSelector:@selector(rotateEnd)];
            [UIView setAnimationDelegate:self];
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft  animated:NO];
            [self.readerDeckController.view setTransform: CGAffineTransformMakeRotation(- M_PI / 2)];
            [self.readerDeckController.view setFrame:deviceFrame];
            [UIView commitAnimations];
        }
        _orientation = orientation;
    }
}

- (void) animationToReader:(BookView*)bookView {
    _isReading = YES;
    CGRect deviceFrame = self.currentWindow.screen.bounds;
    CGFloat statusHeight = isiOS7 ? 0 : 20;
    [self.currentWindow insertSubview:self.readerDeckController.view aboveSubview:self.navigationPaneViewController.view];
    self.currentWindow.rootViewController = self.readerDeckController;
    [self.navigationPaneViewController removeFromParentViewController];
    [self.currentWindow insertSubview:self.navigationPaneViewController.view belowSubview:self.readerDeckController.view];
    
    void (^completionBlock)(BOOL) = ^(BOOL finished) {
        [self.navigationPaneViewController removeFromParentViewController];
    };
    
    switch(_orientation) {
        case UIInterfaceOrientationPortrait: {
            self.readerDeckController.view.frame = CGRectMake(deviceFrame.size.width, 0, deviceFrame.size.width, deviceFrame.size.height);
            [UIView transitionWithView:self.currentWindow
                              duration:READER_DECK_ANIMATION_TIME
                               options:UIViewAnimationOptionTransitionNone
                            animations:^
             {
                 [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
                 self.readerDeckController.view.frame = deviceFrame;
                 self.navigationPaneViewController.view.frame = CGRectMake(-deviceFrame.size.width, statusHeight, deviceFrame.size.width, deviceFrame.size.height - statusHeight);
                 
             }
                            completion:completionBlock];
        }
            break;
        case UIInterfaceOrientationLandscapeRight: {
            self.readerDeckController.view.frame = CGRectMake( 0, deviceFrame.size.height, deviceFrame.size.width, deviceFrame.size.height);
            [UIView transitionWithView:self.currentWindow
                              duration:READER_DECK_ANIMATION_TIME
                               options:UIViewAnimationOptionTransitionNone
                            animations:^
             {
                 [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
                 self.readerDeckController.view.frame = deviceFrame;
                 self.navigationPaneViewController.view.frame = CGRectMake(0, -deviceFrame.size.height, deviceFrame.size.width - statusHeight, deviceFrame.size.height );
                 
             }
                            completion:completionBlock];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            self.readerDeckController.view.frame = CGRectMake( 0, - deviceFrame.size.height, deviceFrame.size.width, deviceFrame.size.height);
            [UIView transitionWithView:self.currentWindow
                              duration:READER_DECK_ANIMATION_TIME
                               options:UIViewAnimationOptionTransitionNone
                            animations:^
             {
                 [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
                 self.readerDeckController.view.frame = deviceFrame;
                 self.navigationPaneViewController.view.frame = CGRectMake(statusHeight, deviceFrame.size.height, deviceFrame.size.width - statusHeight, deviceFrame.size.height );
                 
             }
                            completion:completionBlock];
        }
            break;
        default:
            break;
    }
 
}

- (void) animationBack {
    _isReading = NO;
    CGFloat statusHeight = isiOS7 ? 0 : 20;
    CGRect deviceFrame = self.currentWindow.screen.bounds;
    [self.currentWindow insertSubview:self.navigationPaneViewController.view belowSubview:self.readerDeckController.view];
    self.currentWindow.rootViewController = self.navigationPaneViewController;
    [self.readerDeckController removeFromParentViewController];
    [self.currentWindow insertSubview:self.readerDeckController.view aboveSubview:self.navigationPaneViewController.view];
    
    
    [self.currentWindow insertSubview:self.navigationPaneViewController.view belowSubview:self.navigationPaneViewController.view];
    
    void (^completionBlock)(BOOL) = ^(BOOL finished) {
        [self.readerDeckController removeFromParentViewController];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    };
    
    switch (_orientation) {
        case UIInterfaceOrientationPortrait:{
            self.navigationPaneViewController.view.frame = CGRectMake(-deviceFrame.size.width, statusHeight, deviceFrame.size.width, deviceFrame.size.height - statusHeight);
            [UIView transitionWithView:self.currentWindow
                              duration:READER_DECK_ANIMATION_TIME
                               options:UIViewAnimationOptionTransitionNone
                            animations:^
             {
                 self.navigationPaneViewController.view.frame = CGRectMake(0, statusHeight, deviceFrame.size.width,  deviceFrame.size.height - statusHeight);
                 self.readerDeckController.view.frame = CGRectMake(deviceFrame.size.width, 0, deviceFrame.size.width, deviceFrame.size.height);
                 
             }
                            completion:completionBlock];
        }
            break;
        case UIInterfaceOrientationLandscapeRight: {
            self.navigationPaneViewController.view.frame = CGRectMake(0, -deviceFrame.size.height, deviceFrame.size.width - statusHeight, deviceFrame.size.height);
            [UIView transitionWithView:self.currentWindow
                              duration:READER_DECK_ANIMATION_TIME
                               options:UIViewAnimationOptionTransitionNone
                            animations:^
             {
                 self.navigationPaneViewController.view.frame = CGRectMake(0, 0, deviceFrame.size.width - statusHeight,  deviceFrame.size.height);
                 self.readerDeckController.view.frame = CGRectMake(0, deviceFrame.size.height, deviceFrame.size.width, deviceFrame.size.height);
                 
             }
                            completion:completionBlock];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft: {
            self.navigationPaneViewController.view.frame = CGRectMake(statusHeight, deviceFrame.size.height, deviceFrame.size.width - statusHeight, deviceFrame.size.height);
            [UIView transitionWithView:self.currentWindow
                              duration:READER_DECK_ANIMATION_TIME
                               options:UIViewAnimationOptionTransitionNone
                            animations:^
             {
                 self.navigationPaneViewController.view.frame = CGRectMake(statusHeight, 0, deviceFrame.size.width - statusHeight,  deviceFrame.size.height);
                 self.readerDeckController.view.frame = CGRectMake(0, -deviceFrame.size.height, deviceFrame.size.width, deviceFrame.size.height);
                 
             }
                            completion:completionBlock];
        }
            break;
        default:
            break;
    }
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

- (BOOL) openReaderRightPanel {
    return [self.readerDeckController openRightView];
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

- (void)orientationChanged:(NSNotification *)notification
{
    UIInterfaceOrientation newOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    if (newOrientation == UIInterfaceOrientationPortrait ||
        newOrientation == UIInterfaceOrientationLandscapeLeft ||
        newOrientation == UIInterfaceOrientationLandscapeRight) {
        if (!_userDefaults.orientationLocked) {
            _orientation = newOrientation;
        } else {
            _orientation = _userDefaults.fixedOrientation;
        }
            
    }
}


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
    ReaderPagingViewController* sectionReader = (ReaderPagingViewController*)self.readerDeckController.centerController;
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
