//
//  RemoteControlViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-11.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "RemoteControlViewController.h"
#import "AppDelegate.h"
#import "SectionReaderTableViewController.h"
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
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    SectionReaderTableViewController* sectionReader = (SectionReaderTableViewController*)delegate.readerDeckController.centerController;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        [sectionReader moveToPrevPage];
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        [sectionReader moveToNextPage];
    }
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
