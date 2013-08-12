//
//  MSMainPaneViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-12.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "MSMainPaneViewController.h"
@interface MSMainPaneViewController ()

@end

@implementation MSMainPaneViewController

- (id) init {
    self = [super init];
    if (self) {
        self.userDefaults = [GVUserDefaults standardUserDefaults];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (self.userDefaults.orientationLocked && toInterfaceOrientation != self.userDefaults.fixedOrientation) {
        return NO;
    }
    return YES;
}

- (BOOL)shouldAutorotate {
    if (self.userDefaults.orientationLocked && self.interfaceOrientation == self.userDefaults.fixedOrientation) {
        return NO;
    }
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape);
}

@end
