////
////  DayType.m
////  aXTimes
////
////  Created by Christopher Füseschi on 01/06/16.
////  Copyright © 2016 aXimilate. All rights reserved.
////
//
//#import "DayType.h"
//
//#import "UIImage+AXUIImageCategory.h"
//
//@implementation DayType
//
//- (void)setCalendarDate:(NSDate *)calendarDate {
//    [self willChangeValueForKey:@"calendarDate"];
//    [self setPrimitiveValue:calendarDate forKey:@"calendarDate"];
//    [self didChangeValueForKey:@"calendarDate"];
//    
//    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
//    NSString *systemTimeZoneName = [timeZone name];
//    [self setCalendarDateTimeZone:systemTimeZoneName];
//    
//    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    [dateFormatter setLocale:[NSLocale currentLocale]];
//    [dateFormatter setDateFormat:@"yyyy_MM_dd"];
//    [self setCalendarDay:[dateFormatter stringFromDate:calendarDate]];
//    
//    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
//    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//    
//    [dateFormatter setDateFormat:@"yyyy"];
//    NSNumber *numberToSave = [numberFormatter numberFromString:[dateFormatter stringFromDate:calendarDate]];
//    [self setYear:numberToSave];
//    
//    [dateFormatter setDateFormat:@"MM"];
//    numberToSave = [numberFormatter numberFromString:[dateFormatter stringFromDate:calendarDate]];
//    [self setMonth:numberToSave];
//    
//    [dateFormatter setDateFormat:@"dd"];
//    numberToSave = [numberFormatter numberFromString:[dateFormatter stringFromDate:calendarDate]];
//    [self setDay:numberToSave];
//}
//
//- (NSString *)dayKey {
//    return [self.calendarDay stringByReplacingOccurrencesOfString:@"_" withString:@""];
//}
//
//
//- (void)setWork {
//    [self setWork:@YES];
//    [self setVacation:@NO];
//    [self setSickness:@NO];
//    [self setHoliday:@NO];
//}
//
//- (void)setVacation; {
//    [self setWork:@YES];
//    [self setVacation:@YES];
//    [self setSickness:@NO];
//    [self setHoliday:@NO];
//}
//
//- (void)setHoliday {
//    [self setWork:@NO];
//    [self setVacation:@NO];
//    [self setSickness:@NO];
//    [self setHoliday:@YES];
//}
//
//- (void)setSickness {
//    [self setWork:@YES];
//    [self setVacation:@NO];
//    [self setSickness:@YES];
//    [self setHoliday:@NO];
//}
//
//- (void)setOff {
//    [self setWork:@NO];
//    [self setVacation:@NO];
//    [self setSickness:@NO];
//    [self setHoliday:@NO];
//}
//
//- (BOOL)isOff {
//    if (![self.work boolValue] &&
//        ![self.holiday boolValue] &&
//        ![self.vacation boolValue] &&
//        ![self.sickness boolValue]) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//- (BOOL)isNotWorking {
//    if ([[self holiday] boolValue]) {
//        return YES;
//    }
//    
//    if (![[self work] boolValue] &&
//        ![[self vacation] boolValue] &&
//        ![[self sickness] boolValue] &&
//        ![[self holiday] boolValue]) {
//        return YES;
//    }
//    return NO;
//}
//
//
//- (UIColor *)primaryColor {
//    if ([[self vacation] boolValue]) {
//        return C_CANTALOUPE;
//    } else if ([[self sickness] boolValue]) {
//        return C_SALMON;
//    } else if ([[self holiday] boolValue]) {
//        return C_CLOVER;
//    } else if ([self isOff]) {
//        return NOTWORKINGCELLCOLOR;
//    } else {
//        return [UIColor whiteColor];
//    }
//}
//
//- (UIImage *)image {
//    if ([[self vacation] boolValue]) {
//        return [DayType vacationImage];
//    } else if ([[self sickness] boolValue]) {
//        return [DayType sicknessImage];
//    } else if ([[self holiday] boolValue]) {
//        return [DayType holidayImage];
//    } else if ([self isOff]) {
//        return [DayType offImage];
//    } else {
//        return [DayType workImage];
//    }
//}
//
//- (NSString *)title {
//    if ([[self vacation] boolValue]) {
//        return NSLS_VACATION;
//    } else if ([[self sickness] boolValue]) {
//        return NSLS_SICKNESS;
//    } else if ([[self holiday] boolValue]) {
//        return NSLS_HOLIDAY_SINGULAR;
//    } else if ([self isOff]) {
//        return NSLS_DAYOFF_SINGULAR;
//    } else {
//        return NSLS_WORKDAY;
//    }
//}
//
//+ (UIImage *)vacationImage {
//    static UIImage *_image;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _image = [[UIImage imageNamed:@"sun-7.png"] imageWithBurnTint:C_CANTALOUPE];
//    });
//    
//    return _image;
//}
//
//+ (UIImage *)sicknessImage {
//    static UIImage *_image;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _image = [[UIImage imageNamed:@"medical-box-7.png"] imageWithBurnTint:C_SALMON];
//    });
//    
//    return _image;
//}
//
//+ (UIImage *)holidayImage {
//    static UIImage *_image;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _image = [[UIImage imageNamed:@"candle_black_2.png"] imageWithBurnTint:C_CLOVER];
//    });
//    
//    return _image;
//}
//
//+ (UIImage *)workImage {
//    static UIImage *_image;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _image = [[UIImage imageNamed:@"work_icon.png.png"] imageWithBurnTint:SELECTIONCOLOR];
//    });
//    
//    return _image;
//}
//
//+ (UIImage *)offImage {
//    static UIImage *_image;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _image = [[UIImage imageNamed:@"clock_black_2.png"] imageWithBurnTint:GLOBALFONTCOLOR];
//    });
//    
//    return _image;
//}
//
//
//@end
