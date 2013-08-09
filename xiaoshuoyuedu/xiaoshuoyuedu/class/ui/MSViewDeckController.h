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

@interface MSViewDeckController : IIViewDeckController
@property (nonatomic, strong) MSReaderViewController *readerMasterViewController;
@property (nonatomic, strong) IISideController *constrainedRightController;
@property (nonatomic, strong) ReaderPagingViewController* readerViewController;
@end
