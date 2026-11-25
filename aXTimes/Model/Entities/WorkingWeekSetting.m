////
////  WorkingWeekSetting.m
////  aXTimes
////
////  Created by Christopher Füseschi on 01/06/16.
////  Copyright © 2016 aXimilate. All rights reserved.
////
//
//#import "WorkingWeekSetting.h"
//
//@implementation WorkingWeekSetting
//
//- (void)setValidUntil:(NSDate *)calendarDate {
//    [self willChangeValueForKey:@"validUntil"];
//    [self setPrimitiveValue:calendarDate forKey:@"validUntil"];
//    [self didChangeValueForKey:@"validUntil"];
//    
//    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
//    NSString *systemTimeZoneName = [timeZone name];
//    [self setValidUntilTimeZone:systemTimeZoneName];
//    
//    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    [dateFormatter setLocale:[NSLocale currentLocale]];
//    [dateFormatter setDateFormat:@"yyyy_MM_dd"];
//    [self setValidUntilString:[dateFormatter stringFromDate:calendarDate]];
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
//    return [self.validUntilString stringByReplacingOccurrencesOfString:@"_" withString:@""];
//}
//
//
//@end
