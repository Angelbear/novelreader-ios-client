//
//  RemoteControlViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-11.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "RemoteControlViewController.h"
#import "AppDelegate.h"
@interface RemoteControlViewController ()

@end

@implementation RemoteControlViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(IBAction)didSwipeOnRemoteControlView:(UISwipeGestureRecognizer*) recognizer {
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
