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
#import "MSReaderViewController.h"
#import "MSNavigationPaneViewController+iBooksOpen.h"

@implementation AppDelegate
@synthesize currentBookView =_bookView;
@synthesize bookViewOrignCenter = _bookViewOrignCenter;
@synthesize modalTransitionStyle = _modalTransitionStyle;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DataBase initialize_database];
    if ([[UINavigationBar class]respondsToSelector:@selector(appearance)]) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation_bar_bg"] forBarMetrics:UIBarMetricsDefault];
    }
    
    CGRect deviceFrame = [UIScreen mainScreen].bounds;

    self.containerViewController = [[UIViewController alloc] init];
    self.containerViewController.view.frame = CGRectMake(0, 0, deviceFrame.size.width * 2, deviceFrame.size.height);
    
    self.navigationPaneViewController = [[MSNavigationPaneViewController alloc] init];
    MSMasterViewController *masterViewController = [[MSMasterViewController alloc] init];
    masterViewController.navigationPaneViewController = self.navigationPaneViewController;
    self.navigationPaneViewController.masterViewController = masterViewController;
    self.navigationPaneViewController.view.frame = deviceFrame;

    
    self.readerPaneViewController = [[MSNavigationPaneViewController alloc] init];
    [self.readerPaneViewController.touchForwardingClasses addObject:UITableView.class];
    MSReaderViewController *readerMasterViewController = [[MSReaderViewController alloc] init];
    readerMasterViewController.navigationPaneViewController = self.readerPaneViewController;
    self.readerPaneViewController.masterViewController = readerMasterViewController;
    

    self.readerPaneViewController.view.frame = CGRectMake(deviceFrame.size.width + 40, 0, deviceFrame.size.width, deviceFrame.size.height);
    
    //[self.containerViewController.view insertSubview:self.readerPaneViewController.view aboveSubview:self.containerViewController.view];
    //[self.containerViewController.view addSubview:self.navigationPaneViewController.view];
    
    //[self.navigationPaneViewController.view insertSubview:self.readerPaneViewController.view belowSubview:self.navigationPaneViewController.paneViewController.view];
    
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, deviceFrame.size.width * 2, deviceFrame.size.height)];
    self.window.rootViewController = self.navigationPaneViewController;
    [self.window insertSubview:self.readerPaneViewController.view aboveSubview:self.navigationPaneViewController.view];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void) animationToReader {
    CGRect deviceFrame = [UIScreen mainScreen].bounds;
    [UIView transitionWithView:self.containerViewController.view
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionNone
                    animations:^
     {
         self.readerPaneViewController.view.frame = deviceFrame;
         self.navigationPaneViewController.view.frame = CGRectMake(-deviceFrame.size.width, 0, deviceFrame.size.width, deviceFrame.size.height);
         
     }
    completion:^(BOOL finished){
        self.navigationPaneViewController.view.frame = CGRectMake(-deviceFrame.size.width - 40, 0, deviceFrame.size.width, deviceFrame.size.height);
    }];
}

- (void) animationBack {
    CGRect deviceFrame = [UIScreen mainScreen].bounds;
     self.navigationPaneViewController.view.frame = CGRectMake(-deviceFrame.size.width, 0, deviceFrame.size.width, deviceFrame.size.height);
    [UIView transitionWithView:self.containerViewController.view
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionNone
                    animations:^
     {
         self.navigationPaneViewController.view.frame = CGRectMake(0, 0, deviceFrame.size.width,  deviceFrame.size.height);
         self.readerPaneViewController.view.frame = CGRectMake(deviceFrame.size.width, 0, deviceFrame.size.width, deviceFrame.size.height);
         
     }
    completion:^(BOOL finished){
    }];

}

- (void) switchToReader:(Book*) book {
    if ( [self.readerPaneViewController presentingViewController] == nil) {
        //self.readerPaneViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        MSReaderViewController *readerMasterViewController = (MSReaderViewController*)self.readerPaneViewController.masterViewController;
        [readerMasterViewController loadBook:book];
        [self animationToReader];
        //[self.navigationPaneViewController presentModalViewController: self.readerPaneViewController animated:YES];
    } else {
        [self switchToNavitation];
    }
}

- (void) switchToReader:(Book*) book fromBookView:(BookView*)view {
    if ( [self.readerPaneViewController presentingViewController] == nil) {
       // self.readerPaneViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        self.currentBookView = view;
        MSReaderViewController *readerMasterViewController = (MSReaderViewController*)self.readerPaneViewController.masterViewController;
        [readerMasterViewController loadBook:book];
        [self animationToReader];
        //[self.navigationPaneViewController presentModalViewController: self.readerPaneViewController animated:YES];
    } else {
        self.currentBookView = nil;
        [self switchToNavitation];
    }
}

- (void) openReaderPaneView {
    [self.readerPaneViewController setPaneState:MSNavigationPaneStateOpen animated:YES completion:nil];
}


- (void) switchToNavitation {
    [self animationBack];
    //[self.navigationPaneViewController dismissFlipSideViewController:nil];
    //[self.window.rootViewController dismissModalViewControllerAnimated:YES];
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
