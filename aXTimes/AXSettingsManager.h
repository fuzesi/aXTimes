//
//  AXSettingsManager.h
//  aXTimes
//
//  Created by fuesec on 6/11/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AXSettingsManager : NSObject

+ (TimeFormatting)timeFormatting;
+ (void)setTimeFormatting:(TimeFormatting)timeFormatting;


#pragma mark - default pause
- (BOOL)isDefaultPause;
- (void)setDefaultPause:(BOOL)defaultPause;
- (NSDate *)getDefaultPauseStart;
- (void)setDefaultPauseStart:(NSDate *)startDate;
- (NSDate *)getDefaultPauseEnd;
- (void)setDefaultPauseEnd:(NSDate *)endDate;

#pragma mark - getters
- (NSString *)getCurrencyIso;
- (NSString *)getExportLanguageLocale;
- (NSString *)getDefaultComment;
- (NSString *)getExportEmail;
- (double)getHourlyWage;
- (double)getHoursPerDay;
- (double)getWorkTimeUnit;
- (ROUNDINGBEHAVIOUR)getNetRounding;
- (BOOL)getExportWage;
- (NSString *)getExportDecimalSeparator;
- (BOOL)getInclTimezone;
- (NSArray<NSNumber *> *)getWorkingweek;


#pragma mark - setters
- (void)setCurrencyIso:(NSString *)locale;
- (void)setExportLanguageLocale:(NSString *)locale;
- (void)setDefaultComment:(NSString *)comment;
- (void)setExportEmail:(NSString *)exportEmail;
- (void)setHourlyWage:(double)hourlyWage;
- (void)setHoursPerDay:(double)hoursPerDay;
- (void)setWorkTimeUnit:(double)timeUnit;
- (void)setNetRounding:(ROUNDINGBEHAVIOUR)rounding;
- (void)setExportWage:(BOOL)exportIt;
- (void)setExportDecimalSeparator:(NSString *)separator;
- (void)setInclTimezone:(BOOL)inclTimezone;
- (void)setWorkingweek:(NSArray *)workingweekArray;



#pragma mark - custom getters
- (NSNumber *)getHourlyWageAsNumber;

- (NSString *)getHourlyWageDisplayValue;
- (NSString *)getHoursPerDayDisplayValue;
- (NSString *)getWorkTimeUnitDisplayValue;
- (NSString *)getNetRoundingDisplayValue;
- (NSString *)getExportLanguageLocaleDisplayValue;
- (NSString *)getExportDecimalSeparatorDisplayValue;

@end
