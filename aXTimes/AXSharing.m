////
////  AXSharing.m
////  aXTimes
////
////  Created by fuesec on 5/25/13.
////  Copyright (c) 2013 aXimilate. All rights reserved.
////
//
//#import "AXSharing.h"
//#import "CSV.h"
//#import "AXCalculation.h"
//#import "NSDate+AXNSDateCategory.h"
//#import "NSDateFormatter+AXDateFormatters.h"
//#import "NSNumberFormatter+AXNSNumberFormatterCategory.h"
//#import "NSCalendar+AXNSCalendarCategory.h"
//
//#define AXExportLocalizedString(key, comment) \
//    [self stringForKey : key]
//
//@interface AXSharing ()
//@property (strong, nonatomic) SettingsManager *settingsController;
//@property (strong, nonatomic) NSString *preferredExportLanguage;
//@property (strong, nonatomic) NSString *preferredExportSeparator;
//@property (strong, nonatomic) NSString *commaSeparatorChar;
//@property (strong, nonatomic) NSString *semicolonSeparatorChar;
//@property (strong, nonatomic) NSString *bom;
//
//@property (strong, nonatomic) NSArray<NSString *> *specialCharArray;
//@property BOOL useCustomLanguage;
//@property BOOL useCustomSeparator;
//
//@end
//
//@implementation AXSharing
//
//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        self.settingsController =  [SettingsManager new];
//        self.preferredExportLanguage = [self.settingsController exportLanguageLocale];
//        self.useCustomLanguage = ![self.preferredExportLanguage isEqualToString:NULLSTRING];
//        self.preferredExportSeparator = [self.settingsController exportDecimalSeparator];
//        self.useCustomSeparator = ![self.preferredExportSeparator isEqualToString:NULLSTRING];
//        self.semicolonSeparatorChar = @";";
//        self.commaSeparatorChar = @",";
//        self.bom = @"\ufeff";
//
//        unichar lineSeparatorCharacter = AXLineSeparatorCharacter;
//        unichar newlineCharacter = AXNewlineCharacter;
//        unichar paragraphSeparatorCharacter = AXParagraphSeparatorCharacter;
//        self.specialCharArray = @[[NSString stringWithCharacters:&lineSeparatorCharacter length:1],
//                                  [NSString stringWithCharacters:&newlineCharacter length:1],
//                                  [NSString stringWithCharacters:&paragraphSeparatorCharacter length:1]];
//    }
//    return self;
//}
//
//- (NSData *)exportSingleEntriesAsCsv:(NSMutableArray *)entries
//                      withMainResult:(AXSummaryCalculationResult *)mainResult
//                  withProjectResults:(NSMutableDictionary<NSManagedObjectID *, AXSummaryCalculationResult *> *)results
//                        withProjects:(NSArray<Project *> *)projects {
//    NSNumberFormatter *numberFormatter;
//    NSDateFormatter *dateDateFormatter;
//    NSDateFormatter *timeDateFormatter;
//    NSDateFormatter *timestampDateFormatter;
//
//    numberFormatter = [NSNumberFormatter defaultNumberFormatter_Static:NO];
//    if (self.useCustomSeparator) {
//        [numberFormatter setDecimalSeparator:self.preferredExportSeparator];
//    }
//    [numberFormatter setUsesGroupingSeparator:NO];
//
//    dateDateFormatter = [NSDateFormatter formatter_Day_Month_Year_Static:NO];
//    
//    timeDateFormatter = [NSDateFormatter new];
//    [timeDateFormatter setDateFormat:DATEFORMATTERHOURMINUTE];
//
//    timestampDateFormatter = [NSDateFormatter formatter_fulltimeStamp:NO];
//
//    BOOL exportWage = [self.settingsController isExportWage];
//    BOOL exportTimezone = [self.settingsController isExportTimeZone];
//
//    CSVRow *headerRow = nil;
//
//    NSMutableArray *headerArray = [[NSMutableArray alloc] initWithArray:@[AXExportLocalizedString(@"Project", nil),
//                                                                          AXExportLocalizedString(@"Subproject", nil),
//                                                                          AXExportLocalizedString(@"Check-In date", nil),
//                                                                          AXExportLocalizedString(@"Check-In time", nil),
//                                                                          AXExportLocalizedString(@"Check-Out date", nil),
//                                                                          AXExportLocalizedString(@"Check-Out time", nil),
//                                                                          AXExportLocalizedString(@"Pause time", nil),
//                                                                          AXExportLocalizedString(@"Working_time", nil),
//                                                                          AXExportLocalizedString(@"Comment", @"Translate the word 'Comment' which is diplayed as header in the settings for the 'default comment view'")
//                                                                          ]];
//
//    if (exportTimezone) {
//        [headerArray insertObject:AXExportLocalizedString(@"Check-In timezone", nil) atIndex:2];
//        [headerArray insertObject:AXExportLocalizedString(@"Check-In timestamp", nil) atIndex:3];
//        [headerArray insertObject:AXExportLocalizedString(@"Check-Out timezone", nil) atIndex:6];
//        [headerArray insertObject:AXExportLocalizedString(@"Check-Out timestamp", nil) atIndex:7];
//    }
//
//    if (exportWage) {
//        [headerArray insertObject:[NSString stringWithFormat:@"%@ %@",
//                                   AXExportLocalizedString(@"Hourly wage", @"Translate the term 'Hourly wage' which is diplayed as a label e.g. in the settings."),
//                                   [self.settingsController currencyIso]] atIndex:[headerArray count] - 1];
//        [headerArray insertObject:[NSString stringWithFormat:@"%@ %@",
//                                   AXExportLocalizedString(@"Wage in", nil),
//                                   [self.settingsController currencyIso]] atIndex:[headerArray count] - 1];
//    }
//
//    for (int i = 0; i < headerArray.count; i++) {
//        headerArray[i] = [NSString stringWithFormat:@"\"%@\"", headerArray[i]];
//    }
//    headerRow = [[CSVRow alloc] initWithValues:headerArray];
//
//    NSMutableArray *tableArray = [[NSMutableArray alloc] initWithObjects:headerRow, nil];
//    NSString *checkInDate = @"";
//    NSString *checkInTime = @"";
//    NSString *checkInTimezone = @"";
//    NSString *checkInTimestamp = @"";
//
//    NSString *checkOutDate = @"";
//    NSString *checkOutTime = @"";
//    NSString *checkOutTimezone = @"";
//    NSString *checkOutTimestamp = @"";
//
//    for (DayEntry *dayEntry in entries) {
//        NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:dayEntry.checkInTimeZone];
//        [dateDateFormatter setTimeZone:timeZone];
//        [timeDateFormatter setTimeZone:timeZone];
//        [timestampDateFormatter setTimeZone:timeZone];
//
//        checkInDate = [dateDateFormatter
//                       stringFromDate:dayEntry.checkInTime];
//        checkInTime = [timeDateFormatter
//                       stringFromDate:dayEntry.checkInTime];
//
//        if (dayEntry.checkOutTime == nil) {
//            // for safety
//            continue;
//        }
//
//        timeZone = [[NSTimeZone alloc] initWithName:dayEntry.checkOutTimeZone];
//        [dateDateFormatter setTimeZone:timeZone];
//        [timeDateFormatter setTimeZone:timeZone];
//        [timestampDateFormatter setTimeZone:timeZone];
//
//        checkOutDate = [dateDateFormatter
//                        stringFromDate:dayEntry.checkOutTime];
//        checkOutTime = [timeDateFormatter
//                        stringFromDate:dayEntry.checkOutTime];
//
//        NSString *pauseTimeString = [numberFormatter
//                                     stringFromNumber:[dayEntry hoursPaused]];
//
//        NSString *netTimeWorkedString = [numberFormatter
//                                         stringFromNumber:[dayEntry netHours]];
//
//        NSString *tempComment = dayEntry.comment;
//
//        if (tempComment) {
//            for (NSString *specialChar in self.specialCharArray) {
//                tempComment = [tempComment stringByReplacingOccurrencesOfString:specialChar withString:@" "];
//            }
//        } else {
//            tempComment = @"";
//        }
//
//        NSString *commentString = tempComment;
//        
//        NSString *projectString = NULLSTRING;
//        NSString *subProjectString = NULLSTRING;
//
//        if (dayEntry.project &&
//            dayEntry.project.parent == nil) { // parent project
//            projectString = [dayEntry.project displayName];
//        } else if (dayEntry.project &&
//                   dayEntry.project.parent != nil) {
//            projectString = dayEntry.project.parent.name;
//            subProjectString = dayEntry.project.name;
//        }
//
//        CSVRow *row = nil;
//        NSMutableArray *rowArray = [[NSMutableArray alloc] initWithArray:@[projectString,
//                                                                           subProjectString,
//                                                                           checkInDate,
//                                                                           checkInTime,
//                                                                           checkOutDate,
//                                                                           checkOutTime,
//                                                                           pauseTimeString,
//                                                                           netTimeWorkedString,
//                                                                           commentString
//                                                                           ]];
//
//        if (exportTimezone) {
//            checkInTimezone = dayEntry.checkInTimeZone;
//            checkInTimestamp = [timestampDateFormatter stringFromDate:dayEntry.checkInTime];
//            [rowArray insertObject:checkInTimezone atIndex:2];
//            [rowArray insertObject:checkInTimestamp atIndex:3];
//            checkOutTimezone = dayEntry.checkOutTimeZone;
//            checkOutTimestamp = [timestampDateFormatter stringFromDate:dayEntry.checkOutTime];
//            [rowArray insertObject:checkOutTimezone atIndex:6];
//            [rowArray insertObject:checkOutTimestamp atIndex:7];
//        }
//
//        if (exportWage) {
//            NSString *hourlyWageString = [numberFormatter
//                                          stringFromNumber:[dayEntry actualHourlyWage]];
//            [rowArray insertObject:hourlyWageString atIndex:[rowArray count] - 1];
//            NSString *salaryString = [numberFormatter
//                                      stringFromNumber:[dayEntry income]];
//            [rowArray insertObject:salaryString atIndex:[rowArray count] - 1];
//        }
//
//        for (int i = 0; i < rowArray.count; i++) {
//            rowArray[i] = [NSString stringWithFormat:@"\"%@\"", rowArray[i]];
//        }
//        row = [[CSVRow alloc] initWithValues:rowArray];
//        [tableArray addObject:row];
//    }
//
//    NSString *totalNetTimeWorkedString = @"";
//    NSString *totalPauseTimeString = @"";
//    
//    if (mainResult.netWorkingTimeHours) {
//        totalNetTimeWorkedString = [numberFormatter
//                                    stringFromNumber:mainResult.netWorkingTimeHours];
//    }
//    if (mainResult.pauseTimeHours) {
//        totalPauseTimeString = [numberFormatter
//                                stringFromNumber:mainResult.pauseTimeHours];
//    }
//
//    // bottom row for total
//    CSVRow *bottomRow = nil;
//    NSMutableArray *bottomArray = [[NSMutableArray alloc]
//                                   initWithArray:@[AXExportLocalizedString(@"Total", nil),
//                                                   @"",
//                                                   @"",
//                                                   @"",
//                                                   @"",
//                                                   @"",
//                                                   totalPauseTimeString,
//                                                   totalNetTimeWorkedString,
//                                                   @""]];
//
//    if (exportTimezone) {
//        [bottomArray insertObject:@"" atIndex:2];
//        [bottomArray insertObject:@"" atIndex:3];
//        [bottomArray insertObject:@"" atIndex:6];
//        [bottomArray insertObject:@"" atIndex:7];
//    }
//
//    if (exportWage) {
//        [bottomArray insertObject:@"" atIndex:[bottomArray count] - 1];
//        NSString *totalHourlyWageString = @"";
//        if (mainResult.income) {
//            totalHourlyWageString = [numberFormatter
//                                     stringFromNumber:mainResult.income];
//        }
//        [bottomArray insertObject:totalHourlyWageString atIndex:[bottomArray count] - 1];
//    }
//
//    for (int i = 0; i < bottomArray.count; i++) {
//        bottomArray[i] = [NSString stringWithFormat:@"\"%@\"", bottomArray[i]];
//    }
//
//    bottomRow = [[CSVRow alloc] initWithValues:bottomArray];
//
//    [tableArray addObject:bottomRow];
//    
//    for (Project *project in projects) {
//        AXSummaryCalculationResult *result = results[project.objectID];
//        NSString *netTimeWorkedString = @"";
//        NSString *pauseTimeString = @"";
//        if (result.netWorkingTimeHours) {
//            netTimeWorkedString = [numberFormatter stringFromNumber:result.netWorkingTimeHours];
//        }
//        if (result.pauseTimeHours) {
//            pauseTimeString = [numberFormatter stringFromNumber:result.pauseTimeHours];
//        }
//        CSVRow *bottomRow = nil;
//        
//        NSString *projectString = NULLSTRING;
//        NSString *subProjectString = NULLSTRING;
//        
//        if (project.parent == nil) { // parent project
//            projectString = [project displayName];
//        } else if (project.parent != nil) {
//            projectString = project.parent.name;
//            subProjectString = project.name;
//        }
//        
//        NSMutableArray *bottomArray = [[NSMutableArray alloc]
//                                       initWithArray:@[projectString,
//                                                       subProjectString,
//                                                       @"",
//                                                       @"",
//                                                       @"",
//                                                       @"",
//                                                       pauseTimeString,
//                                                       netTimeWorkedString,
//                                                       @""]];
//        
//        if (exportTimezone) {
//            [bottomArray insertObject:@"" atIndex:2];
//            [bottomArray insertObject:@"" atIndex:3];
//            [bottomArray insertObject:@"" atIndex:6];
//            [bottomArray insertObject:@"" atIndex:7];
//        }
//        
//        if (exportWage) {
//            [bottomArray insertObject:@"" atIndex:[bottomArray count] - 1];
//            NSString *hourlyWageString = @"";
//            if (result.income) {
//                hourlyWageString = [numberFormatter stringFromNumber:result.income];
//            }
//            [bottomArray insertObject:hourlyWageString atIndex:[bottomArray count] - 1];
//        }
//        
//        for (int i = 0; i < bottomArray.count; i++) {
//            bottomArray[i] = [NSString stringWithFormat:@"\"%@\"", bottomArray[i]];
//        }
//        
//        bottomRow = [[CSVRow alloc] initWithValues:bottomArray];
//        
//        [tableArray addObject:bottomRow];
//    }
//
//    CSVTable *table = [[CSVTable alloc] initWithRows:tableArray];
//
//    NSMutableString *output = [NSMutableString new];
//    [output appendString:self.bom];
//
//    CSVSerializer *serializer = [[CSVSerializer alloc] initWithOutput:output];
//    if ([numberFormatter.decimalSeparator isEqualToString:self.commaSeparatorChar]) {
//        [serializer setSeparatorChar:self.semicolonSeparatorChar];
//    } else {
//        [serializer setSeparatorChar:self.commaSeparatorChar];
//    }
//    [serializer serialize:table];
//
//    NSData *data = [output dataUsingEncoding:NSUTF8StringEncoding];
//    return data;
//}
//
//- (NSData *)exportEntriesAsCsvForYear:(NSMutableArray *)entries {
//    AXCalculation *axcalculator = [AXCalculation new];
//    NSNumberFormatter *numberFormatter;
//    
//    numberFormatter = [NSNumberFormatter defaultNumberFormatter_Static:NO];
//    if (self.useCustomSeparator) {
//        [numberFormatter setDecimalSeparator:self.preferredExportSeparator];
//    }
//    [numberFormatter setUsesGroupingSeparator:NO];
//
//    NSDate *nowDate = [NSDate date];
//    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    [dateFormatter setDateFormat:@"MMMM"];
//    NSCalendar *calendar = [NSCalendar defaultCalendar_Static:YES];
//    NSDateComponents *components = [calendar components:CALENDARUNITCOMPONENTS
//                                               fromDate:nowDate];
//
//    [components setHour:0];
//    [components setMinute:0];
//    [components setSecond:0];
//    [components setDay:1];
//
//    BOOL exportWage = [self.settingsController isExportWage];
//
//    CSVRow *headerRow = nil;
//    
//    NSMutableArray *headerArray = [[NSMutableArray alloc]
//                                   initWithArray:@[AXExportLocalizedString(@"Month", nil),
//                                                   AXExportLocalizedString(@"Working_time", nil),
//                                                   AXExportLocalizedString(@"Overtime", nil)]];
//    
//    if (exportWage) {
//        [headerArray insertObject:[NSString stringWithFormat:@"%@ %@",
//                                   AXExportLocalizedString(@"Wage in", nil),
//                                   [self.settingsController currencyIso]] atIndex:[headerArray count]];
//    }
//
//    for (int i = 0; i < headerArray.count; i++) {
//        headerArray[i] = [NSString stringWithFormat:@"\"%@\"", headerArray[i]];
//    }
//    headerRow = [[CSVRow alloc] initWithValues:headerArray];
//
//    NSMutableArray *tableArray = [[NSMutableArray alloc] initWithObjects:headerRow, nil];
//
//    
//    NSDecimalNumber *overtime = [NSDecimalNumber zero];
//    for (int i = 1; i <= 12; i++) {
//        [components setMonth:i];
//
//        NSString *monthString = [dateFormatter stringFromDate:[calendar dateFromComponents:components]];
//
//        NSMutableArray *tempEntries = [NSMutableArray new];
//        NSDate *tempDate = [calendar dateFromComponents:components];
//        for (DayEntry *dayEntry in entries) {
//            if ([dayEntry.checkInTime isSameMonthOnlyMonthComponent:tempDate]) {
//                [tempEntries addObject:dayEntry];
//            }
//        }
//        
//        NSString *netTimeWorkedString = NULLSTRING;
//        NSString *overtimeString = NULLSTRING;
//        
//        if ([tempEntries count] > 0) {
//            NSNumber *netTimeHours = [DayEntry netTimeForArray:tempEntries];
//            netTimeWorkedString = [numberFormatter
//                                   stringFromNumber:netTimeHours];
//            DayEntry *entry = tempEntries[[tempEntries count] - 1];
//            NSDate *monthDate = [calendar dateFromComponents:components];
//            
//            AXDayTypesCalculationResult *dayTypecalculationsResult;
//            dayTypecalculationsResult = [axcalculator
//                                         getTargetWorkingDaysForTimeUnit:SummaryUnitMonth
//                                         andDate:monthDate
//                                         andLastDayEntry:entry];
//            NSDecimalNumber *overtimeTemp;
//            overtimeTemp = [AXCalculation
//                            overtimeHoursWithTargetWorkingDays:[dayTypecalculationsResult.wholeRangeTargetDays decimalNumber]
//                            withHoursPerDay:[NSDecimalNumber decimalNumberWithDecimal:[self.settingsController hoursPerDay].decimalValue]
//                            withNetTimeHours:[netTimeHours decimalNumber]];
//            if (overtimeTemp) {
//                overtime = [overtime
//                            decimalNumberByAdding:overtimeTemp];
//                overtimeString = [numberFormatter
//                                  stringFromNumber:overtimeTemp];
//            }
//        }
//        
//        CSVRow *row = nil;
//        NSMutableArray *rowArray = [[NSMutableArray alloc] initWithArray:@[monthString,
//                                                                           netTimeWorkedString,
//                                                                           overtimeString]];
//
//        if (exportWage) {
//            NSString *hourlyWageString = [numberFormatter
//                                          stringFromNumber:[DayEntry incomeForArray:tempEntries]];
//            [rowArray insertObject:hourlyWageString atIndex:[rowArray count]];
//        }
//
//        for (int i = 0; i < rowArray.count; i++) {
//            rowArray[i] = [NSString stringWithFormat:@"\"%@\"", rowArray[i]];
//        }
//        row = [[CSVRow alloc] initWithValues:rowArray];
//        [tableArray addObject:row];
//    }
//
//    NSString *totalNetTimeWorkedString = [numberFormatter
//                                          stringFromNumber:[DayEntry netTimeForArray:entries]];
//    NSString *totalOvertimeString = [numberFormatter
//                                     stringFromNumber:overtime];
//    
//    
//    // bottom row for total
//    CSVRow *bottomRow = nil;
//    NSMutableArray *bottomArray = [[NSMutableArray alloc]
//                                   initWithArray:@[AXExportLocalizedString(@"Total", nil),
//                                                   totalNetTimeWorkedString,
//                                                   totalOvertimeString]];
//    
//    if (exportWage) {
//        NSString *totalHourlyWageString = [numberFormatter
//                                           stringFromNumber:[DayEntry incomeForArray:entries]];
//        [bottomArray insertObject:totalHourlyWageString atIndex:[bottomArray count]];
//    }
//
//    for (int i = 0; i < bottomArray.count; i++) {
//        bottomArray[i] = [NSString stringWithFormat:@"\"%@\"", bottomArray[i]];
//    }
//    bottomRow = [[CSVRow alloc] initWithValues:bottomArray];
//    [tableArray addObject:bottomRow];
//
//    CSVTable *table = [[CSVTable alloc] initWithRows:tableArray];
//
//    NSMutableString *output = [NSMutableString new];
//    [output appendString:self.bom];
//    CSVSerializer *serializer = [[CSVSerializer alloc] initWithOutput:output];
//    if ([numberFormatter.decimalSeparator isEqualToString:self.commaSeparatorChar]) {
//        [serializer setSeparatorChar:self.semicolonSeparatorChar];
//    } else {
//        [serializer setSeparatorChar:self.commaSeparatorChar];
//    }
//    [serializer serialize:table];
//
//    NSData *data = [output dataUsingEncoding:NSUTF8StringEncoding];
//
//    return data;
//}
//
//#pragma mark - convenience methods
//
//- (NSString *)stringForKey:(NSString *)key {
//    if (!self.useCustomLanguage) {
//        return NSLocalizedString(key, @"");
//    }
//
//    NSString *path = [[NSBundle mainBundle] pathForResource:self.preferredExportLanguage ofType:@"lproj"];
//    NSBundle *languageBundle = [NSBundle bundleWithPath:path];
//    NSString *returnString = [languageBundle localizedStringForKey:key value:@"" table:nil];
//
//    return returnString;
//}
//
//@end

