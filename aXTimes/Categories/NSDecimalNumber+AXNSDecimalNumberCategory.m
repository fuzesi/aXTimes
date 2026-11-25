//
//  NSDecimalNumber+AXNSDecimalNumberCategory.m
//  aXTimes
//
//  Created by Christopher Füseschi on 31/08/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "NSDecimalNumber+AXNSDecimalNumberCategory.h"
#import "NSNumberFormatter+AXNSNumberFormatterCategory.h"

@implementation NSDecimalNumber (AXNSDecimalNumberCategory)

- (NSString *)stringValueNumberFormatted {
    return [[NSNumberFormatter defaultNumberFormatter_Static:YES] stringFromNumber:self];
}

@end
