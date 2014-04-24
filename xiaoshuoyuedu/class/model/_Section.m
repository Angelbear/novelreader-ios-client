// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Section.m instead.

#import "_Section.h"

const struct SectionAttributes SectionAttributes = {
	.from = @"from",
	.last_update_time = @"last_update_time",
	.name = @"name",
	.text = @"text",
	.url = @"url",
};

const struct SectionRelationships SectionRelationships = {
	.book = @"book",
	.bookmark = @"bookmark",
};

const struct SectionFetchedProperties SectionFetchedProperties = {
};

@implementation SectionID
@end

@implementation _Section

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Section" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Section";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Section" inManagedObjectContext:moc_];
}

- (SectionID*)objectID {
	return (SectionID*)[super objectID];
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




@dynamic from;






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






@dynamic text;






@dynamic url;






@dynamic book;

	

@dynamic bookmark;

	






@end
