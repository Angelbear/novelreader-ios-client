//
//  SectionPageView.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-8-7.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "SectionPageView.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import <WEPopover/WEPopoverTableViewController.h>
#import <CoreText/CoreText.h>
#import "WindowSelectViewController.h"
#import "Common.h"
@implementation SectionPageViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    CGRect deviceFrame = [UIScreen mainScreen].bounds;
    self.contentView.frame = deviceFrame;
    self.contentView.dropDownMenuToolbar.frame = CGRectMake(0,  - 44.0f, deviceFrame.size.width, 44.0f);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end

@implementation SectionPageView

- (id)init {
    SectionPageViewController* controller = [[SectionPageViewController alloc] initWithNibName:@"SectionPageView" bundle:nil];
    self = (SectionPageView*)controller.view;
    if (self) {
        
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        CGRect deviceFrame = delegate.currentWindow.screen.bounds;

        CGFloat Width = isLandscape ? deviceFrame.size.height : deviceFrame.size.width;
        CGFloat Height = isLandscape ? deviceFrame.size.width : deviceFrame.size.height;
        
        self.textLabelView = [[YLLabel alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + 20.0f, Width, Height - 35.0f)];
        self.textLabelView.userInteractionEnabled = NO;
        
        [self addSubview:self.textLabelView];
        
        self.dropDownMenuToolbar.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - 44.0f, Width, 44.0f);
        self.dropDownMenuToolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.dropDownMenuToolbar.hidden = YES;
        [self addSubview:self.dropDownMenuToolbar];
        
        WindowSelectViewController* select = [[WindowSelectViewController alloc] initWithStyle:UITableViewStylePlain];
        self.popup = [[WEPopoverController alloc] initWithContentViewController:select];
        
        self.downloadPanel.hidden = YES;
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
        self.tapRecognizer.cancelsTouchesInView = NO;
        self.tapRecognizer.delegate = self;
        [self addGestureRecognizer:self.tapRecognizer];
        
        [self bringSubviewToFront:self.downloadPanel];
        _menuMode = NO;
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[UIBarButtonItem class]] ) {
        return NO;
    }
    return YES;
}


-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer {
    CGPoint touchLocation = [recognizer locationInView:self.textLabelView];
    if (   touchLocation.x > self.frame.size.width / 3.0f
        && touchLocation.x < self.frame.size.width * 2.0f / 3.0f
        && touchLocation.y > self.frame.size.height / 4.0f
        && touchLocation.y < self.frame.size.height * 3.0f / 4.0f ) {
        [self toggleShowMenu:recognizer];
        return;
    }
    
    if (!_menuMode) {
        if (   touchLocation.x > self.frame.size.width * 2.0f / 3.0f
            && touchLocation.y > self.frame.size.height * 3.0f / 4.0f ) {
            [self.delegate moveToNextPage];
            return;
        }
        if (   touchLocation.x < self.frame.size.width  / 3.0f
            && touchLocation.y < self.frame.size.height / 4.0f ) {
            [self.delegate moveToPrevPage];
            return;
        }
    }
    
}

- (void) setNovelText:(NSString*)text {
    if (text == nil || [text length] == 0) {
        self.downloadPanel.hidden = NO;
    } else {
        self.downloadPanel.hidden = YES;
    }
    [self.textLabelView setText:text];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dataComps = [gregorianCal components: (NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                  fromDate: [NSDate date]];
    
    self.timeView.text = [NSString stringWithFormat:@"%02d:%02d", [dataComps hour], [dataComps minute]];
    
    [self showMenu:_menuMode];
}

- (IBAction)tapOnRefreshButton:(id)sender {
    [self.delegate clickRefreshButton:sender];
}

- (IBAction)tapOnDownloadLaterButton:(id)sender {
    [self.delegate clickDownloadLaterButton:sender];
}

- (IBAction)tapOnFontSelectButton:(id)sender {
    [self.delegate clickFontMenuButton:sender];
}


- (IBAction)tapOnNextButton:(id)sender {
    [self.delegate moveToNextSection];
}

- (IBAction)tapOnPrevButton:(id)sender {
    [self.delegate moveToPrevSection];
}

- (IBAction)changeOrientation:(id)sender {
    // check current orientation
    CGRect deviceframe = [UIScreen mainScreen].bounds;
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) {
        // no, the orientation is wrong, we must rotate the UI
        self.userInteractionEnabled = NO;
        [UIView beginAnimations:@"orientation" context:NULL];
        [UIView setAnimationDelegate:self];
        // setup status bar
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait  animated:NO];
        // rotate main view, in this sample the view of navigation controller is the root view in main window
        [self setTransform: CGAffineTransformMakeRotation(M_PI / 2)];
        // set size of view
        [self setFrame:CGRectMake(0, 0, deviceframe.size.width, deviceframe.size.height)];
        [UIView commitAnimations];
    } else if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait)  {
        // no, the orientation is wrong, we must rotate the UI
        self.userInteractionEnabled = NO;
        [UIView beginAnimations:@"orientation" context:NULL];
        [UIView setAnimationDelegate:self];
        // setup status bar
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft  animated:NO];
        // rotate main view, in this sample the view of navigation controller is the root view in main window
        [self setTransform: CGAffineTransformMakeRotation(M_PI / 2)];
        // set size of view
        [self setFrame:CGRectMake(0, 0, deviceframe.size.height, deviceframe.size.width)];
        [UIView commitAnimations];
    }
    
}

- (void)tapOnInfoButton:(id)sender {
    [self.delegate clickInfoButton:sender];
}

- (void)tapOnAirMirrorButton:(id)sender {
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.popup.popoverContentSize = CGSizeMake(200, [delegate.windows count] * 44.0f);
    UIView* view = (UIView*)sender;
    [self.popup presentPopoverFromRect:view.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) setMenuState:(BOOL)state {
    _menuMode = state;
}

- (void) showMenu:(BOOL)state {
    _menuMode = state;
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CGFloat Width =  self.frame.size.width;
    if (_menuMode) {
        if (delegate.isReading) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
        self.dropDownMenuToolbar.frame = CGRectMake(0, 20.0f, Width, 44.0f);
        self.dropDownMenuToolbar.hidden = NO;
    } else {
        if (delegate.isReading) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
        self.dropDownMenuToolbar.frame = CGRectMake(0, - 44.0f, Width, 44.0f);
        self.dropDownMenuToolbar.hidden = YES;
    }
}

- (void) toggleShowMenu:(id) sender {
    _menuMode = !_menuMode;
    [self.delegate toggleMenuState:_menuMode];
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CGFloat Width = self.frame.size.width;
    if (_menuMode) {
        self.dropDownMenuToolbar.frame = CGRectMake(0,  - 44.0f, Width, 44.0f);
        self.dropDownMenuToolbar.hidden = NO;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             if (delegate.isReading) {
                                 [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                             }
                             self.dropDownMenuToolbar.frame = CGRectMake(0, 20.0f, Width, 44.0f);
                         } completion:^(BOOL finished) {
                             
                         }];
    } else {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             if (delegate.isReading) {
                                 [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                             }
                             self.dropDownMenuToolbar.frame = CGRectMake(0, - 44.0f, Width, 44.0f);
                         } completion:^(BOOL finished) {
                             self.dropDownMenuToolbar.hidden = YES;
                         }];
    }
}

@end
