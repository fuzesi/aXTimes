////
////  Project.m
////  aXTimes
////
////  Created by fuesec on 22/09/15.
////  Copyright © 2015 aXimilate. All rights reserved.
////
//
//#import "Project.h"
//#import "NSDateFormatter+AXDateFormatters.h"
//#import "NSNumber+AXNSNumberCategory.h"
//#import "NSString+AXNSStringCategory.h"
//#import "SettingsManager.h"
//#import "NSDate+AXNSDateCategory.h"
//#import "NSCalendar+AXNSCalendarCategory.h"
//
//
//
//
//@implementation Project
//
//#pragma mark - setters
//
//- (void)setFromDate:(NSDate *)fromDate {
//    [self willChangeValueForKey:@"fromDate"];
//    [self setPrimitiveValue:fromDate forKey:@"fromDate"];
//    [self didChangeValueForKey:@"fromDate"];
//    
//    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
//    NSString *systemTimeZoneName = [timeZone name];
//    [self setFromDateTimeZone:systemTimeZoneName];
//}
//
//- (void)setToDate:(NSDate *)toDate {
//    [self willChangeValueForKey:@"toDate"];
//    [self setPrimitiveValue:toDate forKey:@"toDate"];
//    [self didChangeValueForKey:@"toDate"];
//    
//    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
//    NSString *systemTimeZoneName = [timeZone name];
//    [self setToDateTimeZone:systemTimeZoneName];
//}
//
//- (void)setFilterActiveForAllSubProjects:(BOOL)filterActive {
//    for (Project *subProject in self.subProjects) {
//        [subProject setFilterActiveNoCheck:@(filterActive)];
//    }
//}
//
//- (void)setFilterActiveNoCheck:(NSNumber *)filterActive {
//    [self willChangeValueForKey:@"filterActive"];
//    [self setPrimitiveValue:filterActive forKey:@"filterActive"];
//    [self didChangeValueForKey:@"filterActive"];
//}
//
//- (void)setFilterActive:(NSNumber *)filterActive {
//    BOOL oldValue = [self.filterActive boolValue];
//    
//    [self willChangeValueForKey:@"filterActive"];
//    [self setPrimitiveValue:filterActive forKey:@"filterActive"];
//    [self didChangeValueForKey:@"filterActive"];
//    
//    if ([filterActive boolValue] != oldValue) {
//        if (self.parentProject) {
//            if ([self.parentProject.filterActive boolValue] != [self.parentProject isFilterActiveForAllSubProjects]) {
//                [self.parentProject setFilterActiveNoCheck:@([self.parentProject isFilterActiveForAllSubProjects])];
//            }
//        }
//    }
//}
//
//#pragma mark - other methods
//
//// week start at monday with index 0
//- (DefaultPauseSetting *)retrieveDefaultPauseSettingEntryForWeekDayIndex:(NSInteger)weekDayIndex {
//    Project *project;
//    if (self.parentProject != nil) {
//        project = self.parentProject;
//    } else {
//        project = self;
//    }
//    DefaultPauseSetting *defaultPauseSetting = nil;
//    
//    if ([project.defaultPauseSettings count] > 0) {
//        for (DefaultPauseSetting *settingEntry in project.defaultPauseSettings) {
//            if ([settingEntry.dayOfWeek unsignedIntegerValue] == weekDayIndex) {
//                defaultPauseSetting = settingEntry;
//            }
//        }
//    }
//    
//    return defaultPauseSetting;
//}
//
//- (NSDate *)getDefaultPauseStartForWeekday:(NSUInteger)weekday {
//    Project *project;
//    if (self.parentProject != nil) {
//        project = self.parentProject;
//    } else {
//        project = self;
//    }
//    
//    DefaultPauseSetting *setting = [project
//                                    retrieveDefaultPauseSettingEntryForWeekDayIndex:weekday];
//    if (setting) {
//        return setting.start;
//    }
//    return project.defaultPauseStart;
//}
//
//- (NSDate *)getDefaultPauseEndForWeekday:(NSUInteger)weekday {
//    Project *project;
//    if (self.parentProject != nil) {
//        project = self.parentProject;
//    } else {
//        project = self;
//    }
//    
//    DefaultPauseSetting *setting = [project
//                                    retrieveDefaultPauseSettingEntryForWeekDayIndex:weekday];
//    if (setting) {
//        return setting.end;
//    }
//    return project.defaultPauseEnd;
//}
//
//- (RoundingBehaviour)getRoundingBehaviour {
//    if (self.parentProject != nil) {
//        return [self.parentProject.roundingBehaviour unsignedIntegerValue];
//    }
//    return [self.roundingBehaviour unsignedIntegerValue];
//}
//
//- (NSUInteger)getTimeUnit {
//    if (self.parentProject != nil) {
//        return [self.parentProject.timeUnit unsignedIntegerValue];
//    }
//    return [self.timeUnit unsignedIntegerValue];
//}
//
//- (NSDecimalNumber *)getHourlyWage {
//    if (self.parentProject != nil) {
//        return self.parentProject.hourlyWage;
//    }
//    return self.hourlyWage;
//}
//
//- (NSDecimalNumber *)sumOfSubProjectBudgets {
//    NSDecimalNumber *sum = [[NSDecimalNumber alloc] initWithInteger:0];
//    for (Project *subProject in [self subProjects]) {
//        sum = [subProject.budget decimalNumberByAdding:sum];
//    }
//    return sum;
//}
//
//- (NSDecimalNumber *)getBudget {
//    if ([self.isUseSubProjectsBudget boolValue]) {
//        if ([self.subProjects count] > 0) {
//            return [self sumOfSubProjectBudgets];
//        } else {
//            return [NSDecimalNumber zero];
//        }
//    } else {
//        return self.budget;
//    }
//}
//
//- (NSNumber *)remainingBudgetWithEntries:(NSArray<DayEntry *> *)entries {
//    NSNumber *remainingBudgetNumber = nil;
//    NSNumber *tempNetTimeHoursNumber = [DayEntry netTimeForArray:entries];
//    berechnung schöner
//    double budget = [[self getBudget] doubleValue] * [[SettingsManager hoursPerDay] doubleValue];
//    double remaining = budget - [tempNetTimeHoursNumber doubleValue];
//    remainingBudgetNumber = [NSNumber numberWithDouble:remaining];
//    return remainingBudgetNumber;
//}
//
//- (NSArray<DayEntry *> *)fetchEntriesWithEnd:(NSDate *)end {
//    NSArray<DayEntry *> *entries;
//    
//    if (self.parentProject == nil) {
//        NSMutableArray<DayEntry *> *tempEntries = [NSMutableArray new];
//        for (Project *subProject in [self subProjects]) {
//            [tempEntries addObjectsFromArray:subProject.dayEntries.allObjects];
//        }
//        entries = tempEntries;
//    } else {
//        entries = self.dayEntries.allObjects;
//    }
//
//    NSDate *timeZoneIncludedEndDate = [end addDays:1];
//    
//    NSPredicate *predicate = [NSPredicate
//                              predicateWithFormat:@"(checkOutTime != nil AND (checkInTime <= %@))",
//                              timeZoneIncludedEndDate];
//    
//    NSArray *fetchedResults = [entries filteredArrayUsingPredicate:predicate];
//    
//    NSMutableArray *tempFetchedResults = [NSMutableArray arrayWithArray:fetchedResults];
//    
//    NSArray *actuallyNotInThisMonth = [tempFetchedResults
//                                       filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(checkInTime > %@)", end]];
//    
//    for (DayEntry *entry in actuallyNotInThisMonth) {
//        if ([entry.checkInTimeZone isEqualToString:[[NSTimeZone systemTimeZone] name]]) {
//            [tempFetchedResults removeObject:entry];
//        } else {
//            if (([entry.checkInTime compare:end] == NSOrderedDescending &&
//                 ![entry.checkInTime isSameDay:end withReceiverTimeZoneName:entry.checkInTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]])) {
//                    [tempFetchedResults removeObject:entry];
//                }
//        }
//    }
//    
//    return tempFetchedResults;
//}
//
//#pragma mark - misc
//
//- (NSString *)timeRangeString {
//    NSString *timeRangeString = @"";
//    
//    NSDateFormatter *dateFormatter = [NSDateFormatter formatter_Day_Month_Year_Static:NO];
//    [dateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:self.fromDateTimeZone]];
//    timeRangeString = [NSString stringWithFormat:@"%@ - ",
//                       [dateFormatter stringFromDate:self.fromDate]];
//    
//    if (self.toDate != nil) {
//        [dateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:self.toDateTimeZone]];
//        timeRangeString = [NSString stringWithFormat:@"%@%@",
//                           timeRangeString,
//                           [dateFormatter stringFromDate:self.toDate]];
//    }
//    
//    return timeRangeString;
//}
//
//@end
