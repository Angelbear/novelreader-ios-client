//
//  DataBase.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-28.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Section, Book;

@interface DataBase : NSObject
+ (void) initialize_database;
+ (NSMutableArray*) getAllBooks;
+ (NSMutableArray*) getAllSectionsOfBook:(Book*)book;
+ (BOOL) insertBook:(Book*) book;
+ (BOOL) deleteBook:(Book*) book;
+ (BOOL) updateBook:(Book*) book;
+ (BOOL) insertSection:(Section*) section;
+ (BOOL) deleteSection:(Section*) section;
+ (BOOL) updateSection:(Section*) section;
@end
