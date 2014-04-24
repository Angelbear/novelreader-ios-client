// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Book.m instead.

#import "_Book.h"

const struct BookAttributes BookAttributes = {
	.author = @"author",
	.cover = @"cover",
	.from = @"from",
	.image_url = @"image_url",
	.last_update_time = @"last_update_time",
	.name = @"name",
	.url = @"url",
};

const struct BookRelationships BookRelationships = {
	.bookmark = @"bookmark",
	.sections = @"sections",
};

const struct BookFetchedProperties BookFetchedProperties = {
};

@implementation BookID
@end

@implementation _Book

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Book";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Book" inManagedObjectContext:moc_];
}

- (BookID*)objectID {
	return (BookID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"last_update_timeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"last_update_time"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic author;






@dynamic cover;






@dynamic from;






@dynamic image_url;






@dynamic last_update_time;



- (int32_t)last_update_timeValue {
	NSNumber *result = [self last_update_time];
	return [result intValue];
}

- (void)setLast_update_timeValue:(int32_t)value_ {
	[self setLast_update_time:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveLast_update_timeValue {
	NSNumber *result = [self primitiveLast_update_time];
	return [result intValue];
}

- (void)setPrimitiveLast_update_timeValue:(int32_t)value_ {
	[self setPrimitiveLast_update_time:[NSNumber numberWithInt:value_]];
}





@dynamic name;






@dynamic url;






@dynamic bookmark;

	

@dynamic sections;

	
- (NSMutableSet*)sectionsSet {
	[self willAccessValueForKey:@"sections"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"sections"];
  
	[self didAccessValueForKey:@"sections"];
	return result;
}
	






@end
