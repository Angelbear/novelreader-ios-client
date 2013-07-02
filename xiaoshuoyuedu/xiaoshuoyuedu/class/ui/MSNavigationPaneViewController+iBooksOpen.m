//
//  MSNavigationPaneViewController+iBooksOpen.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-1.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "MSNavigationPaneViewController+iBooksOpen.h"
#import "AppDelegate.h"


@implementation MSNavigationPaneViewController (iBooksOpen)

#define ANIMATION_DURATION 1.0f

#define FLIP_GAP 60.0f

#pragma mark -
#pragma mark Animation Methods

- (CATransform3D)transformWithDegrees:(CGFloat)degrees{
	
	if (degrees == 0) {
		return CATransform3DIdentity;
	}
	
	return CATransform3DMakeRotation((M_PI/180)*degrees, 0.0f, 1.0f, 0.0);
	
}

- (UIImage*)contentsForView:(UIView*)aView{
	
	UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, [[UIScreen mainScreen] scale]);
	[aView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
	
	if (flag) {
		[[anim valueForKey:@"ContentsLayer"] removeFromSuperlayer];
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	}
	
}

- (void)animateFromViewController:(UIViewController*)fromController toViewController:(UIViewController*)toController{
	
	UIImage *image = [self contentsForView:toController.view];
	
	CALayer *contentsLayer = [CALayer layer];
	contentsLayer.frame = toController.view.bounds;
	contentsLayer.backgroundColor = [UIColor blackColor].CGColor;
	[toController.view.layer addSublayer:contentsLayer];
	
	CATransformLayer *transformLayer = [CATransformLayer layer];
	transformLayer.frame = contentsLayer.bounds;
	[contentsLayer addSublayer:transformLayer];
	
	CALayer *backLayer = [CALayer layer];
	backLayer.contents = (id)image.CGImage;
	backLayer.doubleSided = NO;
	backLayer.frame = transformLayer.bounds;
	backLayer.zPosition = 0.0f;
	backLayer.transform = [self transformWithDegrees:180.0f];
	[transformLayer addSublayer:backLayer];
	
	CALayer *frontLayer = [CALayer layer];
	frontLayer.contents = (id)[self contentsForView:fromController.view].CGImage;
	frontLayer.doubleSided = NO;
	frontLayer.zPosition = FLIP_GAP;
	frontLayer.frame = transformLayer.bounds;
	frontLayer.masksToBounds = NO;
	[transformLayer addSublayer:frontLayer];
	
	CALayer *sideLayer = [CALayer layer];
	sideLayer.contents = (id)[UIImage imageNamed:@"Wood Tile"].CGImage;
	sideLayer.zPosition = FLIP_GAP/2;
	sideLayer.frame = CGRectMake(transformLayer.bounds.origin.x-(FLIP_GAP/2), transformLayer.bounds.origin.y, FLIP_GAP, transformLayer.bounds.size.height);
	sideLayer.transform = [self transformWithDegrees:90.0f];
	[transformLayer addSublayer:sideLayer];
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform"];
	animation.toValue = [NSValue valueWithCATransform3D:[self transformWithDegrees:179.9f]];
	animation.duration = ANIMATION_DURATION;
	animation.fillMode = kCAFillModeForwards;
	animation.removedOnCompletion = NO;
	animation.delegate = self;
	[animation setValue:contentsLayer forKey:@"ContentsLayer"];
	[transformLayer addAnimation:animation forKey:@"FlipAnimation"];
    
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	
}


#pragma mark -
#pragma mark Modal Prentation Methods

- (void)dismissModalViewControllerAnimated:(BOOL)animated{
	
	UIViewController *modalViewController = self.modalViewController;
	[self animateFromViewController:modalViewController toViewController:self];
	[super dismissModalViewControllerAnimated:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
	
}

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated{
	
	[super presentModalViewController:modalViewController animated:NO];
	[self animateFromViewController:self toViewController:modalViewController];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
}


#pragma mark -
#pragma mark FlipSideDelegate

- (void)dismissFlipSideViewController:(id)controller{
	
	[self dismissModalViewControllerAnimated:YES];
	
}

@end
