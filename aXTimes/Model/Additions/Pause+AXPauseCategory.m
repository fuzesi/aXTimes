//
//  Pause+AXPauseCategory.m
//  aXTimes
//
//  Created by fuesec on 6/6/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "Pause+AXPauseCategory.h"
#import "NSNumber+AXNSNumberCategory.h"

@implementation Pause (AXPauseCategory)

#pragma mark - public methods
- (NSNumber *)secondsPausedUntilNow {
	if (self.startTime == nil) {
		return [NSNumber numberWithInt:0];
	} else {
		NSDate *nowDate = [NSDate date];
		NSTimeInterval distanceBetweenDates = [nowDate timeIntervalSinceDate:self.startTime];
		return [NSNumber numberWithDouble:distanceBetweenDates];
	}
}

- (NSString *)totalTimeUntilNowWithSeconds {
	return [self.secondsPausedUntilNow numberAsSecondsToCountdownString];
}

- (double)secondsPaused {
	if ((self.startTime == nil) || (self.startTime != nil && self.endTime == nil) || (self.startTime == nil && self.endTime == nil)) {
		return (double)0.0;
	} else {
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

		NSDateComponents *componentsCheckin = [calendar components:CALENDARUNITCOMPONENTS fromDate:self.startTime];
		[componentsCheckin setSecond:0];

		NSDate *tempCheckin = [calendar dateFromComponents:componentsCheckin];
		NSDateComponents *componentsCheckout = [calendar components:CALENDARUNITCOMPONENTS fromDate:self.endTime];
		[componentsCheckout setSecond:0];
		NSDate *tempCheckout = [calendar dateFromComponents:componentsCheckout];

		NSTimeInterval distanceBetweenDates = [tempCheckout timeIntervalSinceDate:tempCheckin];
		return distanceBetweenDates;
	}
}

- (double)secondsPausedNotZeroed{
    if ((self.startTime == nil) || (self.startTime != nil && self.endTime == nil) || (self.startTime == nil && self.endTime == nil)) {
        return (double)0.0;
    } else {
//        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//        
//        NSDateComponents *componentsCheckin = [calendar components:CALENDARUNITCOMPONENTS fromDate:self.startTime];
//        [componentsCheckin setSecond:0];
//        
//        NSDate *tempCheckin = [calendar dateFromComponents:componentsCheckin];
//        NSDateComponents *componentsCheckout = [calendar components:CALENDARUNITCOMPONENTS fromDate:self.endTime];
//        [componentsCheckout setSecond:0];
//        NSDate *tempCheckout = [calendar dateFromComponents:componentsCheckout];
        
        NSTimeInterval distanceBetweenDates = [self.endTime timeIntervalSinceDate:self.startTime];
        return distanceBetweenDates;
    }
}

- (double)minutesPaused {
	double minutesPaused = ([self secondsPaused] / (double)60.0);

	return minutesPaused;
}

- (double)hoursPaused {
	double hoursPaused = ([self minutesPaused] / (double)60.0);

	return hoursPaused;
}

- (NSString *)hoursPausedDisplayValue {
	return [[NSNumber numberWithDouble:[self hoursPaused]] timeFormatted];
}

@end
