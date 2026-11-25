//
//  AXCalculation.m
//  aXTimes
//
//  Created by fuesec on 5/27/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXCalculation.h"

#import "NSCalendar+AXNSCalendar.h"
#import "NSString+AXNSStringCategory.h"
#import "NSDate+AXNSDateCategory.h"
#import "NSNumber+AXNSNumberCategory.h"
#import "NSCalendar+AXNSCalendarCategory.h"

#import "AXUtility.h"


@interface AXCalculation ()

@end

@implementation AXCalculation

#pragma mark - public calculations methods

- (AXSummaryCalculationResult *)calculationResultForFetchedEntries:(NSArray<DayEntry *> *)fetchedDayEntries
                                      forDayTypesCalculationResult:(AXDayTypesCalculationResult *)dayTypesCalculationResult
                                                        andProject:(Project *)project {
    //    Summary:
    //    - days Off mit Symbol
    //    - Public holidays mit Symbol
    //    - Vacation mit Symbol
    //    - Planned Working Time (=Anzahl Tage im Jahr minus days off minus vacation minus Public holidays minus sickness days)
    //    - Time Worked net
    //    - Overtime
    //    - average Time per Day
    //    - Sickness mit Symbol
    //    - Income
    
    AXSummaryCalculationResult *calculationResult;
    
    calculationResult = [[AXSummaryCalculationResult alloc] initWithDayTypesCalculationResult:dayTypesCalculationResult];

    NSNumber *targetDaysWholeTimeRangeNoNumber = dayTypesCalculationResult.limitedRangeTargetDays;
    NSNumber *targetDaysWholeTimeRangeYesNumber = dayTypesCalculationResult.wholeRangeTargetDays;
    
    NSNumber *hoursPerDay = [[SettingsManager new] hoursPerDay];
    
    NSNumber *targetTimeInHoursNumber = nil;
    if (hoursPerDay.isGreaterZero) {
        targetTimeInHoursNumber =  [[NSDecimalNumber
                                     decimalNumberWithDecimal:targetDaysWholeTimeRangeYesNumber.decimalValue]
                                    decimalNumberByMultiplyingBy:[NSDecimalNumber
                                                                  decimalNumberWithDecimal:hoursPerDay.decimalValue]];
    }
    
    if ([fetchedDayEntries count] == 0) {
        [calculationResult createDisplayInformation];
        return calculationResult;
        // EXIT
    }
    
    NSNumber *netTimeHoursNumber = [DayEntry netTimeForArray:fetchedDayEntries];
    NSNumber *pauseTimeHoursNumber = [DayEntry pauseTimeForArray:fetchedDayEntries];

    NSNumber *netTimeDaysNumber = nil;
    
    NSNumber *overTimeHoursNumber = nil;
    NSNumber *overTimeDaysNumber = nil;
    
    if (hoursPerDay.isGreaterZero) {
        // diese Sachen können nur berechnet werden, wenn hoursPerDay gesetzt worden ist
        
        netTimeDaysNumber = [netTimeHoursNumber hoursToDaysWithHoursPerDay:[NSDecimalNumber decimalNumberWithDecimal:hoursPerDay.decimalValue]];
        if (netTimeDaysNumber) {
            overTimeHoursNumber = [AXCalculation
                                   overtimeHoursWithTargetWorkingDays:[targetDaysWholeTimeRangeNoNumber decimalNumber]
                                   withHoursPerDay:[NSDecimalNumber decimalNumberWithDecimal:hoursPerDay.decimalValue]
                                   withNetTimeHours:[netTimeHoursNumber decimalNumber]];
            overTimeDaysNumber = [overTimeHoursNumber hoursToDaysWithHoursPerDay:[NSDecimalNumber decimalNumberWithDecimal:hoursPerDay.decimalValue]];
        }
    }
    
    NSNumber *averageTimeNumber = nil;
    
    averageTimeNumber = [AXCalculation
                         averageHoursPerDayWithDays:[targetDaysWholeTimeRangeNoNumber decimalNumber]
                         hours:[netTimeHoursNumber decimalNumber]];
    
    
    NSNumber *salaryNumber = [DayEntry incomeForArray:fetchedDayEntries];
    
    calculationResult.targetTimeInHours = targetTimeInHoursNumber;
    calculationResult.netWorkingTimeHours = netTimeHoursNumber;
    calculationResult.netWorkingTimeDays = netTimeDaysNumber;
    calculationResult.pauseTimeHours = pauseTimeHoursNumber;
    calculationResult.overtimeHours = overTimeHoursNumber;
    calculationResult.overtimeDays = overTimeDaysNumber;
    calculationResult.averageTimePerDay = averageTimeNumber;
    calculationResult.income = salaryNumber;
    
    [calculationResult createDisplayInformation];
    return calculationResult;
}

