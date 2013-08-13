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
@interface MSViewDeckController ()

@end

@implementation MSViewDeckController

- (id) init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        CGRect deviceFrame = [UIScreen mainScreen].bounds;
        self.readerMasterViewController = [[MSReaderViewController alloc] init];
        CGFloat openSize = isiPad ? (deviceFrame.size.width / 2) : deviceFrame.size.width - 50;
        self.userDefaults = [GVUserDefaults standardUserDefaults];
        self.constrainedRightController = [[IISideController alloc] initWithViewController:self.readerMasterViewController constrained:openSize];
        
        self.readerViewController = [[ReaderPagingViewController alloc] init];
        
        self.centerController =  self.readerViewController;
        self.rightController = self.constrainedRightController;
        
        self.openSlideAnimationDuration = 0.15f;
        self.closeSlideAnimationDuration = 0.15f;
        self.rightSize = deviceFrame.size.width  - openSize;
        self.elastic = NO;
        self.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractive;
        
        self.readerMasterViewController.deckViewController = self;
        self.readerMasterViewController.currentReaderViewController = self.readerViewController;
        
        self.view.frame = CGRectMake(deviceFrame.size.width, 0, deviceFrame.size.width, deviceFrame.size.height);
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == self.userDefaults.fixedOrientation);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.readerViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    CGRect deviceFrame = [UIScreen mainScreen].bounds;
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        CGFloat openSize = isiPad ? (deviceFrame.size.width / 2) : deviceFrame.size.width - 50;
        self.rightSize = deviceFrame.size.height  - openSize;
    } else {
        CGFloat openSize = isiPad ? (deviceFrame.size.width / 2) : deviceFrame.size.width - 50;
        self.rightSize = deviceFrame.size.width  - openSize;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.readerViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self closeRightView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.readerViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void) forceOrientation:(UIInterfaceOrientation)orientation {
    ForceOrientationViewController* controller = [[ForceOrientationViewController alloc] initWithOrientation:orientation];
    [self presentViewController:controller animated:NO completion:^{
        [controller dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
