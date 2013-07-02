//
//  MSNavigationPaneViewController+iBooksOpen.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-1.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "MSNavigationPaneViewController.h"
#import "BookView.h"
typedef enum {
    UIModalTransitionStyleOpenBooks = 0x01 << 7,
    
} UIModalTransitionStyleCustom;

@interface MSNavigationPaneViewController (iBooksOpen)
- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
- (void)dismissFlipSideViewController:(id)controller;
@end
