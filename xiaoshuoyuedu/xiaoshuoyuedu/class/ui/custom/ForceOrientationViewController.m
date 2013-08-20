//
//  ForceOrientationViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-12.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "ForceOrientationViewController.h"

@interface ForceOrientationViewController ()

@end

@implementation ForceOrientationViewController

- (id) initWithOrientation:(UIInterfaceOrientation)orientation {
    self = [super init];
    if (self) {
        _orientation = orientation;
    }
    return self;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return 1 << _orientation;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    NSLog(@"preferredInterfaceOrientationForPresentation %d", _orientation);
    return _orientation;
}

@end
