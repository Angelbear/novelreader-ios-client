// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Bookmark.m instead.

#import "_Bookmark.h"

const struct BookmarkAttributes BookmarkAttributes = {
	.default_bookmark = @"default_bookmark",
	.last_update_time = @"last_update_time",
	.offset = @"offset",
};

const struct BookmarkRelationships BookmarkRelationships = {
	.book = @"book",
	.section = @"section",
};

const struct BookmarkFetchedProperties BookmarkFetchedProperties = {
};

@implementation BookmarkID
@end

@implementation _Bookmark

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Bookmark";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:moc_];
}

- (BookmarkID*)objectID {
	return (BookmarkID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"default_bookmarkValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"default_bookmark"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"last_update_timeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"last_update_time"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"offsetValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"offset"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic default_bookmark;



- (BOOL)default_bookmarkValue {
	NSNumber *result = [self default_bookmark];
	return [result boolValue];
}

- (void)setDefault_bookmarkValue:(BOOL)value_ {
	[self setDefault_bookmark:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDefault_bookmarkValue {
	NSNumber *result = [self primitiveDefault_bookmark];
	return [result boolValue];
}

- (void)setPrimitiveDefault_bookmarkValue:(BOOL)value_ {
	[self setPrimitiveDefault_bookmark:[NSNumber numberWithBool:value_]];
}





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





@dynamic offset;



- (int32_t)offsetValue {
	NSNumber *result = [self offset];
	return [result intValue];
}

- (void)setOffsetValue:(int32_t)value_ {
	[self setOffset:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveOffsetValue {
	NSNumber *result = [self primitiveOffset];
	return [result intValue];
}

- (void)setPrimitiveOffsetValue:(int32_t)value_ {
	[self setPrimitiveOffset:[NSNumber numberWithInt:value_]];
}





@dynamic book;

	

@dynamic section;

	






@end
