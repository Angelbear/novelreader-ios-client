//
//  DataBase.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-28.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "DataBase.h"
#import "Common.h"
#import <FMDB/FMDatabase.h>
#import "Book.h"
#import "Section.h"
#import "Bookmark.h"

@implementation DataBase

+ (FMDatabase*) get_database_instance {
    NSArray*    paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString*   dir   = [paths objectAtIndex:0];
    FMDatabase* db    = [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:DATABASE_NAME]];
    return db;
}

+ (void) initialize_database {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString*   create_books_sql = @"CREATE TABLE IF NOT EXISTS books (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, author TEXT, cover BLOB, source TEXT, url TEXT UNIQUE, last_update_time INTEGER);";
    NSString*   create_sections_sql = @"CREATE TABLE IF NOT EXISTS sections (id INTEGER PRIMARY KEY AUTOINCREMENT, book_id INTEGER, name TEXT, text TEXT, source TEXT, url TEXT UNIQUE,  last_update_time INTEGER, FOREIGN KEY(book_id) REFERENCES books(id) ON DELETE CASCADE);";
    NSString*   create_bookmarks_sql = @"CREATE TABLE IF NOT EXISTS bookmarks (id INTEGER PRIMARY KEY AUTOINCREMENT, book_id INTEGER, section_id INTEGER, offset INTEGER, default_bookmark INTEGER, last_update_time INTEGER, FOREIGN KEY(book_id) REFERENCES books(id) ON DELETE CASCADE, FOREIGN KEY(section_id) REFERENCES sections(id) ON DELETE CASCADE)";
    [db open];
    [db executeUpdate:create_books_sql];
    [db executeUpdate:create_sections_sql];
    [db executeUpdate:create_bookmarks_sql];
    [db close];
}

