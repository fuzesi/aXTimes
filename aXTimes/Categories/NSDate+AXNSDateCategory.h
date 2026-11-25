//
//  NSDate+AXNSDateCategory.h
//  aXTimes
//
//  Created by fuesec on 6/30/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

@interface NSDate (AXNSDateCategory)

- (NSString *)formatAs_dd;
- (NSString *)formatAs_MM;
- (NSString *)formatAs_yyyy;
- (NSString *)formatAs_weekOfYear_yearForWeekOfYear;

- (NSString *)dayKey;

- (BOOL)isSameDay:(NSDate *)date;
- (BOOL)isSameDay:(NSDate *)date withReceiverTimeZoneName:(NSString *)receiverTimeZoneName andInputTimeZoneName:(NSString *)inputTimeZoneName;

- (BOOL)isSameMonth:(NSDate *)date;
- (BOOL)isSameMonth:(NSDate *)date withReceiverTimeZoneName:(NSString *)receiverTimeZoneName andInputTimeZoneName:(NSString *)inputTimeZoneName;

- (NSDate *)updateDayMonthYearComponentWithDate:(NSDate *)date;
- (BOOL)isSameMonthOnlyMonthComponent:(NSDate *)date;
- (NSDate *)truncateHours;

- (BOOL)isWithinBeginDate:(NSDate *)begin andEndDate:(NSDate *)end;
- (NSDate *)addMinutes:(NSInteger)minutes;
- (NSDate *)addDays:(NSInteger)days;
- (NSDate *)addMonths:(NSInteger)months;
- (NSDate *)addYears:(NSInteger)years;

- (NSDate *)truncateSeconds;
- (NSDate *)truncateHours;

- (NSInteger)daysBetween:(NSDate *)toDateTime;
- (NSDate *)weekBeginning;
- (NSDate *)monthBeginning;
- (NSUInteger)daysInMonth;
- (NSUInteger)daysInYear;

@end
