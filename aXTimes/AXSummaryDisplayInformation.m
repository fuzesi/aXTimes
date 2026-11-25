//
//  AXSummaryDisplayInformation.m
//  aXTimes
//
//  Created by fuesec on 4/8/14.
//  Copyright (c) 2014 aXimilate. All rights reserved.
//

#import "AXSummaryDisplayInformation.h"

@implementation AXSummaryDisplayInformation

- (id)init {
	self = [super init];
	if (self) {
		self.dayOff = NULLSTRING;
		self.publicHolidays = NULLSTRING;
		self.vacation = NULLSTRING;
		self.plannedWorkingTimeHours = NULLSTRING;
		self.plannedWorkingTimeDays = NULLSTRING;
		self.netWorkingTimeHours = NULLSTRING;
		self.netWorkingTimeDays = NULLSTRING;
        self.pauseTimeHours = NULLSTRING;
		self.overtimeHours = NULLSTRING;
		self.overtimeDays = NULLSTRING;
		self.overtimeUseColor = NO;
		self.overTimeColor = [UIColor blackColor];
		self.averageTimePerDay = NULLSTRING;
		self.sickness = NULLSTRING;
		self.income = NULLSTRING;
        self.remainingBudget = NULLSTRING;
	}
	return self;
}

@end
