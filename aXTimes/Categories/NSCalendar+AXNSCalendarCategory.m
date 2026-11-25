//
//  NSCalendar+AXNSCalendarCategory.m
//  aXTimes
//
//  Created by Christopher Füseschi on 05/09/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "NSCalendar+AXNSCalendarCategory.h"

@implementation NSCalendar (AXNSCalendarCategory)

+ (NSCalendar *)defaultCalendar_Static:(BOOL)shouldBeStatic {
    static NSCalendar *_calendar;
    static dispatch_once_t onceToken;
    if (shouldBeStatic) {
        dispatch_once(&onceToken, ^{
            _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            // -> da dann automatisch gesetzt wird [cal setMinimumDaysInFirstWeek:4]
            // ISO 8601 "The first week of a year is the week that contains the first Thursday of the year."
            [_calendar setLocale:[NSLocale currentLocale]];
            [_calendar setMinimumDaysInFirstWeek:4];
            [_calendar setFirstWeekday:2];
        });
        return _calendar;
    } else {
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        // -> da dann automatisch gesetzt wird [cal setMinimumDaysInFirstWeek:4]
        // ISO 8601 "The first week of a year is the week that contains the first Thursday of the year."
        [cal setLocale:[NSLocale currentLocale]];
        [cal setMinimumDaysInFirstWeek:4];
        [cal setFirstWeekday:2];
        return cal;
    }
}

@end
