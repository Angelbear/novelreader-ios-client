//
//  FontMenuViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-3.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "FontMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface FontMenuViewController ()

@end

@implementation FontMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) setupButton:(UIButton*) button {
    UIColor* brown = [UIColor colorWithRed:194.0/256.0 green:180.0/256.0 blue:175.0/256.0 alpha:1.0f];
    UIColor* lightBrown = [UIColor colorWithRed:244.0/256.0 green:243.0/256.0 blue:232.0/256.0 alpha:1.0f];
    [button setBackgroundColor:lightBrown];
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:5.0];
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[brown CGColor]];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupButton:self.incButton];
    [self setupButton:self.decButton];
    [self setupButton:self.brightButton];
    [self setupButton:self.fontButton];
    [self setupButton:self.themeButton];
    self.brightSlider.value = [UIScreen mainScreen].brightness;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"font_selection_background"]];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
    UIScreen *mainScreen = [UIScreen mainScreen];
    mainScreen.brightness = self.brightSlider.value;
}

- (IBAction)increaseFontSize:(id)sender {
    [self.delegate increaseFontSize];
}
- (IBAction) decreaseFontSize:(id)sender {
    [self.delegate decreaseFontSize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
