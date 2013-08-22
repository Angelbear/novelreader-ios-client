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
@end


@implementation AppDelegate
@synthesize currentBookView =_bookView;
@synthesize isReading = _isReading;
@synthesize orientation = _orientation;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"8946d07e106863f557b755bb244b513a82a3f788"];
    
    _isReading = NO;
    _userDefaults = [GVUserDefaults standardUserDefaults];
    _userDefaults.orientationLocked = NO;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
 
    [[DataBase get_database_instance] initialize_database];
    
    if ([[UINavigationBar class]respondsToSelector:@selector(appearance)]) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation_bar_bg"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navigationPaneViewController = [[MSMainPaneViewController alloc] init];
    MSMasterViewController *masterViewController = [[MSMasterViewController alloc] init];
    masterViewController.navigationPaneViewController = self.navigationPaneViewController;
    self.navigationPaneViewController.masterViewController = masterViewController;
    
    self.readerDeckController =  [[MSViewDeckController alloc] init];
    
    self.window.rootViewController = self.navigationPaneViewController;
    
    [self.window makeKeyAndVisible];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
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
    CGRect deviceFrame = [UIScreen mainScreen].bounds;
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
    CGRect deviceFrame = [UIScreen mainScreen].bounds;
    CGFloat statusHeight = isiOS7 ? 20 : 0;
    void (^completionBlock)(BOOL) =  ^(BOOL finished) {
        [self.navigationPaneViewController removeFromParentViewController];
    };

    [UIView transitionWithView:self.window
                      duration:READER_DECK_ANIMATION_TIME
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.window.rootViewController = self.readerDeckController;
                        if (!isiOS7) {
                            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
                        }
                        switch (_orientation) {
                            case UIInterfaceOrientationPortrait:
                                self.readerDeckController.view.frame = CGRectMake(0, statusHeight, deviceFrame.size.width,  deviceFrame.size.height - statusHeight);
                                break;
                            case UIInterfaceOrientationLandscapeRight:
                                self.readerDeckController.view.frame = CGRectMake(0, 0, deviceFrame.size.width - statusHeight,  deviceFrame.size.height);
                                break;
                            case UIInterfaceOrientationLandscapeLeft:
                                self.readerDeckController.view.frame = CGRectMake(statusHeight, 0, deviceFrame.size.width - statusHeight,  deviceFrame.size.height);
                                break;
                            default:
                                break;
                        }
                    }
                    completion:completionBlock];
}

- (void) animationBack {
    _isReading = NO;
    CGRect deviceFrame = [UIScreen mainScreen].bounds;
    CGFloat statusHeight = isiOS7 ? 0 : 20;
    void (^completionBlock)(BOOL) = ^(BOOL finished) {
        [self.readerDeckController removeFromParentViewController];
        switch (_orientation) {
            case UIInterfaceOrientationPortrait:
                self.navigationPaneViewController.view.frame = CGRectMake(0, statusHeight, deviceFrame.size.width,  deviceFrame.size.height - statusHeight);
                break;
            case UIInterfaceOrientationLandscapeRight:
                self.navigationPaneViewController.view.frame = CGRectMake(0, 0, deviceFrame.size.width - statusHeight,  deviceFrame.size.height);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                self.navigationPaneViewController.view.frame = CGRectMake(statusHeight, 0, deviceFrame.size.width - statusHeight,  deviceFrame.size.height);
                break;
            default:
                break;
        }
    };
    
    [UIView transitionWithView:self.window
                      duration:READER_DECK_ANIMATION_TIME
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if (!isiOS7) {
                            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
                        }
                        self.window.rootViewController = self.navigationPaneViewController;
                    }
                    completion:completionBlock];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
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


@end
