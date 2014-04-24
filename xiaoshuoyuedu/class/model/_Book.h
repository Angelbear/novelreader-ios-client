// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Book.h instead.

#import <CoreData/CoreData.h>


extern const struct BookAttributes {
	__unsafe_unretained NSString *author;
	__unsafe_unretained NSString *cover;
	__unsafe_unretained NSString *from;
	__unsafe_unretained NSString *image_url;
	__unsafe_unretained NSString *last_update_time;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *url;
} BookAttributes;

extern const struct BookRelationships {
	__unsafe_unretained NSString *bookmark;
	__unsafe_unretained NSString *sections;
} BookRelationships;

extern const struct BookFetchedProperties {
} BookFetchedProperties;

@class Bookmark;
@class Section;


@class NSObject;






@interface BookID : NSManagedObjectID {}
@end

@interface _Book : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BookID*)objectID;





@property (nonatomic, strong) NSString* author;



//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id cover;



//- (BOOL)validateCover:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* from;



//- (BOOL)validateFrom:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* image_url;



//- (BOOL)validateImage_url:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* last_update_time;



@property int32_t last_update_timeValue;
- (int32_t)last_update_timeValue;
- (void)setLast_update_timeValue:(int32_t)value_;

//- (BOOL)validateLast_update_time:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Bookmark *bookmark;

//- (BOOL)validateBookmark:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *sections;

- (NSMutableSet*)sectionsSet;





@end

@interface _Book (CoreDataGeneratedAccessors)

- (void)addSections:(NSSet*)value_;
- (void)removeSections:(NSSet*)value_;
- (void)addSectionsObject:(Section*)value_;
- (void)removeSectionsObject:(Section*)value_;

@end

@interface _Book (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAuthor;
- (void)setPrimitiveAuthor:(NSString*)value;




- (id)primitiveCover;
- (void)setPrimitiveCover:(id)value;




- (NSString*)primitiveFrom;
- (void)setPrimitiveFrom:(NSString*)value;




- (NSString*)primitiveImage_url;
- (void)setPrimitiveImage_url:(NSString*)value;




- (NSNumber*)primitiveLast_update_time;
- (void)setPrimitiveLast_update_time:(NSNumber*)value;

- (int32_t)primitiveLast_update_timeValue;
- (void)setPrimitiveLast_update_timeValue:(int32_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (Bookmark*)primitiveBookmark;
- (void)setPrimitiveBookmark:(Bookmark*)value;



- (NSMutableSet*)primitiveSections;
- (void)setPrimitiveSections:(NSMutableSet*)value;


@end
