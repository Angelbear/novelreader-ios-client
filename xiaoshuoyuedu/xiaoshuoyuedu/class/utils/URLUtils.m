//
//  URLUtils.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-25.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "URLUtils.h"

@implementation URLUtils

+ (NSString*) uri_encode:(NSString*) str {
    NSString* encoded = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                             kCFAllocatorDefault,
                                                                                             (__bridge CFStringRef)str,
                                                                                             NULL,
                                                                                             (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                             kCFStringEncodingUTF8));
	return encoded;
}

@end