- (AXDayTypesCalculationResult *)getTargetWorkingDaysForTimeUnit:(SummaryUnit)unit
                                                         andDate:(NSDate *)date
                                                 andLastDayEntry:(DayEntry *)entry {
    
    NSCalendar *calendar = [NSCalendar defaultCalendar_Static:YES];
    AXDayTypesCalculationResult *result = [AXDayTypesCalculationResult new];
    
    if (unit == SummaryUnitYear) {
        NSDateComponents *components = [calendar components:CALENDARUNITCOMPONENTS fromDate:date];

        [components setHour:0];
        [components setMinute:0];
        [components setSecond:0];
        [components setDay:1];

        NSMutableArray *resultsArray = [NSMutableArray new];

        for (int i = 1; i <= 12; i++) {
            [components setMonth:i];
            
            NSDate *loopDate = [calendar dateFromComponents:components];
            //TODO optimize
            NSMutableArray *fetchedDayEntries = [[NSMutableArray alloc] initWithArray:[[AXDataStore sharedInstance] getListDayEntryForMonth:loopDate]];
            
            DayEntry *loopEntry = nil;
            BOOL relevanceForYearOvertime = NO;
            if (fetchedDayEntries &&
                [fetchedDayEntries count] != 0) {
                loopEntry = fetchedDayEntries[[fetchedDayEntries count] - 1];
                relevanceForYearOvertime = YES;
            }
            
            AXDayTypesCalculationResult *result = [self getTargetWorkingDaysForTimeUnit:SummaryUnitMonth
                                                                                andDate:loopDate
                                                                        andLastDayEntry:loopEntry];
            result.isRelevantForYearOvertime = [NSNumber numberWithBool:relevanceForYearOvertime];
            
            [resultsArray addObject:result];
        }

        AXDayTypesCalculationResult *finalResult = [AXDayTypesCalculationResult new];
        for (AXDayTypesCalculationResult *result in resultsArray) {
            
            if ([result.isRelevantForYearOvertime boolValue]) {
                NSNumber *targetDaysWorkedNotWholeNumber = [NSNumber numberWithInt:([result.limitedRangeTargetDays intValue] + [finalResult.limitedRangeTargetDays intValue])];
                finalResult.limitedRangeTargetDays = targetDaysWorkedNotWholeNumber;
            }

            NSNumber *targetDaysWorkedNumber = [NSNumber numberWithInt:([result.wholeRangeTargetDays intValue] + [finalResult.wholeRangeTargetDays intValue])];
            NSNumber *sicknessNumber = [NSNumber numberWithInt:([result.sicknessDays intValue] + [finalResult.sicknessDays intValue])];
            NSNumber *vacationNumber = [NSNumber numberWithInt:([result.vacationDays intValue] + [finalResult.vacationDays intValue])];
            NSNumber *publicHolidaysNumber = [NSNumber numberWithInt:([result.pulicHolidaysDays intValue] + [finalResult.pulicHolidaysDays intValue])];
            NSNumber *offDaysNumber = [NSNumber numberWithInt:([result.dayOffDays intValue] + [finalResult.dayOffDays intValue])];
            
            finalResult.wholeRangeTargetDays = targetDaysWorkedNumber;
            finalResult.sicknessDays = sicknessNumber;
            finalResult.vacationDays = vacationNumber;
            finalResult.pulicHolidaysDays = publicHolidaysNumber;
            finalResult.dayOffDays = offDaysNumber;
        }
        return finalResult;
    }
    
    
	NSArray *fromUserSettingsWorkingWeekArray = [[SettingsManager new] workingWeek];
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];

	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setLocale:[NSLocale currentLocale]];

	NSUInteger numberOfWorkingWeekSettings = [[AXDataStore sharedInstance] getCountForAllManagedObjectsForClass:[WorkingWeekSetting class]];

	NSDateComponents *components = [calendar components:CALENDARUNITCOMPONENTS fromDate:date];

	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];

	NSDate *todayDate = [NSDate date];
	NSDateComponents *componentsToday = [calendar components:CALENDARUNITCOMPONENTS fromDate:todayDate];
	[componentsToday setHour:0];
	[componentsToday setMinute:0];
	[componentsToday setSecond:0];
	NSDate *todayMidnightDate = [calendar dateFromComponents:componentsToday];
	NSDate *checkUntilThisDate = nil;

	if (entry != nil && entry.checkOutTime != nil && [entry.checkOutTime isSameDay:todayDate withReceiverTimeZoneName:entry.checkOutTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
        checkUntilThisDate = [todayMidnightDate addDays:1];
	} else {
		checkUntilThisDate = todayMidnightDate;
	}

	NSDate *beginDate = nil;
	NSUInteger length = 0;
	NSArray *dayTypesArray = [[AXDataStore sharedInstance]
                              getListDayTypesForTimeUnit:unit
                              andDate:date
                              withType:DayTypusNotSpecified];

	switch (unit) {
		case SummaryUnitWeek : {
			beginDate = [date weekBeginning];
			length = 7;
			break;
		}
		case SummaryUnitMonth : {
			beginDate = [date monthBeginning];
            length = [date daysInMonth];
			break;
		}
		case SummaryUnitYear : {
			[components setDay:1];
			[components setMonth:1];
			beginDate = [calendar dateFromComponents:components];

			length = [beginDate daysInYear];
			break;
		}
		default :
			break;
	}

	NSArray *workSettingsArray = [[AXDataStore sharedInstance]
                                  getListWorkingWeekSettingsForDate:beginDate];

	int targetDaysWorked = 0;
	int targetDaysWorkedNotWhole = 0;
	int sicknessDays = 0;
	int publicHolidays = 0;
	int vacationDays = 0;
	int offDays = 0;
	BOOL stopCountingNotWhole = NO;
	NSDate *loopDate = nil;

	for (int i = 0; i < length; i++) {
		if (i > 0) {
            loopDate = [loopDate addDays:1];
		} else {
            // das erstemal mit dem anfang der zeiteinheit anfangen
			loopDate = beginDate;
		}

		if ([loopDate compare:checkUntilThisDate] != NSOrderedAscending) {
			stopCountingNotWhole = YES;
		}

		// TODO kann optimiert werden
		[dateFormatter setDateFormat:@"yyyy"];
		NSNumber *yearNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:loopDate]];
		[dateFormatter setDateFormat:@"MM"];
		NSNumber *monthNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:loopDate]];
		[dateFormatter setDateFormat:@"dd"];
		NSNumber *dayNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:loopDate]];
		NSArray *tempDayTypesArray = [dayTypesArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(year == %@) AND (month == %@) AND (day == %@)", yearNumber, monthNumber, dayNumber]];

		DayType *dayType = nil;
		if (tempDayTypesArray != nil && [tempDayTypesArray count] >= 1) {
			dayType = tempDayTypesArray[0];
		}
		BOOL checkRegularCalendar = YES;

        if (dayType != nil) {
			checkRegularCalendar = NO;
            
			if ([dayType isOff]) {
				offDays++;
			}

			if ([[dayType holiday] boolValue]) {
				publicHolidays++;
			}

			if ([[dayType work] boolValue]) {

                if (![[dayType vacation] boolValue] &&
                    ![[dayType sickness] boolValue]) {
					targetDaysWorked++;
                    if (!stopCountingNotWhole) {
                        targetDaysWorkedNotWhole++;
                    }
				} else if ([[dayType vacation] boolValue]) {
					vacationDays++;
                } else if ([[dayType sickness] boolValue]) {
                    sicknessDays++;
                }
			}
		}

		if (checkRegularCalendar) {
			WorkingWeekSetting *workingWeekSetting = nil;

			if (numberOfWorkingWeekSettings != 0) {

				NSArray *tempDayTypesArray = [workSettingsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"((year = %@) AND (month = %@) AND (day >= %@)) OR ((year = %@) AND (month > %@) AND (day >=%@))  OR ((year > %@) AND (month => %@) AND (day => %@))", yearNumber, monthNumber, dayNumber, yearNumber, monthNumber, [NSNumber numberWithInt:1], yearNumber, [NSNumber numberWithInt:1], [NSNumber numberWithInt:1]] ];

				if ([tempDayTypesArray count] != 0) {
					if ([tempDayTypesArray count] > 1) {
						NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"validUntil" ascending:YES];
						NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
						NSArray *sortedArray = [tempDayTypesArray sortedArrayUsingDescriptors:sortDescriptors];

						workingWeekSetting = sortedArray[0];
					} else {
						workingWeekSetting = tempDayTypesArray[0];
					}
				}
			}

			NSDateComponents *loopComponents = [calendar components:CALENDARUNITCOMPONENTS fromDate:loopDate];

			NSDate *tempDate =  [calendar dateFromComponents:loopComponents];
			NSDateComponents *tempComponents = [calendar components:NSCalendarUnitWeekday fromDate:tempDate];
			NSInteger weekday = [tempComponents weekday];
            
			NSInteger position = [AXUtility standardizeWeekDayFromDateComponents:weekday];
			NSArray *settingsWorkingweek = nil;

			if (workingWeekSetting == nil) {
				settingsWorkingweek = fromUserSettingsWorkingWeekArray;
			} else {
				settingsWorkingweek = [workingWeekSetting workingWeek];
			}

			if ([((NSNumber *)settingsWorkingweek[position])boolValue]) {
				targetDaysWorked++;
				if (!stopCountingNotWhole) {
					targetDaysWorkedNotWhole++;
				}
			} else {
				offDays++;
			}
		}
	}
    
	NSNumber *targetDaysWorkedNumber = [NSNumber numberWithInt:targetDaysWorked];
	NSNumber *targetDaysWorkedNotWholeNumber = [NSNumber numberWithInt:targetDaysWorkedNotWhole];
	NSNumber *sicknessNumber = [NSNumber numberWithInt:sicknessDays];
	NSNumber *vacationNumber = [NSNumber numberWithInt:vacationDays];
	NSNumber *publicHolidaysNumber = [NSNumber numberWithInt:publicHolidays];
	NSNumber *offDaysNumber = [NSNumber numberWithInt:offDays];

	result.wholeRangeTargetDays = targetDaysWorkedNumber;
	result.limitedRangeTargetDays = targetDaysWorkedNotWholeNumber;
	result.sicknessDays = sicknessNumber;
	result.vacationDays = vacationNumber;
	result.pulicHolidaysDays = publicHolidaysNumber;
	result.dayOffDays = offDaysNumber;

    return result;
}

- (NSNumber *)overtimeHoursWithTargetWorkingDays:(NSNumber *)targetDays
                          withHoursPerDay:(NSNumber *)hoursPerDay
                         withNetTimeHours:(NSNumber *)netTimeHours {
    double netTime = [netTimeHours doubleValue];
    double targetDaysAsDouble = [targetDays doubleValue];
    double targetNetTime = [hoursPerDay doubleValue] * targetDaysAsDouble; //FIXME calculation
    
    double overtime = netTime - targetNetTime;
    
    // for negative zero
    if (overtime == 0) {
        overtime = 0;
    }
    return [NSNumber numberWithDouble:overtime];
}

@end
