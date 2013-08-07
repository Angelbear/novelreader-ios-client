//
//  SectionReaderTableViewCell.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "SectionReaderTableViewCell.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import <WEPopover/WEPopoverTableViewController.h>
#import <CoreText/CoreText.h>
#import "WindowSelectViewController.h"
@implementation SectionReaderTableViewCellViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    CGRect deviceFrame = [UIScreen mainScreen].bounds;
    self.cellView.frame = deviceFrame;
    self.cellView.content.frame = deviceFrame;
    self.cellView.dropDownMenuToolbar.frame = CGRectMake(0,  - 44.0f, deviceFrame.size.width, 44.0f);
}

@end

@implementation SectionReaderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier fontSize:(CGFloat)size {
    SectionReaderTableViewCellViewController* controller = [[SectionReaderTableViewCellViewController alloc] initWithNibName:@"SectionReaderTableViewCell" bundle:nil];
    
    self = (SectionReaderTableViewCell*)controller.view;
    if (self) {
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        CGRect deviceFrame = delegate.currentWindow.screen.bounds;
        
        self.contentView.frame = deviceFrame;

        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + 20.0f, deviceFrame.size.width, deviceFrame.size.height - 35.0f)];
        self.textView.editable = NO;
        self.textView.userInteractionEnabled = NO;
        self.textView.scrollEnabled = NO;
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.contentInset = UIEdgeInsetsZero;
        self.textView.textAlignment = NSTextAlignmentLeft;
        self.textView.userInteractionEnabled = NO;
        
        self.textLabelView = [[YLLabel alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + 20.0f, deviceFrame.size.width, deviceFrame.size.height - 35.0f)];
        self.textLabelView.userInteractionEnabled = NO;
        
        [self addSubview:self.textLabelView];    
        
        self.dropDownMenuToolbar.frame = CGRectMake(deviceFrame.origin.x, deviceFrame.origin.y - 44.0f, deviceFrame.size.width, 44.0f);
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

        [self setRestorationIdentifier:reuseIdentifier];
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
    CGRect deviceFrame = delegate.currentWindow.screen.bounds;
    if (_menuMode) {
        self.dropDownMenuToolbar.frame = CGRectMake(0, 0, deviceFrame.size.width, 44.0f);
        self.dropDownMenuToolbar.hidden = NO;
    } else {
        self.dropDownMenuToolbar.hidden = YES;
        self.dropDownMenuToolbar.frame = CGRectMake(0, - 44.0f, deviceFrame.size.width, 44.0f);
    }
}

- (void) toggleShowMenu:(id) sender {
    _menuMode = !_menuMode;
    [self.delegate toggleMenuState:_menuMode];
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CGRect deviceFrame = delegate.currentWindow.screen.bounds;
    if (_menuMode) {
        self.dropDownMenuToolbar.frame = CGRectMake(0, - 44.0f, deviceFrame.size.width, 44.0f);
        self.dropDownMenuToolbar.hidden = NO;
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
            self.dropDownMenuToolbar.frame = CGRectMake(0, 0, deviceFrame.size.width, 44.0f);
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.dropDownMenuToolbar.frame = CGRectMake(0, - 44.0f, deviceFrame.size.width, 44.0f);
        } completion:^(BOOL finished) {
            self.dropDownMenuToolbar.hidden = YES;
        }];
    }
}

@end
