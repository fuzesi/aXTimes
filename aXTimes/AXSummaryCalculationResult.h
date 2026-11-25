//
//  AXSummaryCalculationResult.h
//  aXTimes
//
//  Created by Christopher Füseschi on 17/08/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXSummaryDisplayInformation.h"
#import "AXDayTypesCalculationResult.h"

@interface AXSummaryCalculationResult : NSObject

@property (strong, nonatomic) AXSummaryDisplayInformation *displayInfo;
@property (strong, nonatomic) AXDayTypesCalculationResult *dayTypecalculationsResult;

@property (strong, nonatomic) NSNumber *targetTimeInHours;
@property (strong, nonatomic) NSNumber *netWorkingTimeHours;
@property (strong, nonatomic) NSNumber *netWorkingTimeDays;
@property (strong, nonatomic) NSNumber *pauseTimeHours;
@property (strong, nonatomic) NSNumber *overtimeHours;
@property (strong, nonatomic) NSNumber *overtimeDays;
@property (strong, nonatomic) NSNumber *averageTimePerDay;
@property (strong, nonatomic) NSNumber *income;
@property (strong, nonatomic) NSNumber *remainingBudget;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithDayTypesCalculationResult:(AXDayTypesCalculationResult *)dayTypecalculationsResult NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCalculationResults:(NSArray<AXSummaryCalculationResult *>*)calculationResults
             withDayTypesCalculationResult:(AXDayTypesCalculationResult *)dayTypecalculationsResult;
- (void)createDisplayInformation;

@end
