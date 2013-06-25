//
//  Common.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-25.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//
#define DEBUG 1

#define NOVEL_SERVER @"xiaoshuoyuedu.sinaapp.com"
#define NOVEL_SERVER_LOCAL @"localhost:8080"

#ifdef DEBUG
#define SERVER_HOST NOVEL_SERVER_LOCAL
#else
#define SERVER_HOST NOVEL_SERVER
#endif

