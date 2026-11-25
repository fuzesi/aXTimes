//
//  AXAttendanceRecorder.m
//  aXTimes
//
//  Created by fuesec on 07/10/15.
//  Copyright © 2015 aXimilate. All rights reserved.
//

#import "AXAttendanceRecorder.h"

#import "AXUtility.h"
#import "NSDate+AXNSDateCategory.h"


@implementation AXAttendanceRecorder

+ (void)performCheckInForEntry:(DayEntry *)entry
                      withTime:(NSDate *)date
                   withProject:(nullable Project *)project {
    if (!project) {
        // use settings
        entry.project = [[AXDataStore sharedInstance] defaultCheckInProject];
    } else {
        entry.project = project;
    }
    
    if (!entry.project) { // if no project set basic project
        entry.project = [[AXDataStore sharedInstance] getBasicProject];
    }
    
    entry.comment = entry.project.actualDefaultComment;
    
    [entry configureWithStart:date
                  andTimeZone:[[NSTimeZone systemTimeZone] name]];
}

+ (void)performCheckOutForEntry:(DayEntry *)entry
                       withTime:(NSDate *)checkOutTime {
    [entry configureWithEnd:checkOutTime
                andTimeZone:[[NSTimeZone systemTimeZone] name]];
    
    // delete dayentry if the user worked less than one minute
    if ([[entry minutesWorked] doubleValue] < 1) {
        [[AXDataStore sharedInstance] deleteObject:entry];
    } else {
        [AXAttendanceRecorder applyDefaultPauseSettingsToEntry:entry];
        [entry normalize];  
    }
}

+ (void)finishPause:(Pause *)pause atTime:(NSDate *)date {
    [pause configureWithEnd:date andTimeZone:[[NSTimeZone systemTimeZone] name]];
    if ([pause minutesPaused] < 1) {
        [pause.managedObjectContext deleteObject:pause];
    }
}

+ (void)applyDefaultPauseSettingsToEntry:(DayEntry *)entry {
    NSDate *start;
    NSDate *end;
    
    if(![[SettingsManager new] isDefaultPause]) {
        return; //EXIT
    }
    
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *checkInComponents = [calendar components:CALENDARUNITCOMPONENTS
                                                      fromDate:entry.checkInTime];

    NSUInteger weekday = checkInComponents.weekday;
    NSUInteger actualWeekDay = [AXUtility standardizeWeekDayFromDateComponents:weekday];
    
    start = [[SettingsManager new] defaultPauseStartForWeekday:actualWeekDay];
    end = [[SettingsManager new] defaultPauseEndForWeekday:actualWeekDay];
    
    NSDateComponents *startDefaultPauseComponents = [calendar
                                                     components:CALENDARUNITCOMPONENTS
                                                     fromDate:start];
    NSDateComponents *endDefaultPauseComponents = [calendar
                                                   components:CALENDARUNITCOMPONENTS
                                                   fromDate:end];
    
    startDefaultPauseComponents.year = checkInComponents.year;
    startDefaultPauseComponents.month = checkInComponents.month;
    startDefaultPauseComponents.day = checkInComponents.day;
    startDefaultPauseComponents.timeZone = checkInComponents.timeZone;
    
    endDefaultPauseComponents.year = checkInComponents.year;
    endDefaultPauseComponents.month = checkInComponents.month;
    endDefaultPauseComponents.day = checkInComponents.day;
    endDefaultPauseComponents.timeZone = checkInComponents.timeZone;
    
    NSDate *startDefaultPause = [calendar dateFromComponents:startDefaultPauseComponents];
    NSDate *endDefaultPause = [calendar dateFromComponents:endDefaultPauseComponents];
    NSDate *checkInTime = entry.checkInTime;
    NSDate *checkOutTime = entry.checkOutTime;
    BOOL mayInsertDefaultPause = NO;

    if (checkOutTime == nil) {
        return;
    }
    
    if ([startDefaultPause isWithinBeginDate:checkInTime andEndDate:checkOutTime] &&
        [endDefaultPause isWithinBeginDate:checkInTime andEndDate:checkOutTime]) { // default pause is within bounds of dayentry
        
        mayInsertDefaultPause = YES;
        
        for (Pause *pause in entry.pauses) {
            //test whether default pause start or end is within an existing pause
            if ([startDefaultPause isWithinBeginDate:pause.startTime andEndDate:pause.endTime] &&
                [endDefaultPause isWithinBeginDate:pause.startTime andEndDate:pause.endTime]) {
                
                mayInsertDefaultPause = NO;
                break;
            }
            //test whether a regular pause cuts the default pause
            if ([pause.startTime compare:startDefaultPause] != NSOrderedAscending &&
                [pause.startTime compare:endDefaultPause] != NSOrderedDescending &&
                [pause.startTime compare:startDefaultPause] != NSOrderedAscending &&
                [pause.startTime compare:endDefaultPause] != NSOrderedDescending) {
                
                mayInsertDefaultPause = NO;
                break;
            }
        }
    }
    
    if (mayInsertDefaultPause) {
        Pause *defaultPause = [entry.managedObjectContext newPauseEntityWithStart:startDefaultPause];
        [defaultPause configureWithEnd:endDefaultPause
                           andTimeZone:[[NSTimeZone systemTimeZone] name]];
        [entry addPausesObject:defaultPause];
    }
}

@end
