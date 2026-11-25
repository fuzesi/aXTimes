//
//  AXCalculation.h
//  aXTimes
//
//  Created by fuesec on 5/27/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXDayTypesCalculationResult.h"
#import "AXSummaryCalculationResult.h"
#import "AXSummaryDisplayInformation.h"

@class DayEntry;
@class Project;

typedef NS_ENUM (NSUInteger, SummaryUnit) {
    SummaryUnitDay = 0,
    SummaryUnitWeek = 1,
    SummaryUnitMonth = 2,
    SummaryUnitYear = 3
};


@interface AXCalculation : NSObject


- (AXDayTypesCalculationResult *)getTargetWorkingDaysForTimeUnit:(SummaryUnit)unit
                                                         andDate:(NSDate *)date
                                                 andLastDayEntry:(DayEntry *)entry;
- (AXSummaryCalculationResult *)calculationResultForFetchedEntries:(NSArray<DayEntry *> *)fetchedDayEntries
                                      forDayTypesCalculationResult:(AXDayTypesCalculationResult *)dayTypesCalculationResult
                                                        andProject:(Project *)project;

- (NSNumber *)overtimeHoursWithTargetWorkingDays:(NSNumber *)targetDays
                                 withHoursPerDay:(NSNumber *)hoursPerDay
                                withNetTimeHours:(NSNumber *)netTimeHours;


@end
