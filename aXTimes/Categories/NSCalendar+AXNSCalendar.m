//
//  NSCalendar+AXNSCalendar.m
//  aXTimes
//
//  Created by fuesec on 11/30/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "NSCalendar+AXNSCalendar.h"

@implementation NSCalendar (AXNSCalendar) //TODO mhm
- (NSInteger)daysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
	NSCalendarUnit units = NSCalendarUnitEra | NSCalendarUnitYear |
		NSCalendarUnitMonth | NSCalendarUnitDay;
	NSDateComponents *comp1 = [self components:units fromDate:startDate];
	NSDateComponents *comp2 = [self components:units fromDate:endDate];

	[comp1 setHour:12];
	[comp2 setHour:12];
	NSDate *date1 = [self dateFromComponents:comp1];
	NSDate *date2 = [self dateFromComponents:comp2];
	return [[self components:NSCalendarUnitDay fromDate:date1 toDate:date2 options:0] day];
}

@end
