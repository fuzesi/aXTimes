//
//  AXSummaryCalculationResult.m
//  aXTimes
//
//  Created by Christopher Füseschi on 17/08/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXSummaryCalculationResult.h"
#import "NSString+AXNSStringCategory.h"
#import "NSNumber+AXNSNumberCategory.h"

@implementation AXSummaryCalculationResult

- (instancetype)initWithDayTypesCalculationResult:(AXDayTypesCalculationResult *)dayTypecalculationsResult {
    self = [super init];
    
    if (self) {
        self.displayInfo = [AXSummaryDisplayInformation new];
        self.dayTypecalculationsResult = dayTypecalculationsResult;
    }
    return self;
}

//TODO hours to days könnte man auch in der klasse machen

- (instancetype)initWithCalculationResults:(NSArray<AXSummaryCalculationResult *>*)calculationResults
             withDayTypesCalculationResult:(AXDayTypesCalculationResult *)dayTypecalculationsResult {
    self = [self initWithDayTypesCalculationResult:dayTypecalculationsResult];
    
    if (self) {
        NSNumber *netWorkingTimeHours;
        NSNumber *netWorkingTimeDays;
        NSNumber *pauseTimeHours;
        NSNumber *averageTimePerDay;
        NSNumber *income;
        NSNumber *remainingBudget;
        for (AXSummaryCalculationResult *calculationResult in calculationResults) {
            if (calculationResult.netWorkingTimeHours) {
                if (!netWorkingTimeHours) {
                    netWorkingTimeHours = [NSNumber numberWithDouble:0.0];
                }
                netWorkingTimeHours = [netWorkingTimeHours add:calculationResult.netWorkingTimeHours];
            }
            if (calculationResult.netWorkingTimeDays) {
                if (!netWorkingTimeDays) {
                    netWorkingTimeDays = [NSNumber numberWithDouble:0.0];
                }
                netWorkingTimeDays = [netWorkingTimeDays add:calculationResult.netWorkingTimeDays];
            }
            if (calculationResult.pauseTimeHours) {
                if (!pauseTimeHours) {
                    pauseTimeHours = [NSNumber numberWithDouble:0.0];
                }
                pauseTimeHours = [pauseTimeHours add:calculationResult.pauseTimeHours];
            }
            if (calculationResult.averageTimePerDay) {
                if (!averageTimePerDay) {
                    averageTimePerDay = [NSNumber numberWithDouble:0.0];
                }
                averageTimePerDay = [averageTimePerDay add:calculationResult.averageTimePerDay];
            }
            if (calculationResult.income) {
                if (!income) {
                    income = [NSNumber numberWithDouble:0.0];
                }
                income = [income add:calculationResult.income];
            }
            if (calculationResult.remainingBudget) { //TODO kann weg oder
                if (!remainingBudget) {
                    remainingBudget = [NSNumber numberWithDouble:0.0];
                }
                remainingBudget = [remainingBudget add:calculationResult.remainingBudget];
            }
        }
        self.netWorkingTimeHours = netWorkingTimeHours;
        self.netWorkingTimeDays = netWorkingTimeDays;
        self.pauseTimeHours = pauseTimeHours;
        if (netWorkingTimeHours) {
            NSNumber *hoursPerDay = [[SettingsManager new] hoursPerDay];
            self.overtimeHours = [AXCalculation
                                  overtimeHoursWithTargetWorkingDays:[dayTypecalculationsResult.limitedRangeTargetDays decimalNumber]
                                  withHoursPerDay:[NSDecimalNumber decimalNumberWithDecimal:hoursPerDay.decimalValue]
                                  withNetTimeHours:[netWorkingTimeHours decimalNumber]];
            if (self.overtimeHours) {
                self.overtimeDays = [self.overtimeHours hoursToDaysWithHoursPerDay:[NSDecimalNumber decimalNumberWithDecimal:hoursPerDay.decimalValue]];
            }
        }
        self.averageTimePerDay = averageTimePerDay;
        self.income = income;
        self.remainingBudget = remainingBudget;

        [self createDisplayInformation];
    }
    return self;
}

