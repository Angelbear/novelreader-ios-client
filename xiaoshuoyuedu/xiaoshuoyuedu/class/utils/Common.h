//
//  Common.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-25.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "URLUtils.h"
#ifdef __APPLE__
    #include "TargetConditionals.h"
#endif

#define NOVEL_SERVER @"xiaoshuoyuedu.sinaapp.com"
#define NOVEL_SERVER_LOCAL @"localhost:8080"

#if !(TARGET_IPHONE_SIMULATOR)
    #define SERVER_HOST NOVEL_SERVER
#else
    #define SERVER_HOST NOVEL_SERVER
#endif

#define MAX_CONCURRENT_REQUEST_NUM 2

#define DATABASE_NAME @"data.db"

#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define isiPad ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )

#define isLandscape UIInterfaceOrientationIsLandscape(((AppDelegate*)[UIApplication sharedApplication].delegate).orientation)

#define CELL_HEIGHT 139.0f

#define DEFAULT_FONT_SIZE 20.0f

#define MIN_FONT_SIZE 16.0f
#define MAX_FONT_SIZE (isiPad ? 34.0f : 30.0f)

#define READER_DECK_ANIMATION_TIME 0.25f

#define ROTATION_ANIMATION_TIME 0.25f

#define MAKE_COLOR(r, g, b, a) [UIColor colorWithRed: (CGFloat)r / 256.0f green:(CGFloat)g /256.0f blue:(CGFloat)b /256.0f alpha:(CGFloat)a] 

#define THEME_COLOR_0 MAKE_COLOR(244,236,209, 1 )
#define THEME_COLOR_1 MAKE_COLOR(251,250,246, 1 )
#define THEME_COLOR_2 MAKE_COLOR(197,218,149, 1 )
#define THEME_COLOR_3 MAKE_COLOR(147,187,196, 1 )
#define THEME_COLOR_4 MAKE_COLOR(223,192,183, 1 )
#define THEME_COLOR_5 MAKE_COLOR( 84,115, 81, 1 )
#define THEME_COLOR_6 MAKE_COLOR(134,105, 68, 1 )

#define THEME_COLORS ( [NSArray arrayWithObjects:THEME_COLOR_0, THEME_COLOR_1, THEME_COLOR_2, THEME_COLOR_3, THEME_COLOR_4, THEME_COLOR_5, THEME_COLOR_6, nil] )

#define FONT_COLOR_0 MAKE_COLOR( 76, 54, 25, 1 )
#define FONT_COLOR_1 MAKE_COLOR( 50, 50, 50, 1 )
#define FONT_COLOR_2 MAKE_COLOR( 41, 80, 22, 1 )
#define FONT_COLOR_3 MAKE_COLOR( 36, 81,112, 1 )
#define FONT_COLOR_4 MAKE_COLOR(118, 63, 58, 1 )
#define FONT_COLOR_5 MAKE_COLOR(253,234,162, 1 )
#define FONT_COLOR_6 MAKE_COLOR(254,237,210, 1 )
#define FONT_COLORS ( [NSArray arrayWithObjects:FONT_COLOR_0, FONT_COLOR_1, FONT_COLOR_2, FONT_COLOR_3, FONT_COLOR_4, FONT_COLOR_5, FONT_COLOR_6, nil] )

#define isiOS7 ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 )
