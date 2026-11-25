////
////  DayType.h
////  aXTimes
////
////  Created by Christopher Füseschi on 01/06/16.
////  Copyright © 2016 aXimilate. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>
//
//typedef NS_ENUM (NSInteger, DayTypus) {
//    DayTypusNotSpecified = -2,
//    DayTypusNoSelectionIsWork = -1,
//    DayTypusNotAWorkingDay = 0,
//    DayTypusHoliday = 1,
//    DayTypusVacationDay = 2,
//    DayTypusSickDay = 3
//};
//
//NS_ASSUME_NONNULL_BEGIN
//
//@class UIImage;
//
//@interface DayType : NSManagedObject
//
//- (void)setCalendarDate:(NSDate *)calendarDate;
//- (NSString *)dayKey;
//
//- (void)setWork;
//- (void)setVacation;
//- (void)setHoliday;
//- (void)setSickness;
//- (void)setOff;
//- (BOOL)isOff;
//
//- (BOOL)isNotWorking;
//- (UIColor *)primaryColor;
//- (UIImage *)image;
//- (NSString *)title;
//
//+ (UIImage *)workImage;
//+ (UIImage *)offImage;
//
//@end
//
//NS_ASSUME_NONNULL_END
//
//#import "DayType+CoreDataProperties.h"
