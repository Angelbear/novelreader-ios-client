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
        
        self.fontButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.fontButton.frame = CGRectMake(self.frame.origin.x + deviceFrame.size.width - 40, self.frame.origin.y, 32.0f, 32.0f);
        [self.fontButton setImage:[UIImage imageNamed:@"AAglyp"] forState:UIControlStateNormal];
        [self.fontButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.fontButton addTarget:self action:@selector(tapOnFontSelectButton:) forControlEvents:UIControlEventTouchUpInside];
        self.fontButton.hidden = YES;
        
        self.refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.refreshButton.frame = CGRectMake(self.frame.origin.x + deviceFrame.size.width - 72, self.frame.origin.y, 32.0f, 32.0f);
        [self.refreshButton setImage:[UIImage imageNamed:@"sync_btn"] forState:UIControlStateNormal];
        [self.refreshButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.refreshButton addTarget:self action:@selector(tapOnRefreshButton:) forControlEvents:UIControlEventTouchUpInside];
        self.refreshButton.hidden = YES;
    
        self.infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        self.infoButton.backgroundColor = [UIColor clearColor];
        self.infoButton.frame = CGRectMake(self.frame.origin.x + deviceFrame.size.width - 104, self.frame.origin.y, 32.0f, 32.0f);
        [self.infoButton addTarget:self action:@selector(tapOnInfoButton:) forControlEvents:UIControlEventTouchUpInside];
        self.infoButton.hidden = YES;
        
        self.mirrorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.mirrorButton.frame = CGRectMake(self.frame.origin.x + 20.0f, self.frame.origin.y, 32.0f, 32.0f);
        [self.mirrorButton setImage:[UIImage imageNamed:@"airplay"] forState:UIControlStateNormal];
        [self.mirrorButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.mirrorButton addTarget:self action:@selector(tapOnAirMirrorButton:) forControlEvents:UIControlEventTouchUpInside];
        self.mirrorButton.hidden = YES;
        
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + 20.0f, deviceFrame.size.width, deviceFrame.size.height - 35.0f)];
        self.textView.editable = NO;
        self.textView.userInteractionEnabled = NO;
        self.textView.scrollEnabled = NO;
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.contentInset = UIEdgeInsetsZero;
        self.textView.textAlignment = NSTextAlignmentLeft;
        self.textView.userInteractionEnabled = NO;
        
        self.textLabelView = [[YLLabel alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + 32.0f, deviceFrame.size.width, deviceFrame.size.height - 47.0f)];
        self.textLabelView.userInteractionEnabled = NO;
        
        [self addSubview:self.textLabelView];
        [self addSubview:self.fontButton];
        [self addSubview:self.refreshButton];
        [self addSubview:self.mirrorButton];
        [self addSubview:self.infoButton];
        
        WindowSelectViewController* select = [[WindowSelectViewController alloc] initWithStyle:UITableViewStylePlain];
        self.popup = [[WEPopoverController alloc] initWithContentViewController:select];
        
        self.downloadPanel.hidden = YES;
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
        self.tapRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.tapRecognizer];
        
        [self bringSubviewToFront:self.downloadPanel];

        [self setRestorationIdentifier:reuseIdentifier];
        _menuMode = NO;
    }
    return self;
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

- (void) setNovelText:(NSString*)text {
    if (text == nil || [text length] == 0) {
        self.downloadPanel.hidden = NO;
        [self removeGestureRecognizer:self.tapRecognizer];
    } else {
        self.downloadPanel.hidden = YES;
        [self addGestureRecognizer:self.tapRecognizer];
    }
    [self.textLabelView setText:text];
    //self.textView.text = text;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dataComps = [gregorianCal components: (NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                  fromDate: [NSDate date]];
    
    self.timeView.text = [NSString stringWithFormat:@"%02d:%02d", [dataComps hour], [dataComps minute]];
}

- (IBAction)tapOnRefreshButton:(id)sender {
    [self.delegate clickRefreshButton:sender];
}

- (IBAction)tapOnDownloadLaterButton:(id)sender {
    [self.delegate clickDownloadLaterButton:sender];
}

- (void)tapOnFontSelectButton:(id)sender {
    [self.delegate clickFontMenuButton:sender];
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

- (void) toggleShowMenu:(id) sender {
    _menuMode = !_menuMode;
    if (_menuMode) {
        self.labelView.hidden = YES;
        self.fontButton.hidden = NO;
        self.refreshButton.hidden = NO;
        self.infoButton.hidden = NO;
        //self.mirrorButton.hidden = NO;
    } else {
        self.labelView.hidden = NO;
        self.fontButton.hidden = YES;
        self.refreshButton.hidden = YES;
        self.infoButton.hidden = YES;
        //self.mirrorButton.hidden = YES;
    }
}

@end
