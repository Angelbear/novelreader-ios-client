//
//  MSMainPaneViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-12.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "MSNavigationPaneViewController.h"
#import "GVUserDefaults+Properties.h"
@interface MSMainPaneViewController : MSNavigationPaneViewController
@property (nonatomic, strong) GVUserDefaults* userDefaults;
@end
