//
//  NSNumberFormatter+AXNSNumberFormatterCategory.m
//  aXTimes
//
//  Created by Christopher Füseschi on 31/08/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "NSNumberFormatter+AXNSNumberFormatterCategory.h"

@implementation NSNumberFormatter (AXNSNumberFormatterCategory)

+ (NSNumberFormatter *)defaultNumberFormatter_Static:(BOOL)shouldBeStatic {
    static NSNumberFormatter *_specialFormatting;
    static dispatch_once_t onceToken;
    if (shouldBeStatic) {
        dispatch_once(&onceToken, ^{
            _specialFormatting = [NSNumberFormatter new];
            [_specialFormatting setNumberStyle:NSNumberFormatterDecimalStyle];
            [_specialFormatting setMaximumFractionDigits:2];
            [_specialFormatting setMinimumFractionDigits:2];
            [_specialFormatting setRoundingIncrement:[NSNumber numberWithDouble:0.01]];
            [_specialFormatting setRoundingMode:NSNumberFormatterRoundHalfUp];
        });
        return _specialFormatting;
    } else {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        [formatter setMinimumFractionDigits:2];
        [formatter setRoundingIncrement:[NSNumber numberWithDouble:0.01]];
        [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
        return formatter;
    }
}

@end
