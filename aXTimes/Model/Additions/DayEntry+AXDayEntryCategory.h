//
//  DayEntry+AXDayEntryCategory.h
//  aXTimes
//
//  Created by fuesec on 5/19/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "DayEntry.h"

@interface DayEntry (AXDayEntryCategory)

+ (void)setDecimalSeperator:(NSString *)separator;
+ (NSString *)getDecimalSeperator;
+ (void)setUsesGroupingSeparator:(BOOL)usingIt;

- (DayEntry * )deepCopyWithDate:(NSDate *)date;

- (double)grossMinutesToNetMinutes:(double)grossMinutes;

#pragma mark - main getters
- (double)minutesWorkedAsDouble;
- (double)secondsWorkedAsDouble;

- (double)secondsWorkedUntilNowAsDouble;
- (double)minutesWorkedUntilNowAsDouble;
- (double)netMinutesWorkedUntilNowAsDouble;

- (double)salaryUntilNowAsDouble;
- (NSString *)netSalaryUntilNowDisplayValue;
- (double)netSalaryUntilNowAsDouble;

- (double)netMinutesAsDouble;
- (double)netHoursAsDouble;
- (NSNumber *)netHoursAsNumber;

- (double)overTimeMinutesAsDouble;
- (double)overTimeHoursAsDouble;

- (double)minutesPausedAsDouble;
- (double)minutesPausedAsDoubleNotZeroed;
- (double)hoursPausedAsDouble;

- (double)salaryForEntireDayAsDouble;

#pragma mark - pause stuff
- (NSArray *)sortedPauses;
- (Pause *)getLastSortedPause;
- (Pause *)getFirstSortedPause;

#pragma mark - display values
- (NSString *)pausedTimeAsDecimalString;
- (NSString *)pausedTimeAsDecimalStringWithoutH;
- (NSString *)netHoursAsDecimalString;
- (NSString *)netHoursAsDecimalStringWithoutH;
- (NSString *)overTimeAsDecimalString;
- (NSString *)overTimeAsDecimalStringWithoutH;

- (NSString *)grossTimeAsDecimalString;

- (NSString *)salaryUntilNowDisplayValue;
- (NSString *)salaryDisplayValue;
- (NSString *)salaryDisplayValueWithoutCurrency;
- (NSString *)salaryDisplayValueForCounter;
- (NSString *)hourlyWageAsDecimalString;
- (NSString *)secondsWorkedUntilNowDisplayValue;

#pragma mark - nsnumber values
- (NSNumber *)minutesWorkedUntilNow;
- (NSNumber *)secondsWorkedUntilNow;

- (NSNumber *)salary;
- (NSNumber *)salaryUntilNow;

- (NSNumber *)secondsWorked;
- (NSNumber *)minutesWorked;

- (NSNumber *)minutesPaused;
- (NSNumber *)overTimeMinutes;
- (NSNumber *)netMinutes;

@end
