// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Section.h instead.

#import <CoreData/CoreData.h>


extern const struct SectionAttributes {
	__unsafe_unretained NSString *from;
	__unsafe_unretained NSString *last_update_time;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *text;
	__unsafe_unretained NSString *url;
} SectionAttributes;

extern const struct SectionRelationships {
	__unsafe_unretained NSString *book;
	__unsafe_unretained NSString *bookmark;
} SectionRelationships;

extern const struct SectionFetchedProperties {
} SectionFetchedProperties;

@class Book;
@class Bookmark;







@interface SectionID : NSManagedObjectID {}
@end

@interface _Section : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SectionID*)objectID;





@property (nonatomic, strong) NSString* from;



//- (BOOL)validateFrom:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* last_update_time;



@property int32_t last_update_timeValue;
- (int32_t)last_update_timeValue;
- (void)setLast_update_timeValue:(int32_t)value_;

//- (BOOL)validateLast_update_time:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* text;



//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Book *book;

//- (BOOL)validateBook:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Bookmark *bookmark;

//- (BOOL)validateBookmark:(id*)value_ error:(NSError**)error_;





@end

@interface _Section (CoreDataGeneratedAccessors)

@end

@interface _Section (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveFrom;
- (void)setPrimitiveFrom:(NSString*)value;




- (NSNumber*)primitiveLast_update_time;
- (void)setPrimitiveLast_update_time:(NSNumber*)value;

- (int32_t)primitiveLast_update_timeValue;
- (void)setPrimitiveLast_update_timeValue:(int32_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (Book*)primitiveBook;
- (void)setPrimitiveBook:(Book*)value;



- (Bookmark*)primitiveBookmark;
- (void)setPrimitiveBookmark:(Bookmark*)value;


@end
