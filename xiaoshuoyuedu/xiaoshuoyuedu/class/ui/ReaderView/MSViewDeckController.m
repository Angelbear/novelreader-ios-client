//
//  MSViewDeckController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-9.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "MSViewDeckController.h"
#import "Common.h"
#import "ForceOrientationViewController.h"
#import "AppDelegate.h"

@interface MSViewDeckController ()

@end

@implementation MSViewDeckController

- (id) init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        CGRect deviceFrame = [UIScreen mainScreen].bounds;
        CGFloat Width = UIInterfaceOrientationIsLandscape(delegate.orientation) ? deviceFrame.size.height : deviceFrame.size.width;
        self.readerMasterViewController = [[MSReaderViewController alloc] init];
        CGFloat openSize = (isiPad || UIInterfaceOrientationIsLandscape(delegate.orientation)) ? (Width / 2) : Width - 50;
        self.userDefaults = [GVUserDefaults standardUserDefaults];
        self.constrainedRightController = [[IISideController alloc] initWithViewController:self.readerMasterViewController constrained:openSize];
        
        self.rightController = self.constrainedRightController;
        
        self.openSlideAnimationDuration = 0.15f;
        self.closeSlideAnimationDuration = 0.15f;
        self.rightSize = Width  - openSize;
        self.elastic = NO;
        self.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractive;
        
        self.readerMasterViewController.deckViewController = self;
    }
    return self;
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CGRect deviceFrame = [UIScreen mainScreen].bounds;
    CGFloat Width = UIInterfaceOrientationIsLandscape(delegate.orientation) ? deviceFrame.size.height : deviceFrame.size.width;
    CGFloat openSize = (isiPad || UIInterfaceOrientationIsLandscape(delegate.orientation)) ? (Width / 2) : Width - 50;
    [self.constrainedRightController setConstrainedSize:openSize];
    self.rightSize = Width  - openSize;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!isiOS7) {
        self.wantsFullScreenLayout = YES;
    } else {
        self.wantsFullScreenLayout = NO;
    }
    self.readerViewController = [[ReaderPagingViewController alloc] init];
    self.centerController =  self.readerViewController;
    self.readerMasterViewController.currentReaderViewController = self.readerViewController;
    if (isiOS7) {
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.readerViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.readerViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self closeRightViewAnimated:YES duration:duration completion:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.readerViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CGRect deviceFrame = [UIScreen mainScreen].bounds;
    CGFloat Width = UIInterfaceOrientationIsLandscape(delegate.orientation) ? deviceFrame.size.height : deviceFrame.size.width;
    CGFloat openSize = (isiPad || UIInterfaceOrientationIsLandscape(delegate.orientation)) ? (Width / 2) : Width - 50;
    [self.constrainedRightController setConstrainedSize:openSize];
    self.rightSize = Width  - openSize;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
