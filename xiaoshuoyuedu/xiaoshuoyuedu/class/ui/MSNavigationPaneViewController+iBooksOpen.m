//
//  MSNavigationPaneViewController+iBooksOpen.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-1.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "MSNavigationPaneViewController+iBooksOpen.h"
#import "AppDelegate.h"

#define DURING_TIME         1.0

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@implementation MSNavigationPaneViewController (iBooksOpen)


- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    delegate.modalTransitionStyle = modalViewController.modalTransitionStyle;
    if (delegate.modalTransitionStyle == UIModalTransitionStyleOpenBooks) {
        
        [self presentViewController:modalViewController animated:animated completion:nil];
        
    }
    else
    {
        [super presentModalViewController:modalViewController animated:animated];
    }
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    delegate.modalTransitionStyle = viewControllerToPresent.modalTransitionStyle;
    if (delegate.modalTransitionStyle == UIModalTransitionStyleOpenBooks) {
        NSAssert(delegate.currentBookView, @"_bookView can not be nil");
        
        delegate.currentBookView.content = viewControllerToPresent.view;
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGPoint deviceCenter = CGPointMake(screenBounds.size.width / 2.0f, screenBounds.size.height/2.0f - 20.0f);
        
        CGFloat scaleX = screenBounds.size.width / delegate.currentBookView.bounds.size.width;
        CGFloat scaleY = screenBounds.size.height / delegate.currentBookView.bounds.size.height;
        
        [delegate.currentBookView insertSubview:delegate.currentBookView.content aboveSubview:delegate.currentBookView.cover];
        
        delegate.currentBookView.content.transform = CGAffineTransformMakeScale(1/scaleX, 1/scaleY);
        
        delegate.currentBookView.content.frame = CGRectMake(0, 0,CGRectGetWidth(delegate.currentBookView.frame), CGRectGetHeight(delegate.currentBookView.frame));
        
        
        CATransform3D transformblank = CATransform3DMakeRotation(-M_PI_2 / 1.01, 0.0, 1.0, 0.0);
        transformblank.m34 = 1.0f / 250.0f;
        
        delegate.currentBookView.cover.layer.anchorPoint = CGPointMake(0, 0.5);
        delegate.currentBookView.cover.center = CGPointMake(0.0, delegate.currentBookView.cover.bounds.size.height/2.0); //compensate for anchor offset
        
        delegate.currentBookView.cover.opaque = YES;
        
        delegate.bookViewOrignCenter = delegate.currentBookView.center;
        
        
        CGFloat duringTime = DURING_TIME;
        
        if (!flag) {
            duringTime = 0.0f;
        }
        
        [UIView animateWithDuration:duringTime delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionShowHideTransitionViews animations:^{
            
            delegate.currentBookView.transform = CGAffineTransformMakeScale(scaleX,scaleY);
            delegate.currentBookView.center = deviceCenter;
            
            delegate.currentBookView.cover.layer.transform = transformblank;
            
            [delegate.currentBookView bringSubviewToFront:delegate.currentBookView.cover];
            
        } completion:^(BOOL finished) {
            if (finished) {
                
                delegate.currentBookView.cover.layer.hidden = YES;
                
                if (completion != nil) {
                    completion();
                }
            }
            
        } ];
    }
    else
    {
        
        NSAssert(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"), @" '- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion' need ios 5.0+ ");
        
        [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (delegate.modalTransitionStyle == UIModalTransitionStyleOpenBooks) {
        [self dismissViewControllerAnimated:animated completion:nil];
    }
    else
    {
        [super dismissModalViewControllerAnimated:animated];
    }
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
     AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (delegate.modalTransitionStyle == UIModalTransitionStyleOpenBooks) {
        
        NSAssert(delegate.currentBookView, @"_bookView can not be nil");
        
        delegate.currentBookView.cover.layer.hidden = NO;
        
        CGFloat duringTime = DURING_TIME;
        
        if (!flag) {
            duringTime = 0.0f;
        }
        
        [UIView animateWithDuration:duringTime delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionShowHideTransitionViews animations:^{
            
            delegate.currentBookView.center = delegate.bookViewOrignCenter;
            delegate.currentBookView.transform = CGAffineTransformIdentity;
            delegate.currentBookView.cover.layer.transform = CATransform3DIdentity;
            
        } completion:^(BOOL finished) {
            
            if (finished) {
                
                [delegate.currentBookView.content removeFromSuperview];
                
                if (completion != nil) {
                    
                    completion();
                }
            }
            
        } ];
    }
    else
    {
        
        NSAssert(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"), @" '-- (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion' need ios 5.0+ ");
        
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}
@end
