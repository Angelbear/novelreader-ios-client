//
//  Common.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-25.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "URLUtils.h"

#define NOVEL_SERVER @"xiaoshuoyuedu.sinaapp.com"
#define NOVEL_SERVER_LOCAL @"localhost:8080"

#define SERVER_HOST NOVEL_SERVER


#define DATABASE_NAME @"data.db"

#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define isiPad ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )

#define CELL_HEIGHT 139.0f