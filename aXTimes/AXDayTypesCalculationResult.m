//
//  AXDayTypesCalculationResult.m
//  aXTimes
//
//  Created by fuesec on 4/8/14.
//  Copyright (c) 2014 aXimilate. All rights reserved.
//

#import "AXDayTypesCalculationResult.h"

@implementation AXDayTypesCalculationResult

- (id)init {
    self = [super init];
    
    if(self){
        self.wholeRangeTargetDays = @(0);
        self.limitedRangeTargetDays = @(0);
        self.sicknessDays = @(0);
        self.vacationDays = @(0);
        self.pulicHolidaysDays = @(0);
        self.dayOffDays = @(0);
        self.isRelevantForYearOvertime = @(0);
    }
    
    return self;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"Whole Range Target Days %@ \nLimited Range Target Days %@ \nSickness Days %@ \nVacation Days %@ \nPublic Holidays Days %@ \nDay Off Days %@ \nIs Relevant For Year Overtime %@", self.wholeRangeTargetDays, self.limitedRangeTargetDays, self.sicknessDays, self.vacationDays, self.pulicHolidaysDays, self.dayOffDays, self.isRelevantForYearOvertime];
}

@end
