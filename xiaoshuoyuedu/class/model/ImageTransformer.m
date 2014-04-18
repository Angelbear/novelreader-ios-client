//
//  ImageTransformer.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 14-4-15.
//  Copyright (c) 2014年 Yangyang Zhao. All rights reserved.
//

#import "ImageTransformer.h"

@implementation ImageTransformer
+ (BOOL)allowsReverseTransformation {
    return YES;
}
+ (Class)transformedValueClass {
    return [NSData class];
}
- (id)transformedValue:(id)value {
    NSData *data = UIImagePNGRepresentation(value);
    return data;
}
- (id)reverseTransformedValue:(id)value {
	return [[UIImage alloc] initWithData:value];
}
@end
