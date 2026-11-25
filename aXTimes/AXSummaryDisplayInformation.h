//
//  AXSummaryDisplayInformation.h
//  aXTimes
//
//  Created by fuesec on 4/8/14.
//  Copyright (c) 2014 aXimilate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AXSummaryDisplayInformation : NSObject

@property (strong, nonatomic) NSString *dayOff;
@property (strong, nonatomic) NSString *publicHolidays;
@property (strong, nonatomic) NSString *vacation;
@property (strong, nonatomic) NSString *sickness;
@property (strong, nonatomic) NSString *plannedWorkingTimeHours;
@property (strong, nonatomic) NSString *plannedWorkingTimeDays;

@property (strong, nonatomic) NSString *netWorkingTimeHours;
@property (strong, nonatomic) NSString *netWorkingTimeDays;
@property (strong, nonatomic) NSString *pauseTimeHours;
@property (strong, nonatomic) NSString *overtimeHours;
@property (strong, nonatomic) NSString *overtimeDays;
@property BOOL overtimeUseColor;
@property (strong, nonatomic) UIColor *overTimeColor;
@property (strong, nonatomic) NSString *averageTimePerDay;
@property (strong, nonatomic) NSString *income;
@property (strong, nonatomic) NSString *remainingBudget;

@end
