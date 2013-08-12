//
//  ForceOrientationViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-12.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForceOrientationViewController : UIViewController {
    UIInterfaceOrientation _orientation;
}
- (id) initWithOrientation:(UIInterfaceOrientation)orientation;
@end