+ (NSUInteger) createDefaultBookMark:(Book*)book {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* sql_insert_book = @"INSERT INTO bookmarks (book_id, section_id, offset, default_bookmark, last_update_time) VALUES (?,?,?,?,?)";
    [db open];
    NSError* error;
    NSMutableArray* sections = [DataBase getAllSectionsOfBook:book];
    if (sections !=nil  && [sections count] > 0) {
        Section* sec = [sections objectAtIndex:0];
        [db update:sql_insert_book withErrorAndBindings:&error,@(book.book_id), @(sec.section_id), [NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [self currentTimeStamp]];
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    NSUInteger result = db.lastInsertRowId;
    [db close];
    return result;
}

+ (Bookmark*) getDefaultBookmarkForBook:(Book*)book {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* sql_query_bookmark = @"SELECT * FROM bookmarks WHERE book_id = ? AND default_bookmark = 1";
    NSArray* args = [NSArray arrayWithObjects:@(book.book_id), nil];
    [db open];
    FMResultSet* resultSet = [db executeQuery:sql_query_bookmark withArgumentsInArray:args];
    if ( [resultSet next] )
    {
        Bookmark* bookmark  = [[Bookmark alloc] init];
        bookmark.bookmark_id = [resultSet intForColumn:@"id"];
        bookmark.book_id = [resultSet intForColumn:@"book_id"];
        bookmark.section_id = [resultSet intForColumn:@"section_id"];
        bookmark.offset = [resultSet intForColumn:@"offset"];
        bookmark.default_bookmark = 1;
        bookmark.last_update_time = [resultSet intForColumn:@"last_update_time"];
        [db close];
        return bookmark;
    }
    [db close];
    return nil;
}

+ (BOOL) updateBookMark:(Bookmark*) bookmark {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* sql_update_bookmark = @"UPDATE bookmarks SET section_id = ?, offset = ?, last_update_time = ? WHERE id = ? AND book_id = ? AND default_bookmark = ?";
    [db open];
    NSArray* args = [[NSArray alloc] initWithObjects:@(bookmark.section_id), @(bookmark.offset), [self currentTimeStamp], @(bookmark.bookmark_id), @(bookmark.book_id), @(bookmark.default_bookmark), nil];
    BOOL result =  [db executeUpdate:sql_update_bookmark withArgumentsInArray:args];
    [db close];
    return result;
}


+ (BOOL) deleteBookMarkByBookId:(NSUInteger) book_id {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* sql_delete_bookmarks = @"DELETE FROM bookmarks WHERE book_id = ?";
    [db open];
    NSArray* args = [[NSArray alloc] initWithObjects: @(book_id), nil];
    BOOL result =  [db executeUpdate:sql_delete_bookmarks withArgumentsInArray:args];
    [db close];
    return result;
}


+ (NSMutableArray*) getAllBooks {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* query_books_sql = @"SELECT * FROM books";
    [db open];
    FMResultSet* resultSet = [db executeQuery:query_books_sql];
    NSMutableArray* books   = [[NSMutableArray alloc] initWithCapacity:0];
    while( [resultSet next] )
    {
        Book* book  = [[Book alloc] init];
        book.book_id = [resultSet intForColumn:@"id"];
        book.name   = [resultSet stringForColumn:@"name"];
        book.author = [resultSet stringForColumn:@"author"];
        book.cover  = [[UIImage alloc] initWithData:[resultSet dataForColumn:@"cover"]];
        book.from   = [resultSet stringForColumn:@"source"];
        book.url    = [resultSet stringForColumn:@"url"];
        book.last_update_time = [resultSet intForColumn:@"last_update_time"];
        [books addObject:book];
    }
    [db close];
    return books;
}

+ (NSMutableArray*) getAllSectionsOfBook:(Book*)book {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* query_sections_sql = @"SELECT * FROM sections WHERE book_id = ?";
    NSArray* args = [[NSArray alloc] initWithObjects: @(book.book_id), nil];
    [db open];
    FMResultSet* resultSet = [db executeQuery:query_sections_sql withArgumentsInArray:args];
    NSMutableArray* sections   = [[NSMutableArray alloc] initWithCapacity:0];
    while( [resultSet next] )
    {
        Section* section  = [[Section alloc] init];
        section.section_id = [resultSet intForColumn:@"id"];
        section.book_id = [resultSet intForColumn:@"book_id"];
        section.name   = [resultSet stringForColumn:@"name"];
        section.text   = [resultSet stringForColumn:@"text"];
        section.from   = [resultSet stringForColumn:@"source"];
        section.url    = [resultSet stringForColumn:@"url"];
        section.last_update_time = [resultSet intForColumn:@"last_update_time"];
        [sections addObject:section];
    }
    [db close];
    return sections;
}

+ (NSMutableArray*) getDownloadedSectionsOfBook:(Book*)book {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* query_sections_sql = @"SELECT * FROM sections WHERE book_id = ? AND (text NOT NULL AND text <> '')";
    NSArray* args = [[NSArray alloc] initWithObjects: @(book.book_id), nil];
    [db open];
    FMResultSet* resultSet = [db executeQuery:query_sections_sql withArgumentsInArray:args];
    NSMutableArray* sections   = [[NSMutableArray alloc] initWithCapacity:0];
    while( [resultSet next] )
    {
        Section* section  = [[Section alloc] init];
        section.section_id = [resultSet intForColumn:@"id"];
        section.book_id = [resultSet intForColumn:@"book_id"];
        section.name   = [resultSet stringForColumn:@"name"];
        section.text   = [resultSet stringForColumn:@"text"];
        section.from   = [resultSet stringForColumn:@"source"];
        section.url    = [resultSet stringForColumn:@"url"];
        section.last_update_time = [resultSet intForColumn:@"last_update_time"];
        [sections addObject:section];
    }
    [db close];
    return sections;
}

+ (NSMutableArray*) getNotDownloadedSectionsOfBook:(Book*)book limit:(NSUInteger)limit {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* query_sections_sql = @"SELECT * FROM sections WHERE book_id = ? AND (text IS NULL OR text = '') LIMIT ?";
    NSArray* args = [[NSArray alloc] initWithObjects: @(book.book_id), @(limit), nil];
    [db open];
    FMResultSet* resultSet = [db executeQuery:query_sections_sql withArgumentsInArray:args];
    NSMutableArray* sections   = [[NSMutableArray alloc] initWithCapacity:0];
    while( [resultSet next] )
    {
        Section* section  = [[Section alloc] init];
        section.section_id = [resultSet intForColumn:@"id"];
        section.book_id = [resultSet intForColumn:@"book_id"];
        section.name   = [resultSet stringForColumn:@"name"];
        section.text   = [resultSet stringForColumn:@"text"];
        section.from   = [resultSet stringForColumn:@"source"];
        section.url    = [resultSet stringForColumn:@"url"];
        section.last_update_time = [resultSet intForColumn:@"last_update_time"];
        [sections addObject:section];
    }
    [db close];
    return sections;
}

+ (Book*) getBookByUrl:(NSString*)url {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* query_sections_sql = @"SELECT * FROM books WHERE url = ?";
    NSArray* args = [[NSArray alloc] initWithObjects: url, nil];
    [db open];
    FMResultSet* resultSet = [db executeQuery:query_sections_sql withArgumentsInArray:args];
    if( [resultSet next] )
    {
        Book* book  = [[Book alloc] init];
        book.book_id = [resultSet intForColumn:@"id"];
        book.author = [resultSet stringForColumn:@"author"];
        book.name   = [resultSet stringForColumn:@"name"];
        book.from   = [resultSet stringForColumn:@"source"];
        book.url    = [resultSet stringForColumn:@"url"];
        book.last_update_time = [resultSet intForColumn:@"last_update_time"];
        [db close];
        return book;
    }
    [db close];
    return nil;
}

+ (Section*) getSectionByUrl:(NSString*)url {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* query_sections_sql = @"SELECT * FROM sections WHERE url = ?";
    NSArray* args = [[NSArray alloc] initWithObjects: url, nil];
    [db open];
    FMResultSet* resultSet = [db executeQuery:query_sections_sql withArgumentsInArray:args];
    if( [resultSet next] )
    {
        Section* section  = [[Section alloc] init];
        section.section_id = [resultSet intForColumn:@"id"];
        section.book_id = [resultSet intForColumn:@"book_id"];
        section.name   = [resultSet stringForColumn:@"name"];
        section.from   = [resultSet stringForColumn:@"source"];
        section.url    = [resultSet stringForColumn:@"url"];
        section.last_update_time = [resultSet intForColumn:@"last_update_time"];
        [db close];
        return section;
    }
    [db close];
    return nil;
}

+ (NSNumber*) currentTimeStamp {
    NSUInteger epoch = (NSUInteger)[[NSDate date] timeIntervalSince1970];
    return [NSNumber numberWithLong:epoch];
}

+ (NSUInteger) insertBook:(Book*) book {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* sql_insert_book = @"INSERT INTO books (name, author, cover, source, url, last_update_time) VALUES (?,?,?,?,?,?)";
    [db open];
    NSError* error;
    [db update:sql_insert_book withErrorAndBindings:&error,book.name, book.author, [[NSData alloc] initWithData:UIImagePNGRepresentation(book.cover)], book.from, book.url, [self currentTimeStamp]];
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    }
    NSUInteger result = db.lastInsertRowId;
    [db close];
    return result;
}

+ (BOOL) deleteBook:(Book*) book {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* sql_delete_book = @"DELETE FROM books WHERE id = ?";
    [db open];
    NSArray* args = [[NSArray alloc] initWithObjects: @(book.book_id), nil];
    BOOL result =  [db executeUpdate:sql_delete_book withArgumentsInArray:args];
    [db close];
    result = [self deleteSectionByBookId:book.book_id];
    result = [self deleteBookMarkByBookId:book.book_id];
    return result;
}

+ (BOOL) updateBook:(Book*) book {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* sql_update_book = @"UPDATE books SET name = ?, author = ?, cover = ?, source = ?, url = ? last_update_time = ? WHERE id = ?";
    [db open];
    NSArray* args = [[NSArray alloc] initWithObjects:book.name, book.author, [[NSData alloc] initWithData:UIImagePNGRepresentation(book.cover)], book.from, book.url, [self currentTimeStamp], @(book.book_id), nil];
    BOOL result =  [db executeUpdate:sql_update_book withArgumentsInArray:args];
    [db close];
    return result;
}

+ (NSUInteger) insertSection:(Section*) section {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* sql_insert_sections = @"INSERT INTO sections (book_id, name, text, source, url, last_update_time) VALUES (?,?,?,?,?,?)";
    [db open];
    NSArray* args = [[NSArray alloc] initWithObjects:@(section.book_id), section.name, section.text, section.from, section.url,  [self currentTimeStamp], nil];
    [db executeUpdate:sql_insert_sections withArgumentsInArray:args];
    NSUInteger result = db.lastInsertRowId;
    [db close];
    return result;
}

+ (BOOL) deleteSection:(Section*) section {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* sql_delete_section = @"DELETE FROM sections WHERE id = ?";
    [db open];
    NSArray* args = [[NSArray alloc] initWithObjects: @(section.section_id), nil];
    BOOL result =  [db executeUpdate:sql_delete_section withArgumentsInArray:args];
    [db close];
    return result;
}

+ (BOOL) deleteSectionByBookId:(NSUInteger) bookId {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* sql_delete_section = @"DELETE FROM sections WHERE book_id = ?";
    [db open];
    NSArray* args = [[NSArray alloc] initWithObjects: @(bookId), nil];
    BOOL result =  [db executeUpdate:sql_delete_section withArgumentsInArray:args];
    [db close];
    return result;
}

+ (BOOL) updateSection:(Section*) section {
    FMDatabase* db    = [DataBase get_database_instance];
    NSString* sql_update_section = @"UPDATE sections SET text = ?, source = ?, url = ?, last_update_time = ? WHERE id = ?";
    [db open];
    NSError* error;
    BOOL result = [db update:sql_update_section withErrorAndBindings:&error, section.text, section.from, section.url, [self currentTimeStamp], @(section.section_id)];
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [db close];
    return result;
}


@end
