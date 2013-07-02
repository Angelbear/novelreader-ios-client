//
//  DataBase.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-28.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Section, Book, Bookmark;

@interface DataBase : NSObject
+ (void) initialize_database;
+ (NSMutableArray*) getAllBooks;
+ (NSMutableArray*) getAllSectionsOfBook:(Book*)book;
+ (NSMutableArray*) getDownloadedSectionsOfBook:(Book*)book;
+ (NSMutableArray*) getNotDownloadedSectionsOfBook:(Book*)book limit:(NSUInteger)limit;
+ (Book*) getBookByUrl:(NSString*)url;
+ (Section*) getSectionByUrl:(NSString*)url;
+ (NSUInteger) insertBook:(Book*) book;
+ (BOOL) deleteBook:(Book*) book;
+ (BOOL) updateBook:(Book*) book;
+ (NSUInteger) insertSection:(Section*) section;
+ (BOOL) deleteSection:(Section*) section;
+ (BOOL) updateSection:(Section*) section;
+ (NSUInteger) createDefaultBookMark:(Book*)book;
+ (Bookmark*) getDefaultBookmarkForBook:(Book*)book;
+ (BOOL) deleteBookMarkByBookId:(NSUInteger) book_id;
+ (BOOL) updateBookMark:(Bookmark*) bookmark;
@end
