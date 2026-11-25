////
////  DayEntry+ObjectiveC.m
////  aXTimes
////
////  Created by Christopher Füseschi on 09/11/2016.
////  Copyright © 2016 aXimilate. All rights reserved.
////
//
//#import "DayEntry+ObjectiveC.h"
//
//#import "SettingsManager.h"
//#import "NSDate+AXNSDateCategory.h"
//#import "NSNumber+AXNSNumberCategory.h"
//#import "NSDateFormatter+AXDateFormatters.h"
//
//static NSNumberFormatter *decimalNumberFormatter;
//
//@implementation DayEntry (ObjectiveC)
//
//+ (void)load {
//    decimalNumberFormatter = [NSNumberFormatter new];
//    [decimalNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//    [decimalNumberFormatter setMaximumFractionDigits:2];
//    [decimalNumberFormatter setMinimumFractionDigits:2];
//    [decimalNumberFormatter setRoundingIncrement:[NSNumber numberWithDouble:0.01]];
//    [decimalNumberFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
//}
//
//- (void)normalize {
//    if (self.checkInTime) {
//        self.checkInTime = [self.checkInTime truncateSeconds];
//    }
//    
//    if (self.checkOutTime) {
//        self.checkOutTime = [self.checkOutTime truncateSeconds];
//    }
//    
//    for (Pause *pause in [self pauses].allObjects) {
//        [pause normalize];
//    }
//}
//
//- (DayEntry *)deepCopyToTargetDate:(NSDate *)date {
//    DayEntry *dayEntry = [[AXDataStore sharedInstance] createDayEntry];
//    
//    dayEntry.checkInTime = [self.checkInTime updateDayMonthYearComponentWithDate:date];
//    dayEntry.checkInTimeZone = self.checkInTimeZone;
//    
//    NSTimeInterval difference = [self.checkOutTime timeIntervalSinceDate:self.checkInTime];
//    dayEntry.checkOutTime = [NSDate dateWithTimeInterval:difference
//                                               sinceDate:dayEntry.checkInTime];
//    dayEntry.checkOutTimeZone = self.checkOutTimeZone;
//    
//    dayEntry.comment = self.comment;
//    
//    dayEntry.hourlyWage = self.hourlyWage;
//    dayEntry.creationDate = [NSDate date];
//    
//    dayEntry.project = self.project;
//    
//    for (Pause *pause in self.pauses) {
//        difference = [pause.startTime timeIntervalSinceDate:self.checkInTime];
//        Pause *newPause = [[AXDataStore sharedInstance] createPauseWithContext:dayEntry.managedObjectContext];
//        newPause.startTime = [NSDate dateWithTimeInterval:difference
//                                                sinceDate:dayEntry.checkInTime];
//        newPause.startTimeZone = pause.startTimeZone;
//        
//        difference = [pause.endTime timeIntervalSinceDate:pause.startTime];
//        newPause.endTime = [NSDate dateWithTimeInterval:difference
//                                              sinceDate:newPause.startTime];
//        newPause.endTimeZone = pause.endTimeZone;
//        [dayEntry addPausesObject:newPause];
//    }
//    return dayEntry;
//}
//
//#pragma mark - setters
//
//- (void)setCheckInTime:(NSDate *)checkInTime {
//    [self willChangeValueForKey:@"checkInTime"];
//    [self setPrimitiveValue:checkInTime forKey:@"checkInTime"];
//    [self didChangeValueForKey:@"checkInTime"];
//    
//    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
//    NSString *systemTimeZoneName = [timeZone name];
//    [self setCheckInTimeZone:systemTimeZoneName];
//}
//
//- (void)setCheckOutTime:(nullable NSDate *)checkOutTime {
//    [self willChangeValueForKey:@"checkOutTime"];
//    [self setPrimitiveValue:checkOutTime forKey:@"checkOutTime"];
//    [self didChangeValueForKey:@"checkOutTime"];
//    
//    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
//    NSString *systemTimeZoneName = [timeZone name];
//    [self setCheckOutTimeZone:systemTimeZoneName];
//}
//
//- (NSString *)dayKey {
//    static NSDateFormatter *_specialFormatting;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _specialFormatting = [NSDateFormatter new];
//        _specialFormatting.dateFormat = @"yyyyMMdd";
//    });
//    
//    return [_specialFormatting stringFromDate:self.checkInTime];
//}
//
//- (NSNumber *)getHourlyWage {
//    if ([self.project isBasic]) {
//        return self.hourlyWage;
//    } else {
//        return [self.project getHourlyWage];
//    }
//}
//
//- (double)minutesToNetMinutes:(double)minutes {
//    Project *project = self.project;
//    
//    NSUInteger timeUnitInMinutes = [project getTimeUnit];
//    double timeUnitsWorked = minutes / timeUnitInMinutes;
//    RoundingBehaviour currentRoundingBehaviour = [project getRoundingBehaviour];
//    double returnValue = 0.0;
//    
//    switch (currentRoundingBehaviour) {
//        case RoundingBehaviourDefault : {
//            double tempTimeUnitsWorked = floor(timeUnitsWorked);
//            
//            double moduloRemainder = timeUnitsWorked - tempTimeUnitsWorked;
//            //			if (timeUnitsWorked >= 1) {
//            //				moduloRemainder = fmod(timeUnitsWorked, tempTimeUnitsWorked);
//            //			} else {
//            //				moduloRemainder = timeUnitsWorked;
//            //			}
//            
//            if (moduloRemainder >= 0.5) {
//                timeUnitsWorked = tempTimeUnitsWorked + 1;
//            } else {
//                timeUnitsWorked = tempTimeUnitsWorked;
//            }
//            returnValue = timeUnitsWorked * timeUnitInMinutes;
//            break;
//        }
//        case RoundingBehaviourRoundDown :
//            returnValue = floor(timeUnitsWorked) * timeUnitInMinutes;
//            break;
//        case RoundingBehaviourRoundUp :
//            returnValue = ceil(timeUnitsWorked) * timeUnitInMinutes;
//            break;
//        default :
//            break;
//    }
//    
//    return returnValue;
//}
//
//#pragma mark - main getters
//
//- (double)minutesWorkedAsDouble {
//    double minutesWorked = ([self secondsWorkedAsDouble] / (double)60.0);
//    
//    return minutesWorked;
//}
//
//- (double)hoursWorkedAsDouble {
//    double hoursWorked = [self minutesWorkedAsDouble] / (double)60.0;
//    
//    return hoursWorked;
//}
//
//- (double)netMinutesAsDouble {
//    return [self minutesToNetMinutes:[self minutesWorkedAsDouble]];
//}
//
//- (double)netHoursAsDouble {
//    double netHours = [self netMinutesAsDouble] / (double)60.0;
//    // rounding einheitlich für alle hier, somit hat das runden mit dem numberformatter später keine auswirkungen mehr
//    double returnValue = round(100 * netHours) / 100;
//    
//    return returnValue;
//}
//
//- (double)secondsWorkedAsDouble {
//    if ((self.checkInTime == nil) || (self.checkInTime != nil && self.checkOutTime == nil) || (self.checkInTime == nil && self.checkOutTime == nil)) {
//        return (double)0.0;
//    } else {
//        NSDate *tempCheckin = [self.checkInTime truncateSeconds];
//        NSDate *tempCheckout = [self.checkOutTime truncateSeconds];
//        
//        NSTimeInterval distanceBetweenDates = [tempCheckout timeIntervalSinceDate:tempCheckin];
//        for (Pause *pause in self.pauses) {
//            if (pause.startTime != nil && pause.endTime != nil) {
//                distanceBetweenDates = distanceBetweenDates -  [pause secondsPaused];
//            }
//        }
//        return distanceBetweenDates;
//    }
//}
//
//- (NSDecimalNumber *)secondsWorkedUntil:(NSDate *)date {
//    if (self.checkInTime == nil) {
//        return [NSDecimalNumber zero];
//    } else {
//        NSTimeInterval distanceBetweenDates = [date timeIntervalSinceDate:self.checkInTime];
//        NSInteger lastObjectIndex = [self.pauses count] - 1;
//        for (int i = 0; i < [self.pauses count]; i++) {
//            Pause *pause = [self sortedPauses][i];
//            
//            if (pause.startTime != nil && pause.endTime != nil) {
//                distanceBetweenDates -= [pause.endTime timeIntervalSinceDate:pause.startTime];
//            } else if (i == lastObjectIndex) {
//                if (pause.startTime != nil) {
//                    distanceBetweenDates -= [date timeIntervalSinceDate:pause.startTime];
//                }
//            }
//        }
//        return [[NSDecimalNumber alloc] initWithDouble:distanceBetweenDates];
//    }
//}
//
//- (double)secondsWorkedUntilNowAsDouble {
//    return [[self secondsWorkedUntil:[NSDate date]] doubleValue];
//}
//
//- (double)minutesWorkedUntilNowAsDouble {
//    double returnValue = ([self secondsWorkedUntilNowAsDouble] / (double)60.0);
//    
//    return returnValue;
//}
//
//- (double)salaryUntilNowAsDouble {
//    NSDecimalNumber *input = [[NSDecimalNumber alloc] initWithDouble:[self minutesWorkedUntilNowAsDouble]];
//    return [[self salaryWithMinutesWorked:input] doubleValue];
//}
//
//- (NSDecimalNumber *)salaryWithMinutesWorked:(NSDecimalNumber *)minutes {
//    NSDecimalNumber *hourlyWage = [NSDecimalNumber decimalNumberWithDecimal:[[self getHourlyWage] decimalValue]];
//    if ([[NSDecimalNumber zero] compare:hourlyWage] != NSOrderedAscending) {
//        return [NSDecimalNumber zero];
//    }
//    
//    NSDecimalNumber *hoursWorked = [minutes
//                                     decimalNumberByDividingBy:[NSDecimalNumber sixty]];
//    
//    NSDecimalNumber *returnValue = [hoursWorked
//                                    decimalNumberByMultiplyingBy:hourlyWage];
//    return returnValue;
//}
//
//- (double)netMinutesWorkedUntilNowAsDouble {
//    return [self minutesToNetMinutes:[self minutesWorkedUntilNowAsDouble]];
//}
//
//- (double)minutesPausedAsDouble {
//    if ((self.checkInTime == nil) ||  (self.checkInTime != nil && self.checkOutTime == nil) || (self.checkInTime == nil && self.checkOutTime == nil)) {
//        return (double)0.0;
//    } else {
//        NSTimeInterval distanceBetweenDates = 0;
//        for (Pause *pause in self.pauses) {
//            if (pause.startTime != nil && pause.endTime != nil) {
//                distanceBetweenDates = distanceBetweenDates + [pause secondsPaused];
//            }
//        }
//        return distanceBetweenDates / (double)60.0;
//    }
//}
//
//- (double)minutesPausedAsDoubleNotZeroed {
//    if ((self.checkInTime == nil) || (self.checkInTime == nil && self.checkOutTime == nil)) {
//        return (double)0.0;
//    } else {
//        NSTimeInterval distanceBetweenDates = 0;
//        for (Pause *pause in self.pauses) {
//            if (pause.startTime != nil && pause.endTime != nil) {
//                distanceBetweenDates = distanceBetweenDates + [pause secondsPausedNotZeroed];
//            }
//        }
//        return distanceBetweenDates / (double)60.0;
//    }
//}
//
//- (double)hoursPausedAsDouble {
//    return [self minutesPausedAsDouble] / (double)60.0;
//}
//
//- (NSNumber *)netHoursAsNumber {
//    NSNumber *netHours = [decimalNumberFormatter numberFromString:[self netHoursAsDecimalStringWithoutH] ];
//    
//    return netHours;
//}
//
//- (double)salaryForEntireDayAsDouble {
//    if ([[self getHourlyWage] doubleValue] <= 0) {
//        return (double)0.0;
//    }
//    
//    double hoursWorked = [[self netHoursAsNumber] doubleValue];
//    double hourlyWage = [[self getHourlyWage] doubleValue];
//    
//    double returnValue = hoursWorked * hourlyWage;
//    return returnValue;
//}
//
//#pragma mark - pause stuff
//- (NSArray *)sortedPauses {
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
//    
//    NSArray *sortDescriptorArray = [NSArray arrayWithObjects:sortDescriptor, nil];
//    NSArray *returnArray = [self.pauses sortedArrayUsingDescriptors:sortDescriptorArray];
//    
//    return returnArray;
//}
//
//- (Pause *)getLastSortedPause {
//    NSUInteger numberOfPause = self.pauses.count;
//    
//    if (numberOfPause == 0) {
//        return nil;
//    }
//    NSInteger lastObjectIndex = self.pauses.count - 1;
//    return [self sortedPauses][lastObjectIndex];
//}
//
//- (Pause *)getFirstSortedPause {
//    NSUInteger numberOfPause = self.pauses.count;
//    
//    if (numberOfPause == 0) {
//        return nil;
//    }
//    return [self sortedPauses][0];
//}
//
//#pragma mark - display values
//
//- (NSString *)netHoursAsDecimalStringWithoutH {
//    double hoursWorked = [self netHoursAsDouble];
//    NSString *formattedNumber = [NSString stringWithFormat:@"%@", [decimalNumberFormatter stringFromNumber:[NSNumber numberWithDouble:hoursWorked]]];
//    
//    return formattedNumber;
//}
//
//- (NSString *)salaryDisplayValue {
//    NSString *currencyString = [SettingsManager getCurrencyIso];
//    NSString *returnString = [NSString stringWithFormat:@"%@ %@", [decimalNumberFormatter stringFromNumber:[self salary]], currencyString];
//    
//    return returnString;
//}
//
//- (NSString *)salaryDisplayValueForCounter {
//    return [decimalNumberFormatter stringFromNumber:[self salary]];
//}
//
//- (NSString *)salaryUntilNowDisplayValue {
//    return [decimalNumberFormatter stringFromNumber:[self salaryUntilNow]];
//}
//
//- (NSString *)hourlyWageAsDecimalString {
//    return [decimalNumberFormatter stringFromNumber:[self getHourlyWage]];
//}
//
//- (NSString *)secondsWorkedUntilNowDisplayValue {
//    return [self.secondsWorkedUntilNow numberAsSecondsToCountdownString];
//}
//
//#pragma mark - nsnumber values
//- (NSNumber *)secondsWorkedUntilNow {
//    return [NSNumber numberWithDouble:[self secondsWorkedUntilNowAsDouble]];
//}
//
//- (NSNumber *)minutesWorkedUntilNow {
//    return [NSNumber numberWithDouble:[self minutesWorkedUntilNowAsDouble]];
//}
//
//- (NSNumber *)salary {
//    return [NSNumber numberWithDouble:[self salaryForEntireDayAsDouble]];
//}
//
//- (NSNumber *)salaryUntilNow {
//    return [NSNumber numberWithDouble:[self salaryUntilNowAsDouble]];
//}
//
//- (NSNumber *)secondsWorked {
//    return [NSNumber numberWithDouble:[self secondsWorkedAsDouble]];
//}
//
//- (NSNumber *)minutesWorked {
//    return [NSNumber numberWithDouble:[self minutesWorkedAsDouble]];
//}
//
//- (NSNumber *)minutesPaused {
//    return [NSNumber numberWithDouble:[self minutesPausedAsDouble]];
//}
//
//- (NSNumber *)netMinutes {
//    return [NSNumber numberWithDouble:[self netMinutesAsDouble]];
//}
//
//#pragma mark - misc
//
//- (NSString *)timeRangeDisplayValueForTargetDate:(NSDate *)date {
//    NSString *timeRange = @"";
//    
//    timeRange = [NSString stringWithFormat:@"%@ - ",
//                 [self checkInTimeDisplayValueForTargetDate:date]];
//    
//    if (self.checkOutTime != nil) {
//        timeRange = [NSString stringWithFormat:@"%@%@",
//                     timeRange,
//                     [self checkOutTimeDisplayValueForTargetDate:date]];
//        
//    }
//    
//    return timeRange;
//}
//
//- (NSString *)checkInTimeDisplayValueForTargetDate:(NSDate *)date {
//    NSString *value = @"";
//    if (self.checkInTime != nil) {
//        NSDateFormatter *dateFormatter = nil;
//        if ([self.checkInTime isSameDay:date
//               withReceiverTimeZoneName:self.checkInTimeZone
//                   andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
//            dateFormatter = [NSDateFormatter formatter_HH_mm_Static:NO];
//        } else if ([self.checkInTime
//                    isSameMonth:date
//                    withReceiverTimeZoneName:self.checkInTimeZone
//                    andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
//            dateFormatter = [NSDateFormatter formatter_HH_mm_d_M_Static:NO];
//        } else {
//            dateFormatter = [NSDateFormatter formatter_HH_mm_d_M_yy_Static:NO];
//        }
//        [dateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:self.checkInTimeZone]];
//        
//        value = [dateFormatter stringFromDate:self.checkInTime];
//    }
//    return value;
//}
//
//- (NSString *)checkOutTimeDisplayValueForTargetDate:(NSDate *)date {
//    NSString *value = @"";
//    if (self.checkOutTime != nil) {
//        NSDateFormatter *dateFormatter = nil;
//        if ([self.checkOutTime isSameDay:date
//                withReceiverTimeZoneName:self.checkOutTimeZone
//                    andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
//            dateFormatter = [NSDateFormatter formatter_HH_mm_Static:NO];
//        } else if ([self.checkOutTime isSameMonth:date
//                         withReceiverTimeZoneName:self.checkOutTimeZone
//                             andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
//            dateFormatter = [NSDateFormatter formatter_HH_mm_d_M_Static:NO];
//        } else {
//            dateFormatter = [NSDateFormatter formatter_HH_mm_d_M_yy_Static:NO];
//        }
//        [dateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:self.checkOutTimeZone]];
//        
//        value = [dateFormatter stringFromDate:self.checkOutTime];
//    }
//    return value;
//}
//
//- (NSString *)pauseTimesDisplayValue {
//    NSString *pauseTimes = @"";
//    
//    for (int i = 0; i < [self.pauses count]; i++) {
//        Pause *pause = [self sortedPauses][i];
//        pauseTimes = [pauseTimes stringByAppendingString:[pause timeRangeString:self.checkInTime]];
//        if (i != ([self.pauses count] - 1)) {
//            pauseTimes = [pauseTimes stringByAppendingString:@"\n"];
//        }
//    }
//    
//    return pauseTimes;
//}
//
//#pragma mark - DDCalendarEventProtocol
//
//- (void)setDateBegin:(NSDate *)dateBegin {
//    //do not do anything
//}
//
//- (void)setDateEnd:(NSDate *)dateEnd {
//    //do not do anything
//}
//
//- (void)setTitle:(NSString *)title {
//    //do not do anything
//}
//
//- (NSString *)title {
//    if (self.project) {
//        return self.project.name;
//    }
//    return  [self timeRangeDisplayValueForTargetDate:self.checkInTime];
//}
//
//- (NSDate *)dateBegin {
//    return self.checkInTime;
//}
//
//- (NSDate *)dateEnd {
//    if (!self.checkOutTime) {
//        return [NSDate date];
//    }
//    return self.checkOutTime;
//}
//
//@end
