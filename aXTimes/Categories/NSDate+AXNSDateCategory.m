//
//  NSDate+AXNSDateCategory.m
//  aXTimes
//
//  Created by fuesec on 6/30/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "NSDate+AXNSDateCategory.h"
#import "NSCalendar+AXNSCalendarCategory.h"

#define WEEKCALENDARUNITCOMPONENTS           (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitTimeZone | NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear | NSCalendarUnitYearForWeekOfYear)

@implementation NSDate (AXNSDateCategory)

- (NSString *)formatAs_dd {
    static NSDateFormatter *_specialFormatting;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _specialFormatting = [NSDateFormatter new];
        _specialFormatting.dateFormat = @"dd";
    });
    
    return [_specialFormatting stringFromDate:self];
}

- (NSString *)formatAs_MM {
    static NSDateFormatter *_specialFormatting;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _specialFormatting = [NSDateFormatter new];
        _specialFormatting.dateFormat = @"MM";
    });
    
    return [_specialFormatting stringFromDate:self];
}

- (NSString *)formatAs_yyyy {
    static NSDateFormatter *_specialFormatting;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _specialFormatting = [NSDateFormatter new];
        _specialFormatting.dateFormat = @"yyyy";
    });
    
    return [_specialFormatting stringFromDate:self];
}

- (NSString *)formatAs_weekOfYear_yearForWeekOfYear {
    NSCalendar *calendar = [NSCalendar defaultCalendar_Static:YES];
    NSDateComponents *components = [calendar components:WEEKCALENDARUNITCOMPONENTS
                                               fromDate:self];
    
    NSInteger weekOfYear = [components weekOfYear];
    NSInteger yearForWeekOfYear = [components yearForWeekOfYear];

    return [NSString stringWithFormat:@"%ld/%ld",
            (long)weekOfYear,
            (long)yearForWeekOfYear];
}

- (NSString *)dayKey {
    static NSDateFormatter *_specialFormatting;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _specialFormatting = [NSDateFormatter new];
        _specialFormatting.dateFormat = @"yyyyMMdd";
    });
    
    return [_specialFormatting stringFromDate:self];
}

- (BOOL)isSameDay:(NSDate *)date {
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

	NSDateComponents *componentsSelfDate = [cal components:CALENDARUNITCOMPONENTS fromDate:self];
	NSDateComponents *componentsCompareDate = [cal components:CALENDARUNITCOMPONENTS fromDate:date];

	if (componentsSelfDate.year == componentsCompareDate.year && componentsSelfDate.month == componentsCompareDate.month && componentsSelfDate.day == componentsCompareDate.day) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)isSameDay:(NSDate *)date withReceiverTimeZoneName:(NSString *)receiverTimeZoneName andInputTimeZoneName:(NSString *)inputTimeZoneName {
	NSCalendar *calReceiver = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

	[calReceiver setTimeZone:[[NSTimeZone alloc] initWithName:receiverTimeZoneName]];
	NSCalendar *calInput = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	[calInput setTimeZone:[[NSTimeZone alloc] initWithName:inputTimeZoneName]];

	NSDateComponents *componentsSelfDate = [calReceiver components:CALENDARUNITCOMPONENTS fromDate:self];
	NSDateComponents *componentsCompareDate = [calInput components:CALENDARUNITCOMPONENTS fromDate:date];

	if (componentsSelfDate.year == componentsCompareDate.year && componentsSelfDate.month == componentsCompareDate.month && componentsSelfDate.day == componentsCompareDate.day) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)isSameMonth:(NSDate *)date {
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *componentsSelfDate = [cal components:CALENDARUNITCOMPONENTS fromDate:self];
	NSDateComponents *componentsCompareDate = [cal components:CALENDARUNITCOMPONENTS fromDate:date];

	if (componentsSelfDate.year == componentsCompareDate.year && componentsSelfDate.month == componentsCompareDate.month) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)isSameMonth:(NSDate *)date withReceiverTimeZoneName:(NSString *)receiverTimeZoneName andInputTimeZoneName:(NSString *)inputTimeZoneName {
	NSCalendar *calReceiver = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

	[calReceiver setTimeZone:[[NSTimeZone alloc] initWithName:receiverTimeZoneName]];
	NSCalendar *calInput = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	[calInput setTimeZone:[[NSTimeZone alloc] initWithName:inputTimeZoneName]];

	NSDateComponents *componentsSelfDate = [calReceiver components:CALENDARUNITCOMPONENTS fromDate:self];
	NSDateComponents *componentsCompareDate = [calInput components:CALENDARUNITCOMPONENTS fromDate:date];

	if (componentsSelfDate.year == componentsCompareDate.year && componentsSelfDate.month == componentsCompareDate.month) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)isSameMonthOnlyMonthComponent:(NSDate *)date {
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *componentsSelfDate = [cal components:CALENDARUNITCOMPONENTS fromDate:self];
	NSDateComponents *componentsCompareDate = [cal components:CALENDARUNITCOMPONENTS fromDate:date];

	if (componentsSelfDate.month == componentsCompareDate.month) {
		return YES;
	} else {
		return NO;
	}
}

