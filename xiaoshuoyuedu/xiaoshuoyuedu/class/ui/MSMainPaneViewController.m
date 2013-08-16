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
    return self.userDefaults.fixedOrientation;
}

- (BOOL)shouldAutorotate {
    return (self.userDefaults.orientationLocked == NO) || (self.interfaceOrientation != self.userDefaults.fixedOrientation);
}

- (NSUInteger)supportedInterfaceOrientations {
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape);
}

@end
