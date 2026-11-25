//
//  AXAttendanceRecorder.h
//  aXTimes
//
//  Created by fuesec on 07/10/15.
//  Copyright © 2015 aXimilate. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface AXAttendanceRecorder : NSObject

+ (void)performCheckInForEntry:(DayEntry *)entry
                      withTime:(NSDate *)date
                   withProject:(nullable Project *)project;
+ (void)performCheckOutForEntry:(DayEntry *)entry
                       withTime:(NSDate *)checkOutTime;
+ (void)applyDefaultPauseSettingsToEntry:(DayEntry *)entry;
NS_ASSUME_NONNULL_END

@end