- (NSDate *)updateDayMonthYearComponentWithDate:(NSDate *)date {
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *componentsSelfDate = [cal components:CALENDARUNITCOMPONENTS fromDate:self];
	NSDateComponents *componentsDayDate = [cal components:CALENDARUNITCOMPONENTS fromDate:date];

	componentsSelfDate.day = componentsDayDate.day;
	componentsSelfDate.month = componentsDayDate.month;
	componentsSelfDate.year = componentsDayDate.year;

	return [cal dateFromComponents:componentsSelfDate];
}

- (BOOL)isWithinBeginDate:(NSDate *)begin andEndDate:(NSDate *)end {
    return ([self compare:begin] != NSOrderedAscending &&
            [self compare:end] != NSOrderedDescending);
}

- (NSDate *)addMinutes:(NSInteger)minutes {
    NSCalendar *calendar = [NSCalendar defaultCalendar_Static:YES];
    NSDateComponents *component = [NSDateComponents new];
    component.minute = minutes;
    return [calendar dateByAddingComponents:component
                                     toDate:self
                                    options:0];
}

- (NSDate *)addDays:(NSInteger)days {
    NSCalendar *calendar = [NSCalendar defaultCalendar_Static:YES];
    NSDateComponents *components = [NSDateComponents new];
    components.day = days;
    return [calendar dateByAddingComponents:components
                                     toDate:self
                                    options:0];
}

- (NSDate *)addMonths:(NSInteger)months {
    NSCalendar *calendar = [NSCalendar defaultCalendar_Static:YES];
    NSDateComponents *components = [NSDateComponents new];
    components.month = months;
    return [calendar dateByAddingComponents:components
                                     toDate:self
                                    options:0];
}

- (NSDate *)addYears:(NSInteger)years {
    NSCalendar *calendar = [NSCalendar defaultCalendar_Static:YES];
    NSDateComponents *components = [NSDateComponents new];
    components.year = years;
    return [calendar dateByAddingComponents:components
                                     toDate:self
                                    options:0];
}


- (NSDate *)truncateSeconds {
    NSCalendar *calendar = [NSCalendar defaultCalendar_Static:YES];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitTimeZone;
    NSDateComponents *fromDateComponents = [calendar components:unitFlags fromDate:self];
    return [calendar dateFromComponents:fromDateComponents];
}

- (NSDate *)truncateHours {
    NSCalendar *calendar = [NSCalendar defaultCalendar_Static:YES];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitTimeZone;
    NSDateComponents *fromDateComponents = [calendar components:unitFlags fromDate:self];
    return [calendar dateFromComponents:fromDateComponents];
}

- (NSInteger)daysBetween:(NSDate *)toDateTime {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar defaultCalendar_Static:YES];
    
    [calendar rangeOfUnit:NSCalendarUnitDay
                startDate:&fromDate
                 interval:NULL
                  forDate:self];
    [calendar rangeOfUnit:NSCalendarUnitDay
                startDate:&toDate
                 interval:NULL
                  forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate
                                                 toDate:toDate
                                                options:0];
    
    return [difference day];
}

- (NSDate *)weekBeginning {
    NSCalendar *cal = [NSCalendar defaultCalendar_Static:YES];
    NSDate *weekStart;
    NSTimeInterval interval;
    [cal rangeOfUnit:NSCalendarUnitWeekOfYear
           startDate:&weekStart
            interval:&interval
             forDate:self];

    return weekStart;
}

- (NSDate *)monthBeginning {
    NSCalendar *cal = [NSCalendar defaultCalendar_Static:YES];
    
    NSDateComponents *components = [cal components:CALENDARUNITCOMPONENTS
                                          fromDate:self];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    [components setDay:1];
    
    NSDate *monthStart = [cal dateFromComponents:components];
    DebugLog(@"Original date is %@ and beginning of month is %@", self, monthStart);

    return monthStart;
}

- (NSUInteger)daysInMonth {
    NSCalendar *cal = [NSCalendar defaultCalendar_Static:YES];
    
    NSRange days = [cal rangeOfUnit:NSCalendarUnitDay
                             inUnit:NSCalendarUnitMonth
                            forDate:self];
    return days.length;
}

- (NSUInteger)daysInYear {
    // http://stackoverflow.com/questions/2078372/how-do-i-calculate-the-number-of-days-in-this-year-in-objective-c
    NSCalendar *cal = [NSCalendar defaultCalendar_Static:YES];
    
    NSUInteger daysInYear = 0;
    NSDateComponents *componentsForYear = [cal components:NSCalendarUnitYear
                                                 fromDate:self];
    NSUInteger months = [cal rangeOfUnit:NSCalendarUnitMonth
                                  inUnit:NSCalendarUnitYear
                                 forDate:self].length;
    for (int i = 1; i <= months; i++) {
        componentsForYear.month = i;
        NSDate *month = [cal dateFromComponents:componentsForYear];
        daysInYear += [month daysInMonth];
    }
    return daysInYear;
}


@end
