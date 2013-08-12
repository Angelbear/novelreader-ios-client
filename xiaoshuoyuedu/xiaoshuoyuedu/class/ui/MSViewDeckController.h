//
//  MSViewDeckController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-9.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "IIViewDeckController.h"
#import "MSReaderViewController.h"
#import "IISideController.h"
#import "GVUserDefaults+Properties.h"
@interface MSViewDeckController : IIViewDeckController
@property (nonatomic, strong) MSReaderViewController *readerMasterViewController;
@property (nonatomic, strong) IISideController *constrainedRightController;
@property (nonatomic, strong) ReaderPagingViewController* readerViewController;
@property (nonatomic, strong) GVUserDefaults* userDefaults;
- (void) forceOrientation:(UIInterfaceOrientation)orientation;
@end
