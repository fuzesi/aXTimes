//
//  AXUtility.m
//  aXTimes
//
//  Created by fuesec on 5/21/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXUtility.h"
#import "NSCalendar+AXNSCalendarCategory.h"

@implementation AXUtility

+ (NSString *)localeToExportLanguageString:(NSString *)localeString {
	if ([localeString isEqualToString:NULLSTRING]) {
		NSString *deviceLanguageLocaleString = [[NSLocale preferredLanguages] objectAtIndex:0];
		NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:deviceLanguageLocaleString];
		NSString *language = [locale displayNameForKey:NSLocaleIdentifier value:deviceLanguageLocaleString];
		return [NSString stringWithFormat:@"%@ (%@)", NSLS_SYSTEM, language];
	}
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeString];
	NSString *language = [locale displayNameForKey:NSLocaleIdentifier value:localeString];

	return [NSString stringWithFormat:@"%@",  language];
}


+ (void)dayTypeChangedWithIndex:(NSInteger)selectedSegment withDate:(NSDate *)date {
    DayType *dayType = [[AXDataStore sharedInstance] getDayTypeForCalendarDay:date];
    
    BOOL work = NO;
        
    if (selectedSegment == DayTypusNotAWorkingDay || selectedSegment == UISegmentedControlNoSegment) {
        WorkingWeekSetting *workingWeekSetting = [[AXDataStore sharedInstance] getLatestWorkingWeekSettingForDate:date];
        NSCalendar *cal = [NSCalendar defaultCalendar_Static:YES];
        NSDateComponents *components = [cal components:CALENDARUNITCOMPONENTS fromDate:date];
        
        NSDate *tempDate =  [cal dateFromComponents:components];
        NSDateComponents *tempComponents = [cal components:NSCalendarUnitWeekday fromDate:tempDate];
        NSUInteger weekday = [tempComponents weekday];
        NSInteger position = [AXUtility standardizeWeekDayFromDateComponents:weekday];
        NSArray *settingsWorkingweek = nil;
        
        if (workingWeekSetting == nil) {
            settingsWorkingweek = [[SettingsManager new] workingWeek];
        } else {
            settingsWorkingweek = [workingWeekSetting workingWeek];
        }
        
        work = [((NSNumber *)settingsWorkingweek[position])boolValue];
    } else if (dayType == nil) {
        dayType = [[[AXDataStore sharedInstance] managedObjectContext] newDayTypeEntityForTargetDate:date];
    }
    
    switch (selectedSegment) {
        case DayTypusNotAWorkingDay :
            if (!work) {
                if (dayType != nil) {
                    [[AXDataStore sharedInstance] deleteObject:dayType];
                }
            } else {
                if (dayType == nil) {
                    dayType = [[[AXDataStore sharedInstance] managedObjectContext] newDayTypeEntityForTargetDate:date];
                }
                [dayType setOff];
            }
            break;
        case UISegmentedControlNoSegment :
            if (work) {
                if (dayType != nil) {
                    [[AXDataStore sharedInstance] deleteObject:dayType];
                }
            } else {
                if (dayType == nil) {
                    dayType = [[[AXDataStore sharedInstance] managedObjectContext] newDayTypeEntityForTargetDate:date];
                }
                [dayType setWork];
            }
            break;
        case DayTypusSickDay :
            [dayType setSickness];
            break;
        case DayTypusVacationDay :
            [dayType setVacation];
            break;
        case DayTypusHoliday :
            [dayType setHoliday];
            break;
        default :
            break;
    }
}

+ (void)dayTypeArrayChanged:(NSInteger)selectedSegment withDateArray:(NSMutableArray *)dateArray {
    for(NSDate* d in dateArray){
        [self dayTypeChangedWithIndex:selectedSegment withDate:d];
    }
}

//return value: week starts on monday with index 0
+ (NSUInteger)standardizeWeekDayFromDateComponents:(NSUInteger)weekDayFromComponents {
    return fmod(weekDayFromComponents + 5, 7);
}

+ (void)handleCommentChange:(DayEntry *)dayEntry andText:(NSString *)textViewString {
    if (!textViewString) {
        return;
    }
    
    if ([textViewString isEqualToString:dayEntry.comment]) {
        // nothing to do since the string did not change
        return;
    }
    
    // new comment or update existing comment
    if (textViewString &&
        ![textViewString isEqualToString:@""]) {
        Comment *comment = [[AXDataStore sharedInstance] getComment:textViewString];
        if (comment) {
            comment.usage = @([comment.usage intValue] + 1);
            comment.lastUsedDate = [NSDate date];
        } else {
            comment = [[[AXDataStore sharedInstance] managedObjectContext] newCommentEntityWithComment:textViewString];
        }
    }
    
    // handle the old comment if the dayentry had one
    if (![dayEntry.comment isEqualToString:@""]) {
        Comment *comment = [[AXDataStore sharedInstance] getComment:dayEntry.comment];
        if ([comment.usage isEqualToNumber:@(1)]) {
            [[AXDataStore sharedInstance] deleteObject:comment];
        } else {
            comment.usage = @([comment.usage intValue] - 1);
        }
    }
    // now set new comment
    dayEntry.comment = textViewString;
}

@end