- (void)createDisplayInformation {
    
    if (self.targetTimeInHours) {
        self.displayInfo.plannedWorkingTimeHours = [self.targetTimeInHours displayTime];
    }
    
    if (self.netWorkingTimeHours) {
        self.displayInfo.netWorkingTimeHours = [self.netWorkingTimeHours displayTime];
    }
    
    if (self.netWorkingTimeDays) {
        self.displayInfo.netWorkingTimeDays = [[self.netWorkingTimeDays stringValueNumberFormatted]
                                               appendStringWithWhiteSpace:NSLS_DAYS];
    }
    
    if (self.pauseTimeHours) { //currently not used
        self.displayInfo.pauseTimeHours = [[self.pauseTimeHours stringValueNumberFormatted]
                                                appendStringWithWhiteSpace:NSLS_HOUR_SHORT];
    }
    
    if ([self.overtimeHours doubleValue] != 0) {
        self.displayInfo.overtimeUseColor = YES;
        if ([self.overtimeHours doubleValue] < 0) {
            self.displayInfo.overTimeColor = REDCOLOR;
        } else {
            self.displayInfo.overTimeColor = GREENCOLOR;
        }
    }
    
    if (self.overtimeHours) {
        self.displayInfo.overtimeHours = [self.overtimeHours displayTime];
    }
    
    if (self.overtimeDays) {
        NSString *overTimeDaysString = [[self.overtimeDays stringValueNumberFormatted]
                                        appendStringWithWhiteSpace:NSLS_DAYS];
        self.displayInfo.overtimeDays = overTimeDaysString;
    }
    
    if (self.averageTimePerDay) {
        self.displayInfo.averageTimePerDay = [self.averageTimePerDay displayTime];
    }
    
    if (self.income) {
        NSString *salary = [NSString stringWithFormat:@"%@ %@",
                            [self.income stringValueNumberFormatted],
                            [[SettingsManager new] currencyIso]];
        self.displayInfo.income = salary;
    }
    
    if (self.remainingBudget) {
        NSString *remainingBudget = [NSString stringWithFormat:@"%@ %@",
                                     [self.remainingBudget stringValueNumberFormatted],
                                     NSLS_HOUR_SHORT];
        self.displayInfo.remainingBudget = remainingBudget;
    }
}

- (void)setDayTypecalculationsResult:(AXDayTypesCalculationResult *)dayTypecalculationsResult {
    
    NSString *targetTimeInDays = [dayTypecalculationsResult.wholeRangeTargetDays stringValue];
    
    NSInteger dayOffNumber = [dayTypecalculationsResult.dayOffDays integerValue];
    NSString *dayOff = [NSString stringWithFormat:@"%ld", (long)dayOffNumber];
    
    NSInteger sicknessDaysNumber = [dayTypecalculationsResult.sicknessDays integerValue];
    NSString *sickness = [NSString stringWithFormat:@"%ld", (long)sicknessDaysNumber];
    
    NSInteger vacationDaysNumber = [dayTypecalculationsResult.vacationDays integerValue];
    NSString *vacation = [NSString stringWithFormat:@"%ld", (long)vacationDaysNumber];
    
    NSInteger publicHolidayNumber = [dayTypecalculationsResult.pulicHolidaysDays integerValue];
    NSString *publicHoliday = [NSString stringWithFormat:@"%ld", (long)publicHolidayNumber];
    
    self.displayInfo.dayOff = dayOff;
    self.displayInfo.publicHolidays = publicHoliday;
    self.displayInfo.vacation = vacation;
    self.displayInfo.sickness = sickness;
    self.displayInfo.plannedWorkingTimeDays = targetTimeInDays;
}

@end
