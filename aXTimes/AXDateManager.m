//
//  AXDateManager.m
//  aXTimes
//
//  Created by fuesec on 5/11/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXDateManager.h"
#import "NSDate+AXNSDateCategory.h"

@interface AXDateManager ()
@property (nonatomic) NSUInteger calendarUnitFlags;
@end

@implementation AXDateManager
static AXDateManager *sharedInstance = nil; // Singleton

+ (AXDateManager *)sharedInstance {
	DEFINE_SHARED_INSTANCE_USING_BLOCK (^{
											sharedInstance = [self new];
											return sharedInstance;
										});
}

- (void)initWithDate:(NSDate *)date {
	self.calendarUnitFlags = CALENDARUNITCOMPONENTS;
	self.currentDate = date;
}

- (BOOL)isToday {
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *componentsNow = [cal components:self.calendarUnitFlags fromDate:[NSDate date]];
	NSDateComponents *componentsCurrenDate = [cal components:self.calendarUnitFlags fromDate:self.currentDate];

	if (componentsNow.year == componentsCurrenDate.year && componentsNow.month == componentsCurrenDate.month && componentsNow.day == componentsCurrenDate.day) {
		return YES;
	} else {
		return NO;
	}
}

- (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime {
	NSDate *fromDate;
	NSDate *toDate;

	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

	[calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
				 interval:NULL forDate:fromDateTime];
	[calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
				 interval:NULL forDate:toDateTime];

	NSDateComponents *difference = [calendar components:NSDayCalendarUnit
											   fromDate:fromDate toDate:toDate options:0];

	return [difference day];
}

- (void)setCurrentDate:(NSDate *)currentDate {
//    _currentDate = currentDate;
    _currentDate = [currentDate truncateHours];
}

@end
