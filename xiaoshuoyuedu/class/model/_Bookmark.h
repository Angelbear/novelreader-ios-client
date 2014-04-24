// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Bookmark.h instead.

#import <CoreData/CoreData.h>


extern const struct BookmarkAttributes {
	__unsafe_unretained NSString *default_bookmark;
	__unsafe_unretained NSString *last_update_time;
	__unsafe_unretained NSString *offset;
} BookmarkAttributes;

extern const struct BookmarkRelationships {
	__unsafe_unretained NSString *book;
	__unsafe_unretained NSString *section;
} BookmarkRelationships;

extern const struct BookmarkFetchedProperties {
} BookmarkFetchedProperties;

@class Book;
@class Section;





@interface BookmarkID : NSManagedObjectID {}
@end

@interface _Bookmark : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BookmarkID*)objectID;





@property (nonatomic, strong) NSNumber* default_bookmark;



@property BOOL default_bookmarkValue;
- (BOOL)default_bookmarkValue;
- (void)setDefault_bookmarkValue:(BOOL)value_;

//- (BOOL)validateDefault_bookmark:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* last_update_time;



@property int32_t last_update_timeValue;
- (int32_t)last_update_timeValue;
- (void)setLast_update_timeValue:(int32_t)value_;

//- (BOOL)validateLast_update_time:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* offset;



@property int32_t offsetValue;
- (int32_t)offsetValue;
- (void)setOffsetValue:(int32_t)value_;

//- (BOOL)validateOffset:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Book *book;

//- (BOOL)validateBook:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Section *section;

//- (BOOL)validateSection:(id*)value_ error:(NSError**)error_;





@end

@interface _Bookmark (CoreDataGeneratedAccessors)

@end

@interface _Bookmark (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveDefault_bookmark;
- (void)setPrimitiveDefault_bookmark:(NSNumber*)value;

- (BOOL)primitiveDefault_bookmarkValue;
- (void)setPrimitiveDefault_bookmarkValue:(BOOL)value_;




- (NSNumber*)primitiveLast_update_time;
- (void)setPrimitiveLast_update_time:(NSNumber*)value;

- (int32_t)primitiveLast_update_timeValue;
- (void)setPrimitiveLast_update_timeValue:(int32_t)value_;




- (NSNumber*)primitiveOffset;
- (void)setPrimitiveOffset:(NSNumber*)value;

- (int32_t)primitiveOffsetValue;
- (void)setPrimitiveOffsetValue:(int32_t)value_;





- (Book*)primitiveBook;
- (void)setPrimitiveBook:(Book*)value;



- (Section*)primitiveSection;
- (void)setPrimitiveSection:(Section*)value;


@end
