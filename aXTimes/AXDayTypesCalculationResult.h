//
//  AXDayTypesCalculationResult.h
//  aXTimes
//
//  Created by fuesec on 4/8/14.
//  Copyright (c) 2014 aXimilate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AXDayTypesCalculationResult : NSObject

@property (strong, nonatomic) NSNumber *wholeRangeTargetDays;
@property (strong, nonatomic) NSNumber *limitedRangeTargetDays;
@property (strong, nonatomic) NSNumber *vacationDays;
@property (strong, nonatomic) NSNumber *sicknessDays;
@property (strong, nonatomic) NSNumber *pulicHolidaysDays;
@property (strong, nonatomic) NSNumber *dayOffDays;
@property (strong, nonatomic) NSNumber *isRelevantForYearOvertime;

@end
