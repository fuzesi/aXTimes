//
//  NSString+AXNSStringCategory.m
//  aXTimes
//
//  Created by fuesec on 5/26/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "NSString+AXNSStringCategory.h"

@implementation NSString (AXNSStringCategory)

- (NSString *)trim {
	NSMutableString *str = [self mutableCopy];

	CFStringTrimWhitespace((__bridge CFMutableStringRef)str);
	return str;
}

- (NSString *)appendStringWithWhiteSpace:(NSString *)appendString {
	NSMutableString *str = [self mutableCopy];

	CFStringAppend((__bridge CFMutableStringRef)str, (__bridge CFStringRef)([NSString stringWithFormat:@" %@", appendString]));
	return str;
}

- (NSUInteger)numberOfLines {
    NSUInteger length = [[self componentsSeparatedByCharactersInSet:
                          [NSCharacterSet newlineCharacterSet]] count];
    return length;
}

@end
