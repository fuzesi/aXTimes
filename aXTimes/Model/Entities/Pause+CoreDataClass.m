////
////  Pause+CoreDataClass.m
////  aXTimes
////
////  Created by Christopher Füseschi on 15/09/2016.
////  Copyright © 2016 aXimilate. All rights reserved.
////
//
//#import "Pause+CoreDataClass.h"
//
//#import "NSNumber+AXNSNumberCategory.h"
//#import "NSDate+AXNSDateCategory.h"
//#import "NSDateFormatter+AXDateFormatters.h"
//
//@implementation Pause
//
//- (void)setStartTime:(NSDate *)startTime {
//    [self willChangeValueForKey:@"startTime"];
//    [self setPrimitiveValue:startTime forKey:@"startTime"];
//    [self didChangeValueForKey:@"startTime"];
//    
//    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
//    NSString *systemTimeZoneName = [timeZone name];
//    [self setStartTimeZone:systemTimeZoneName];
//}
//
//- (void)setEndTime:(NSDate *)endTime {
//    [self willChangeValueForKey:@"endTime"];
//    [self setPrimitiveValue:endTime forKey:@"endTime"];
//    [self didChangeValueForKey:@"endTime"];
//    
//    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
//    NSString *systemTimeZoneName = [timeZone name];
//    [self setEndTimeZone:systemTimeZoneName];
//}
//
//- (NSNumber *)secondsPausedUntilNow {
//    if (self.startTime == nil) {
//        return [NSNumber numberWithInt:0];
//    } else {
//        NSDate *nowDate = [NSDate date];
//        NSTimeInterval distanceBetweenDates = [nowDate timeIntervalSinceDate:self.startTime];
//        return [NSNumber numberWithDouble:distanceBetweenDates];
//    }
//}
//
//- (NSString *)totalTimeUntilNowWithSeconds {
//    return [self.secondsPausedUntilNow numberAsSecondsToCountdownString];
//}
//
//- (double)secondsPaused {
//    if ((self.startTime == nil) || (self.startTime != nil && self.endTime == nil) || (self.startTime == nil && self.endTime == nil)) {
//        return (double)0.0;
//    } else {
//        NSDate *tempCheckin = [self.startTime truncateSeconds];
//        NSDate *tempCheckout = [self.endTime truncateSeconds];
//        NSTimeInterval distanceBetweenDates = [tempCheckout timeIntervalSinceDate:tempCheckin];
//        return distanceBetweenDates;
//    }
//}
//
//- (double)secondsPausedNotZeroed{
//    if ((self.startTime == nil) || (self.startTime != nil && self.endTime == nil) || (self.startTime == nil && self.endTime == nil)) {
//        return (double)0.0;
//    } else {
//        NSTimeInterval distanceBetweenDates = [self.endTime timeIntervalSinceDate:self.startTime];
//        return distanceBetweenDates;
//    }
//}
//
//- (double)minutesPaused {
//    double minutesPaused = ([self secondsPaused] / (double)60.0);
//    
//    return minutesPaused;
//}
//
//- (double)hoursPaused {
//    double hoursPaused = ([self minutesPaused] / (double)60.0);
//    
//    return hoursPaused;
//}
//
//- (NSString *)hoursPausedDisplayValue {
//    return [[NSNumber numberWithDouble:[self hoursPaused]] displayTime];
//}
//
//- (BOOL)isComplete {
//    if (self.startTime != nil &&
//        self.endTime != nil) {
//        return YES;
//    }
//    return NO;
//}
//
//- (BOOL)isCurrentlyRunning {
//    if (self.startTime != nil &&
//        self.endTime == nil) {
//        return YES;
//    }
//    return NO;
//}
//
//- (void)normalize {
//    if (self.startTime) {
//        self.startTime = [self.startTime truncateSeconds];
//    }
//    if (self.endTime) {
//        self.endTime = [self.endTime truncateSeconds];
//    }
//}
//#pragma mark - misc
//
//- (NSString *)timeRangeString:(NSDate *)date {
//    NSString *timeRange = @"";
//    
//    timeRange = [NSString stringWithFormat:@"%@ - ",
//                 [self startTimeDisplayValueForTargetDate:date]];
//    
//    if (self.endTime != nil) {
//        timeRange = [NSString stringWithFormat:@"%@%@",
//                     timeRange,
//                     [self endTimeDisplayValueForTargetDate:date]];
//        
//    }
//    
//    return timeRange;
//}
//
//- (NSString *)startTimeDisplayValueForTargetDate:(NSDate *)date {
//    NSString *value = @"";
//    if (self.startTime != nil) {
//        NSDateFormatter *dateFormatter = nil;
//        if ([self.startTime isSameDay:date
//             withReceiverTimeZoneName:self.startTimeZone
//                 andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
//            dateFormatter = [NSDateFormatter formatter_HH_mm_Static:NO];
//        } else if ([self.startTime
//                    isSameMonth:date
//                    withReceiverTimeZoneName:self.startTimeZone
//                    andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
//            dateFormatter = [NSDateFormatter formatter_HH_mm_d_M_Static:NO];
//        } else {
//            dateFormatter = [NSDateFormatter formatter_HH_mm_d_M_yy_Static:NO];
//        }
//        [dateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:self.startTimeZone]];
//        
//        value = [dateFormatter stringFromDate:self.startTime];
//    }
//    return value;
//}
//
//- (NSString *)endTimeDisplayValueForTargetDate:(NSDate *)date {
//    NSString *value = @"";
//    if (self.endTime != nil) {
//        NSDateFormatter *dateFormatter = nil;
//        if ([self.endTime isSameDay:date
//           withReceiverTimeZoneName:self.endTimeZone
//               andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
//            dateFormatter = [NSDateFormatter formatter_HH_mm_Static:NO];
//        } else if ([self.endTime isSameMonth:date
//                    withReceiverTimeZoneName:self.endTimeZone
//                        andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
//            dateFormatter = [NSDateFormatter formatter_HH_mm_d_M_Static:NO];
//        } else {
//            dateFormatter = [NSDateFormatter formatter_HH_mm_d_M_yy_Static:NO];
//        }
//        [dateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:self.endTimeZone]];
//        
//        value = [dateFormatter stringFromDate:self.endTime];
//    }
//    return value;
//}
//
//@end
