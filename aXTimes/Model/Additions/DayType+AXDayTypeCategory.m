//
//  DayType+AXDayTypeCategory.m
//  aXTimes
//
//  Created by fuesec on 2/27/14.
//  Copyright (c) 2014 aXimilate. All rights reserved.
//

#import "DayType+AXDayTypeCategory.h"

@implementation DayType (AXDayTypeCategory)
- (void)setWork {
	NSNumber *noBoolean = [NSNumber numberWithBool:NO];
	NSNumber *yesBoolean = [NSNumber numberWithBool:YES];

	[self setWork:yesBoolean];
	[self setVacation:noBoolean];
	[self setSickness:noBoolean];
	[self setHoliday:noBoolean];
}

- (void)setVacation; {
	NSNumber *noBoolean = [NSNumber numberWithBool:NO];
	NSNumber *yesBoolean = [NSNumber numberWithBool:YES];
	[self setWork:yesBoolean];
	[self setVacation:yesBoolean];
	[self setSickness:noBoolean];
	[self setHoliday:noBoolean];
}

- (void)setSickness {
	NSNumber *noBoolean = [NSNumber numberWithBool:NO];
	NSNumber *yesBoolean = [NSNumber numberWithBool:YES];

	[self setWork:yesBoolean];
	[self setVacation:noBoolean];
	[self setSickness:yesBoolean];
	[self setHoliday:noBoolean];
}

- (void)setHoliday {
    NSNumber *noBoolean = [NSNumber numberWithBool:NO];
    NSNumber *yesBoolean = [NSNumber numberWithBool:YES];
    
    [self setWork:noBoolean];
    [self setVacation:noBoolean];
    [self setSickness:noBoolean];
    [self setHoliday:yesBoolean];
}

- (void)setOff {
	NSNumber *noBoolean = [NSNumber numberWithBool:NO];

	[self setWork:noBoolean];
	[self setVacation:noBoolean];
	[self setSickness:noBoolean];
	[self setHoliday:noBoolean];
}

- (BOOL)isOff {
	if (![self.work boolValue] && ![self.holiday boolValue] && ![self.vacation boolValue] && ![self.sickness boolValue]) {
		return YES;
	} else {
		return NO;
	}
}

@end
