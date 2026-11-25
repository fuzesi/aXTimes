//
//  NSDateFormatter+AXDateFormatters.m
//  aXTimes
//
//  Created by Christopher Füseschi on 01/06/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "NSDateFormatter+AXDateFormatters.h"

#define DATEFORMATTERMONTHYEAR           @ "MMMM yyyy"
#define DATEFORMATTER_SHARING_DATE       @ "dd.MM.yyyy"
#define DATEFORMATTERFULL                @ "yyyy-MM-dd'T'hh:mm:ssZ"

@implementation NSDateFormatter (AXDateFormatters)

// http://stackoverflow.com/questions/11231844/use-a-static-variable-inside-an-objective-c-category

+ (NSDateFormatter *)formatter_HH_mm_Static:(BOOL)shouldBeStatic {
    static NSDateFormatter *_specialFormatting;
    static dispatch_once_t onceToken;
    if (shouldBeStatic) {
        dispatch_once(&onceToken, ^{
            _specialFormatting = [NSDateFormatter new];
            _specialFormatting.dateFormat = DATEFORMATTERHOURMINUTE;
        });
        return _specialFormatting;
    } else {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = DATEFORMATTERHOURMINUTE;
        return formatter;
    }
}

+ (NSDateFormatter *)formatter_HH_mm_d_M_Static:(BOOL)shouldBeStatic {
    static NSDateFormatter *_specialFormatting;
    static dispatch_once_t onceToken;
    if (shouldBeStatic) {
        dispatch_once(&onceToken, ^{
            _specialFormatting = [NSDateFormatter new];
            _specialFormatting.dateFormat = @"HH:mm d. MMM";
        });
        return _specialFormatting;
    } else {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"HH:mm d. MMM";
        return formatter;
    }
}

+ (NSDateFormatter *)formatter_HH_mm_d_M_yy_Static:(BOOL)shouldBeStatic {
    static NSDateFormatter *_specialFormatting;
    static dispatch_once_t onceToken;
    if (shouldBeStatic) {
        dispatch_once(&onceToken, ^{
            _specialFormatting = [NSDateFormatter new];
            _specialFormatting.dateFormat = @"HH:mm d. MMM yy";
        });
        return _specialFormatting;
    } else {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"HH:mm d. MMM yy";
        return formatter;
    }
}

+ (NSDateFormatter *)formatter_Month_Year_Static:(BOOL)shouldBeStatic {
    static NSDateFormatter *_specialFormatting;
    static dispatch_once_t onceToken;
    if (shouldBeStatic) {
        dispatch_once(&onceToken, ^{
            _specialFormatting = [NSDateFormatter new];
            _specialFormatting.dateFormat = DATEFORMATTERMONTHYEAR;
        });
        return _specialFormatting;
    } else {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = DATEFORMATTERMONTHYEAR;
        return formatter;
    }
}

+ (NSDateFormatter *)formatter_Day_Month_Year_Static:(BOOL)shouldBeStatic {
    static NSDateFormatter *_specialFormatting;
    static dispatch_once_t onceToken;
    if (shouldBeStatic) {
        dispatch_once(&onceToken, ^{
            _specialFormatting = [NSDateFormatter new];
            _specialFormatting.dateFormat = DATEFORMATTER_SHARING_DATE;
        });
        return _specialFormatting;
    } else {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = DATEFORMATTER_SHARING_DATE;
        return formatter;
    }
}

+ (NSDateFormatter *)formatter_d_MMM_yyyy_Static:(BOOL)shouldBeStatic {
    static NSDateFormatter *_specialFormatting;
    static dispatch_once_t onceToken;
    if (shouldBeStatic) {
        dispatch_once(&onceToken, ^{
            _specialFormatting = [NSDateFormatter new];
            _specialFormatting.dateFormat = @"d. MMM yyyy";
        });
        return _specialFormatting;
    } else {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"d. MMM yyyy";
        return formatter;
    }
}

+ (NSDateFormatter *)formatter_fulltimeStamp:(BOOL)shouldBeStatic {
    static NSDateFormatter *_specialFormatting;
    static dispatch_once_t onceToken;
    if (shouldBeStatic) {
        dispatch_once(&onceToken, ^{
            _specialFormatting = [NSDateFormatter new];
            _specialFormatting.dateFormat = DATEFORMATTERFULL;
        });
        return _specialFormatting;
    } else {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = DATEFORMATTERFULL;
        return formatter;
    }
}


@end
