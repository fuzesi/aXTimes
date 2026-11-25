////
////  DayEntry+ObjectiveC.h
////  aXTimes
////
////  Created by Christopher Füseschi on 09/11/2016.
////  Copyright © 2016 aXimilate. All rights reserved.
////
//
//#import "DDCalendarEventProtocol.h"
//#import "DayEntry+CoreDataClass.h"
//
//@class DayEntry;
//
//NS_ASSUME_NONNULL_BEGIN
//
//@interface DayEntry (ObjectiveC)
//
//- (void)setCheckInTime:(NSDate *)checkInTime;
//- (void)setCheckOutTime:(nullable NSDate *)checkOutTime;
//
//- (NSString *)dayKey;
//
//- (DayEntry *)deepCopyToTargetDate:(NSDate *)date;
//- (void)normalize;
//
//#pragma mark - main getters
//
//- (double)minutesToNetMinutes:(double)minutes;
//
//- (double)minutesWorkedAsDouble;
//- (double)hoursWorkedAsDouble;
//
//- (double)netMinutesAsDouble;
//- (double)netHoursAsDouble;
//
//- (NSDecimalNumber *)secondsWorkedUntil:(NSDate *)date;
//
//- (double)salaryUntilNowAsDouble;
//- (NSDecimalNumber *)salaryWithMinutesWorked:(NSDecimalNumber *)minutes;
//
//- (double)minutesWorkedUntilNowAsDouble;
//- (double)netMinutesWorkedUntilNowAsDouble;
//
//- (double)minutesPausedAsDouble;
//- (double)minutesPausedAsDoubleNotZeroed;
//- (double)hoursPausedAsDouble;
//
//- (double)salaryForEntireDayAsDouble;
//
//- (NSNumber *)getHourlyWage;
//
//#pragma mark - pause stuff
//- (NSArray *)sortedPauses;
//- (Pause *)getLastSortedPause;
//- (Pause *)getFirstSortedPause;
//
//#pragma mark - display values
//
//- (NSString *)salaryUntilNowDisplayValue;
//- (NSString *)salaryDisplayValue;
//- (NSString *)salaryDisplayValueForCounter;
//- (NSString *)hourlyWageAsDecimalString;
//- (NSString *)secondsWorkedUntilNowDisplayValue;
//
//#pragma mark - nsnumber values
//- (NSNumber *)minutesWorkedUntilNow;
//- (NSNumber *)secondsWorkedUntilNow;
//
//- (NSNumber *)salary;
//
//- (NSNumber *)secondsWorked;
//- (NSNumber *)minutesWorked;
//
//- (NSNumber *)minutesPaused;
//- (NSNumber *)netMinutes;
//
//
//#pragma mark - misc
//
//- (NSString *)timeRangeDisplayValueForTargetDate:(NSDate *)date;
//- (NSString *)checkInTimeDisplayValueForTargetDate:(NSDate *)date;
//- (NSString *)checkOutTimeDisplayValueForTargetDate:(NSDate *)date;
//
//- (NSString *)pauseTimesDisplayValue;
//
//#pragma mark - DDCalendarEventProtocol
//
//- (void)setDateBegin:(NSDate *)dateBegin;
//- (void)setDateEnd:(NSDate *)dateEnd;
//- (void)setTitle:(NSString *)title;
//- (NSString *)title;
//- (NSDate *)dateBegin;
//- (NSDate *)dateEnd;
//
//@end
//
//NS_ASSUME_NONNULL_END
//
