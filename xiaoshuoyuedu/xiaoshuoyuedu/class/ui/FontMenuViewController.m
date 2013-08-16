//
//  FontMenuViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-7-3.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "FontMenuViewController.h"
#import "Common.h"
#import <QuartzCore/QuartzCore.h>
#import "ReaderCacheManager.h"
@interface FontMenuViewController ()
@property (nonatomic, strong) NSArray* fonts;
@end

@implementation FontMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.userDefaults = [GVUserDefaults standardUserDefaults];
        self.fonts = [NSArray arrayWithObjects:[UIFont systemFontOfSize:DEFAULT_FONT_SIZE], [UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE], [UIFont fontWithName:@"FZLTHJW--GB1-0" size:DEFAULT_FONT_SIZE], nil];
        _selectedIndex = 0;
        for( UIFont* font in self.fonts) {
            if ([font.fontName compare:self.userDefaults.fontName] == NSOrderedSame) {
                _selectedIndex = [self.fonts indexOfObject:font];
                break;
            }
        }
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
    self.fontSelectView.backgroundView = nil;
    self.orientationButton.selectedSegmentIndex = self.userDefaults.textOrientation;
    self.fontSelectView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"font_selection_background"]];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
    UIScreen *mainScreen = [UIScreen mainScreen];
    mainScreen.brightness = self.brightSlider.value;
}

- (IBAction) increaseFontSize:(id)sender {
    if (self.userDefaults.fontSize < MAX_FONT_SIZE) {
        self.userDefaults.fontSize += 0.5f;
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[ReaderCacheManager init_instance] clearAllSplitInfos];
        [self.delegate increaseFontSize];
    }
    
}
- (IBAction) decreaseFontSize:(id)sender {
    if (self.userDefaults.fontSize > MIN_FONT_SIZE) {
        self.userDefaults.fontSize -= 0.5f;
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[ReaderCacheManager init_instance] clearAllSplitInfos];
        [self.delegate decreaseFontSize];
    }
}

- (IBAction) clickFontSelect:(id)sender {
    [UIView transitionWithView:self.view
                      duration:1.25
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^
    {
        
        [self.view  addSubview:self.fontSelectView];
        [self.view bringSubviewToFront:self.fontSelectView];
    }
                    completion:NULL];
}


- (IBAction) clickThemeSelect:(id)sender {
    [UIView transitionWithView:self.view
                      duration:1.25
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^
     {
         [self.view  addSubview:self.themeSelectView];
         [self.view bringSubviewToFront:self.themeSelectView];
         
     }
                    completion:nil];
}

- (IBAction)clickThemeButton:(id)sender {
    UIButton* imageButton = (UIButton*) sender;
    self.userDefaults.themeIndex = imageButton.tag;
    [[NSUserDefaults standardUserDefaults] synchronize];
    [UIView transitionWithView:self.view
                      duration:1.25
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:^
     {
         
         [self.themeSelectView removeFromSuperview];
         
     }
                    completion:^(BOOL finished)
     {
         [self.delegate changeTheme:self.userDefaults.themeIndex];
     }];
}

- (IBAction)selectTextOrientation:(id*)sender {
    [self.delegate changeTextOrientation:self.orientationButton.selectedSegmentIndex];
}


- (void) backToFontMenu {
    [UIView transitionWithView:self.view
                      duration:1.25
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:^
     {
         
         [self.fontSelectView removeFromSuperview];
         
     }
                    completion:NULL];
}


#pragma UITableViewSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"字体选择";
}   

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fonts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.origin.x + 2, cell.frame.origin.y + 2, self.view.frame.size.width - 24,  cell.frame.size.height - 4)];
        UIFont* font = [self.fonts objectAtIndex:indexPath.row];
        label.font = font;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"小说阅读";
        [cell.contentView addSubview:label];
    }
    
    if (_selectedIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont* font = [self.fonts objectAtIndex:indexPath.row];
    if ([font.fontName compare:self.userDefaults.fontName] != NSOrderedSame) {
        [[ReaderCacheManager init_instance] clearAllSplitInfos];
        [self.delegate changeFont:font.fontName];
        _selectedIndex = indexPath.row;
        [tableView reloadData];
    }
    [self backToFontMenu];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
