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
#import "Common.h"
#import "GVUserDefaults+Properties.h"
@implementation SectionPageViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CGRect deviceFrame = (delegate.orientation == UIInterfaceOrientationPortrait) ? [UIScreen mainScreen].bounds : CGRectRotate([UIScreen mainScreen].bounds);
    if (isiOS7) {
        deviceFrame = CGRectMake(0, 0.0f, deviceFrame.size.width, deviceFrame.size.height - 20.0f);
    }
    self.view.frame = deviceFrame;
    self.contentView.frame = deviceFrame;
    self.contentView.dropDownMenuToolbar.frame = CGRectMake(0, deviceFrame.origin.y - 44.0f, deviceFrame.size.width, 44.0f);
    self.contentView.textLabelView.frame = CGRectMake(0, deviceFrame.origin.y + 20.0f, deviceFrame.size.width, deviceFrame.size.height - 35.0f);
    self.contentView.blackView.frame = CGRectMake(0, deviceFrame.origin.y, deviceFrame.size.width * 2.0f, deviceFrame.size.height * 2.0f);
    self.contentView.labelView.frame = CGRectMake(deviceFrame.size.width/2 - self.contentView.labelView.frame.size.width/2, deviceFrame.origin.y, self.contentView.labelView.frame.size.width, self.contentView.labelView.frame.size.height);
    self.contentView.timeView.frame = CGRectMake(10, deviceFrame.origin.y + deviceFrame.size.height - self.contentView.timeView.frame.size.height, self.contentView.timeView.frame.size.width, self.contentView.timeView.frame.size.height);
    self.contentView.indexView.frame = CGRectSetXY(deviceFrame.size.width - self.contentView.indexView.frame.size.width - 10, deviceFrame.origin.y + deviceFrame.size.height - self.contentView.indexView.frame.size.height, self.contentView.timeView.frame);
    self.contentView.downloadPanel.frame = CGRectSetXY(deviceFrame.size.width/2.0f - self.contentView.downloadPanel.frame.size.width/2.0f, deviceFrame.origin.y + deviceFrame.size.height/2.0f - self.contentView.downloadPanel.frame.size.height/2.0f, self.contentView.downloadPanel.frame);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end

@implementation SectionPageView

- (id)init {
    SectionPageViewController* controller = [[SectionPageViewController alloc] initWithNibName: isiPad ? @"SectionPageView~iPad" : @"SectionPageView~iPhone" bundle:nil];
    self = (SectionPageView*)controller.view;
    if (self) {
        CGRect deviceFrame = [UIScreen mainScreen].bounds;
        if (isiOS7) {
            deviceFrame = CGRectSetY(20.0f, CGRectSetHeight(CGRectGetHeight(deviceFrame) - 20.0f, deviceFrame));
        }

        self.textLabelView.userInteractionEnabled = NO;
 
        self.dropDownMenuToolbar.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - 44.0f, deviceFrame.size.width, 44.0f);
        self.dropDownMenuToolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.dropDownMenuToolbar.hidden = YES;
        if (isiOS7) {
            self.dropDownMenuToolbar.barStyle = UIBarStyleDefault;
        }
        
        self.downloadPanel.hidden = YES;
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
        self.tapRecognizer.cancelsTouchesInView = NO;
        self.tapRecognizer.delegate = self;
        
        GVUserDefaults* ud = [GVUserDefaults standardUserDefaults];
        if (ud.orientationLocked) {
            [self.deviceOrientationItem setImage:[UIImage imageNamed:@"lock"]];
        } else {
            [self.deviceOrientationItem setImage:[UIImage imageNamed:@"rotation"]];
        }

        self.blackView.alpha = (0.5 - 0.5f*ud.brightness);
        
        [self addGestureRecognizer:self.tapRecognizer];
        [self bringSubviewToFront:self.blackView];
        [self addSubview:self.dropDownMenuToolbar];
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

- (void) setBeginParagraph:(BOOL)beginParagraph {
    [self. textLabelView setBeginParagraph:beginParagraph];
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
    UIBarButtonItem* item = (UIBarButtonItem*)sender;
    GVUserDefaults* ud = [GVUserDefaults standardUserDefaults];
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (ud.orientationLocked) {
        ud.orientationLocked = NO;
        [item setImage:[UIImage imageNamed:@"rotation"]];
    } else {
        ud.orientationLocked = YES;
        ud.fixedOrientation = delegate.orientation;
        [item setImage:[UIImage imageNamed:@"lock"]];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)tapOnInfoButton:(id)sender {
    [self.delegate clickInfoButton:sender];
}

- (void)tapOnAirMirrorButton:(id)sender {

}

- (void) setMenuState:(BOOL)state {
    _menuMode = state;
}

- (void) showMenu:(BOOL)state {
    _menuMode = state;
    CGFloat Width =  self.frame.size.width;
    if (_menuMode) {
        self.dropDownMenuToolbar.frame = CGRectMake(0, 20.0f, Width, 44.0f);
        self.dropDownMenuToolbar.hidden = NO;
    } else {
        self.dropDownMenuToolbar.frame = CGRectMake(0, - 44.0f, Width, 44.0f);
        self.dropDownMenuToolbar.hidden = YES;
    }
}

- (void) toggleShowMenu:(id)sender {
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
