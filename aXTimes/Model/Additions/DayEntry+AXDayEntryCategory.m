//
//  DayEntry+AXDayEntryCategory.m
//  aXTimes
//
//  Created by fuesec on 5/19/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "DayEntry+AXDayEntryCategory.h"
#import "AXSettingsManager.h"
#import "NSNumber+AXNSNumberCategory.h"
#import "Pause+AXPauseCategory.h"
#import "NSDate+AXNSDateCategory.h"

static NSNumberFormatter *decimalNumberFormatter;

@implementation DayEntry (AXDayEntryCategory)

+ (void)load {
	decimalNumberFormatter = [NSNumberFormatter new];
	[decimalNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[decimalNumberFormatter setMaximumFractionDigits:2];
	[decimalNumberFormatter setMinimumFractionDigits:2];
	[decimalNumberFormatter setRoundingIncrement:[NSNumber numberWithDouble:0.01]];
	[decimalNumberFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
}

+ (void)setDecimalSeperator:(NSString *)separator {
	[decimalNumberFormatter setDecimalSeparator:separator];
}

+ (NSString *)getDecimalSeperator {
	return [decimalNumberFormatter decimalSeparator];
}

+ (void)setUsesGroupingSeparator:(BOOL)usingIt {
	[decimalNumberFormatter setUsesGroupingSeparator:usingIt];
}

- (DayEntry * )deepCopyWithDate:(NSDate *)date {
	DayEntry *dayEntry = [[AXDataStore sharedInstance] createDayEntry];

	dayEntry.checkInTime = [self.checkInTime updateDayMonthYearComponentWithDate:date];
	dayEntry.checkInTimeZone = self.checkInTimeZone;

	NSTimeInterval difference = [self.checkOutTime timeIntervalSinceDate:self.checkInTime];
	dayEntry.checkOutTime = [NSDate dateWithTimeInterval:difference sinceDate:dayEntry.checkInTime];
	dayEntry.checkOutTimeZone = self.checkOutTimeZone;

	dayEntry.comment = self.comment;
    
	dayEntry.hourlyWage = self.hourlyWage;
	dayEntry.creationDate = [NSDate date];

	for (Pause *pause in self.pauses) {
		difference = [pause.startTime timeIntervalSinceDate:self.checkInTime];
		Pause *newPause = [[AXDataStore sharedInstance] createPause];
		newPause.startTime = [NSDate dateWithTimeInterval:difference sinceDate:dayEntry.checkInTime];
		newPause.startTimeZone = pause.startTimeZone;

		difference = [pause.endTime timeIntervalSinceDate:pause.startTime];
		newPause.endTime = [NSDate dateWithTimeInterval:difference sinceDate:newPause.startTime];
		newPause.endTimeZone = pause.endTimeZone;
// TODO test whether pause also has reference to  dayentry
		[dayEntry addPausesObject:newPause];
	}
	return dayEntry;
}

- (double)grossMinutesToNetMinutes:(double)grossMinutes {
	AXSettingsManager *settingsController = [AXSettingsManager new];

	double timeUnitInMinutes = [settingsController getWorkTimeUnit];
	double timeUnitsWorked = grossMinutes / timeUnitInMinutes;
	int currentRoundingBehaviour = [settingsController getNetRounding];
	double returnValue = 0.0;

	switch (currentRoundingBehaviour) {
		case DEFAULTROUNDING : {
			double tempTimeUnitsWorked = floor(timeUnitsWorked);

			double moduloRemainder = timeUnitsWorked - tempTimeUnitsWorked;
//			if (timeUnitsWorked >= 1) {
//				moduloRemainder = fmod(timeUnitsWorked, tempTimeUnitsWorked);
//			} else {
//				moduloRemainder = timeUnitsWorked;
//			}

			if (moduloRemainder >= 0.5) {
				timeUnitsWorked = tempTimeUnitsWorked + 1;
			} else {
				timeUnitsWorked = tempTimeUnitsWorked;
			}
			returnValue = timeUnitsWorked * timeUnitInMinutes;
			break;
		}
		case ROUNDDOWN :
			returnValue = floor(timeUnitsWorked) * timeUnitInMinutes;
			break;
		case ROUNDUP :
			returnValue = ceil(timeUnitsWorked) * timeUnitInMinutes;
			break;
		default :
			break;
	}

	return returnValue;
}

#pragma mark - main getters
- (double)secondsWorkedAsDouble {
	if ((self.checkInTime == nil) || (self.checkInTime != nil && self.checkOutTime == nil) || (self.checkInTime == nil && self.checkOutTime == nil)) {
		return (double)0.0;
	} else {
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

		NSDateComponents *componentsCheckin = [calendar components:CALENDARUNITCOMPONENTS fromDate:self.checkInTime];
		[componentsCheckin setSecond:0];

		NSDate *tempCheckin = [calendar dateFromComponents:componentsCheckin];
		NSDateComponents *componentsCheckout = [calendar components:CALENDARUNITCOMPONENTS fromDate:self.checkOutTime];
		[componentsCheckout setSecond:0];
		NSDate *tempCheckout = [calendar dateFromComponents:componentsCheckout];

		NSTimeInterval distanceBetweenDates = [tempCheckout timeIntervalSinceDate:tempCheckin];
		for (Pause *pause in self.pauses) {
			if (pause.startTime != nil && pause.endTime != nil) {
				distanceBetweenDates = distanceBetweenDates -  [pause secondsPaused];
			}
		}
		return distanceBetweenDates;
	}
}

- (double)minutesWorkedAsDouble {
	double minutesWorked = ([self secondsWorkedAsDouble] / (double)60.0);

	return minutesWorked;
}

- (double)secondsWorkedUntilNowAsDouble {
	if (self.checkInTime == nil) {
		return 0.0;
	} else {
		NSDate *nowDate = [NSDate date];
		NSTimeInterval distanceBetweenDates = [nowDate timeIntervalSinceDate:self.checkInTime];
		NSInteger lastObjectIndex = [self.pauses count] - 1;
		for (int i = 0; i < [self.pauses count]; i++) {
			Pause *pause = [self sortedPauses][i];

			if (pause.startTime != nil && pause.endTime != nil) {
				distanceBetweenDates = distanceBetweenDates - [pause.endTime timeIntervalSinceDate:pause.startTime];
			} else if (i == lastObjectIndex) {
				if (pause.startTime != nil) {
					distanceBetweenDates = distanceBetweenDates - [nowDate timeIntervalSinceDate:pause.startTime];
				}
			}
		}
		return distanceBetweenDates;
	}
}

- (double)minutesWorkedUntilNowAsDouble {
	double returnValue = ([self secondsWorkedUntilNowAsDouble] / (double)60.0);

	return returnValue;
}

- (double)salaryUntilNowAsDouble {
    // FIXME das kann nicht gut sein
	if (self.hourlyWage <= 0) {
		return (double)0.0;
	}

	double hoursWorked = [self minutesWorkedUntilNowAsDouble] / 60.0;
	double hourlyWage = [self.hourlyWage doubleValue];

	double returnValue = hoursWorked * hourlyWage;
	return returnValue;
}

- (double)netMinutesWorkedUntilNowAsDouble {
	return [self grossMinutesToNetMinutes:[self minutesWorkedUntilNowAsDouble]];
}

- (double)netSalaryUntilNowAsDouble {
	if (self.hourlyWage <= 0) {
		return (double)0.0;
	}

	double hoursWorked = [self netMinutesWorkedUntilNowAsDouble] / 60.0;
	double hourlyWage = [self.hourlyWage doubleValue];

	double returnValue = hoursWorked * hourlyWage;
	return returnValue;
}

- (double)overTimeMinutesAsDouble {
	double minutesWorked = [self netMinutesAsDouble];
	AXSettingsManager *settingsController = [AXSettingsManager new];
	NSInteger hoursPerDay =  [settingsController getHoursPerDay];
	double targetMinutesWorked = [[NSNumber numberWithInteger:hoursPerDay] doubleValue] * (double)60;
	double minutesOvertime = minutesWorked - targetMinutesWorked;

	return minutesOvertime;
}

- (double)overTimeHoursAsDouble {
	return [self overTimeMinutesAsDouble] / (double)60.0;
}

- (double)minutesPausedAsDouble {
	if ((self.checkInTime == nil) ||  (self.checkInTime != nil && self.checkOutTime == nil) || (self.checkInTime == nil && self.checkOutTime == nil)) {
		return (double)0.0;
	} else {
		NSTimeInterval distanceBetweenDates = 0;
		for (Pause *pause in self.pauses) {
			if (pause.startTime != nil && pause.endTime != nil) {
				distanceBetweenDates = distanceBetweenDates + [pause secondsPaused];
			}
		}
		return distanceBetweenDates / (double)60.0;
	}
}

- (double)minutesPausedAsDoubleNotZeroed {
    if ((self.checkInTime == nil) || (self.checkInTime == nil && self.checkOutTime == nil)) {
        return (double)0.0;
    } else {
        NSTimeInterval distanceBetweenDates = 0;
        for (Pause *pause in self.pauses) {
            if (pause.startTime != nil && pause.endTime != nil) {
                distanceBetweenDates = distanceBetweenDates + [pause secondsPausedNotZeroed];
            }
        }
        return distanceBetweenDates / (double)60.0;
    }
}

- (double)hoursPausedAsDouble {
	return [self minutesPausedAsDouble] / (double)60.0;
}

- (NSNumber *)netHoursAsNumber {
	NSNumber *netHours = [decimalNumberFormatter numberFromString:[self netHoursAsDecimalStringWithoutH] ];

	return netHours;
}

- (double)salaryForEntireDayAsDouble {
	if (self.hourlyWage <= 0) {
		return (double)0.0;
	}

	double hoursWorked = [[self netHoursAsNumber] doubleValue];
	double hourlyWage = [self.hourlyWage doubleValue];

	double returnValue = hoursWorked * hourlyWage;
	return returnValue;
}

- (double)netMinutesAsDouble {
	return [self grossMinutesToNetMinutes:[self minutesWorkedAsDouble]];
}

- (double)netHoursAsDouble {
	double netHours = [self netMinutesAsDouble] / (double)60.0;
	// rounding einheitlich für alle hier, somit hat das runden mit dem numberformatter später keine auswirkungen mehr
	double returnValue = round(100 * netHours) / 100;

	return returnValue;
}

#pragma mark - pause stuff
- (NSArray *)sortedPauses {
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];

	NSArray *sortDescriptorArray = [NSArray arrayWithObjects:sortDescriptor, nil];
	NSArray *returnArray = [self.pauses sortedArrayUsingDescriptors:sortDescriptorArray];

	return returnArray;
}

- (Pause *)getLastSortedPause {
	NSUInteger numberOfPause = self.pauses.count;

	if (numberOfPause == 0) {
		return nil;
	}
	NSInteger lastObjectIndex = self.pauses.count - 1;
	return [self sortedPauses][lastObjectIndex];
}

- (Pause *)getFirstSortedPause {
	NSUInteger numberOfPause = self.pauses.count;

	if (numberOfPause == 0) {
		return nil;
	}
	return [self sortedPauses][0];
}

#pragma mark - display values
- (NSString *)pausedTimeAsDecimalString {
	double hoursPaused = [self hoursPausedAsDouble];

	return [NSString stringWithFormat:@"%@ %@", [decimalNumberFormatter stringFromNumber:[NSNumber numberWithDouble:hoursPaused]], NSLS_HOUR_SHORT];
}

- (NSString *)pausedTimeAsDecimalStringWithoutH {
	double hoursPaused = [self hoursPausedAsDouble];

	return [NSString stringWithFormat:@"%@", [decimalNumberFormatter stringFromNumber:[NSNumber numberWithDouble:hoursPaused]]];
}

- (NSString *)netHoursAsDecimalString {
	double hoursWorked = [self netHoursAsDouble];
	NSString *formattedNumber = [[NSNumber numberWithDouble:hoursWorked] timeFormatted];

	return formattedNumber;
}

- (NSString *)netHoursAsDecimalStringWithoutH {
	double hoursWorked = [self netHoursAsDouble];
	NSString *formattedNumber = [NSString stringWithFormat:@"%@", [decimalNumberFormatter stringFromNumber:[NSNumber numberWithDouble:hoursWorked]]];

	return formattedNumber;
}

- (NSString *)overTimeAsDecimalString {
	AXSettingsManager *settingsController = [[AXSettingsManager alloc] init];

	if ([settingsController getHoursPerDay] == 0) {
		return NULLSTRING;
	}
	double hoursOvertimed = [self overTimeHoursAsDouble];

	return [NSString stringWithFormat:@"%@ %@", [decimalNumberFormatter stringFromNumber:[NSNumber numberWithDouble:hoursOvertimed]], NSLS_HOUR_SHORT];;
}

- (NSString *)overTimeAsDecimalStringWithoutH {
	AXSettingsManager *settingsController = [[AXSettingsManager alloc] init];

	if ([settingsController getHoursPerDay] == 0) {
		return NULLSTRING;
	}
	double hoursOvertimed = [self overTimeHoursAsDouble];

	return [NSString stringWithFormat:@"%@", [decimalNumberFormatter stringFromNumber:[NSNumber numberWithDouble:hoursOvertimed]] ];;
}

- (NSString *)salaryDisplayValue {
	AXSettingsManager *settingsController = [AXSettingsManager new];

	NSString *currencyString = [settingsController getCurrencyIso];
	NSString *returnString = [NSString stringWithFormat:@"%@ %@", [decimalNumberFormatter stringFromNumber:[self salary]], currencyString];

	return returnString;
}

- (NSString *)salaryDisplayValueWithoutCurrency {
	NSString *returnString = [NSString stringWithFormat:@"%@", [decimalNumberFormatter stringFromNumber:[self salary]]];

	return returnString;
}

- (NSString *)salaryDisplayValueForCounter {
	return [decimalNumberFormatter stringFromNumber:[self salary]];
}

- (NSString *)salaryUntilNowDisplayValue {
	return [decimalNumberFormatter stringFromNumber:[self salaryUntilNow]];
}

- (NSString *)netSalaryUntilNowDisplayValue {
	return [decimalNumberFormatter stringFromNumber:[NSNumber numberWithDouble:[self netSalaryUntilNowAsDouble]]];
}

- (NSString *)grossTimeAsDecimalString {
	double hoursWorked = [self minutesWorkedAsDouble] / (double)60.0;

	return [[NSNumber numberWithDouble:hoursWorked] timeFormatted];
}

- (NSString *)hourlyWageAsDecimalString {
	return [decimalNumberFormatter stringFromNumber:self.hourlyWage];
}

- (NSString *)secondsWorkedUntilNowDisplayValue {
	return [self.secondsWorkedUntilNow numberAsSecondsToCountdownString];
}

#pragma mark - nsnumber values
- (NSNumber *)secondsWorkedUntilNow {
	return [NSNumber numberWithDouble:[self secondsWorkedUntilNowAsDouble]];
}

- (NSNumber *)minutesWorkedUntilNow {
	return [NSNumber numberWithDouble:[self minutesWorkedUntilNowAsDouble]];
}

- (NSNumber *)salary {
	return [NSNumber numberWithDouble:[self salaryForEntireDayAsDouble]];
}

- (NSNumber *)salaryUntilNow {
	return [NSNumber numberWithDouble:[self salaryUntilNowAsDouble]];
}

- (NSNumber *)secondsWorked {
	return [NSNumber numberWithDouble:[self secondsWorkedAsDouble]];
}

- (NSNumber *)minutesWorked {
	return [NSNumber numberWithDouble:[self minutesWorkedAsDouble]];
}

- (NSNumber *)overTimeMinutes {
	return [NSNumber numberWithDouble:[self overTimeMinutesAsDouble]];
}

- (NSNumber *)minutesPaused {
	return [NSNumber numberWithDouble:[self minutesPausedAsDouble]];
}

- (NSNumber *)netMinutes {
	return [NSNumber numberWithDouble:[self netMinutesAsDouble]];
}

@end
