//
//  AXSettings.m
//  aXTimes
//
//  Created by fuesec on 6/11/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXSettingsManager.h"
#import "AXUtility.h"

@implementation AXSettingsManager

+ (TimeFormatting)timeFormatting {
    return [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_TIME_FORMATTING];
}

+ (void)setTimeFormatting:(TimeFormatting)timeFormatting  {
    [[NSUserDefaults standardUserDefaults] setInteger:timeFormatting forKey:SETTINGS_TIME_FORMATTING];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - getters
- (NSString *)getCurrencyIso {
	return [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_CURRENCYISO];
}

- (NSString *)getExportLanguageLocale {
	return [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_EXPORT_LANGUAGELOCALE];
}

- (NSString *)getDefaultComment {
	return [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_DEFAULTCOMMENT];
}

- (NSString *)getExportEmail {
	return [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_EXPORT_EMAIL];
}

- (double)getHourlyWage {
	return [[NSUserDefaults standardUserDefaults] doubleForKey:SETTINGS_HOURLYWAGE];
}

- (double)getHoursPerDay {
	return [[NSUserDefaults standardUserDefaults] doubleForKey:SETTINGS_HOURSPERDAY];
}

- (double)getWorkTimeUnit {
	return [[NSUserDefaults standardUserDefaults] doubleForKey:SETTINGS_WORKTIMEUNIT];
}

- (ROUNDINGBEHAVIOUR)getNetRounding {
	NSUInteger roundingBehaviour = [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_NETROUNDING];

	return roundingBehaviour;
}

- (BOOL)getExportWage {
	return [[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_EXPORT_WAGE];
}

- (NSString *)getExportDecimalSeparator {
	return [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_EXPORT_DECIMALSEPARATOR];
}

- (BOOL)getInclTimezone {
	return [[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_EXPORT_INCL_TIMEZONE];
}

- (NSArray<NSNumber *> *)getWorkingweek {
	return [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_WORKINGWEEK];
}

#pragma mark - setters
- (void)setCurrencyIso:(NSString *)isoIdentifier {
	[[NSUserDefaults standardUserDefaults] setValue:isoIdentifier forKey:SETTINGS_CURRENCYISO];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setExportLanguageLocale:(NSString *)locale {
	[[NSUserDefaults standardUserDefaults] setValue:locale forKey:SETTINGS_EXPORT_LANGUAGELOCALE];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setDefaultComment:(NSString *)comment {
	[[NSUserDefaults standardUserDefaults] setValue:comment forKey:SETTINGS_DEFAULTCOMMENT];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setExportEmail:(NSString *)exportEmail {
	[[NSUserDefaults standardUserDefaults] setValue:exportEmail forKey:SETTINGS_EXPORT_EMAIL];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setHourlyWage:(double)hourlyWage {
	[[NSUserDefaults standardUserDefaults] setDouble:hourlyWage forKey:SETTINGS_HOURLYWAGE];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setHoursPerDay:(double)hoursPerDay {
	[[NSUserDefaults standardUserDefaults] setDouble:hoursPerDay forKey:SETTINGS_HOURSPERDAY];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setWorkTimeUnit:(double)timeUnit {
	[[NSUserDefaults standardUserDefaults] setDouble:timeUnit forKey:SETTINGS_WORKTIMEUNIT];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setNetRounding:(ROUNDINGBEHAVIOUR)rounding {
	[[NSUserDefaults standardUserDefaults] setInteger:rounding forKey:SETTINGS_NETROUNDING];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setExportWage:(BOOL)exportIt {
	[[NSUserDefaults standardUserDefaults] setBool:exportIt forKey:SETTINGS_EXPORT_WAGE];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setExportDecimalSeparator:(NSString *)separator {
	[[NSUserDefaults standardUserDefaults] setValue:separator forKey:SETTINGS_EXPORT_DECIMALSEPARATOR];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setInclTimezone:(BOOL)inclTimezone {
	[[NSUserDefaults standardUserDefaults] setBool:inclTimezone forKey:SETTINGS_EXPORT_INCL_TIMEZONE];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setWorkingweek:(NSArray *)workingweekArray {
	[[NSUserDefaults standardUserDefaults] setValue:workingweekArray forKey:SETTINGS_WORKINGWEEK];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - custom getters
- (NSString *)getHourlyWageDisplayValue {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];

	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	[numberFormatter setMaximumFractionDigits:2];
	[numberFormatter setMinimumFractionDigits:2];
	return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[self getHourlyWage]]];
}

- (NSString *)getHoursPerDayDisplayValue {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];

	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	[numberFormatter setMaximumFractionDigits:2];
	[numberFormatter setMinimumFractionDigits:2];
	return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[self getHoursPerDay]]];
}

- (NSString *)getWorkTimeUnitDisplayValue {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];

	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	return [NSString stringWithFormat:@"%@ %@", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[self getWorkTimeUnit]]], NSLS_MINUTE_SHORT];
}

- (NSString *)getNetRoundingDisplayValue {
	NSArray *array = ROUNDINGBEHAVIOURNAMES;
	ROUNDINGBEHAVIOUR roundingBehaviour = [self getNetRounding];

	return array[roundingBehaviour];
}

- (NSString *)getExportLanguageLocaleDisplayValue {
	AXUtility *utility = [AXUtility new];
	NSString *exportLanguageLocale = [self getExportLanguageLocale];
	NSString *returnString = [utility localeToExportLanguageString:exportLanguageLocale];

	return returnString;
}

- (NSNumber *)getHourlyWageAsNumber {
	return [NSNumber numberWithDouble:[self getHourlyWage]];
}

- (NSString *)getExportDecimalSeparatorDisplayValue {
	if ([[self getExportDecimalSeparator] isEqualToString:NULLSTRING]) {
		return [NSString stringWithFormat:@" %@ (%@)", DEFAULTSTRING, [[NSNumberFormatter new] decimalSeparator]];
	} else {
		return [self getExportDecimalSeparator];
	}
}

#pragma mark - default pause
- (BOOL)isDefaultPause {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_DEFAULTPAUSE];
}

- (void)setDefaultPause:(BOOL)defaultPause {
    [[NSUserDefaults standardUserDefaults] setBool:defaultPause forKey:SETTINGS_DEFAULTPAUSE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)getDefaultPauseStart {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_DEFAULTPAUSESTART];
}

- (void)setDefaultPauseStart:(NSDate *)startDate {
    [[NSUserDefaults standardUserDefaults] setValue:startDate forKey:SETTINGS_DEFAULTPAUSESTART];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)getDefaultPauseEnd {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_DEFAULTPAUSEEND];
}

- (void)setDefaultPauseEnd:(NSDate *)endDate {
    [[NSUserDefaults standardUserDefaults] setValue:endDate forKey:SETTINGS_DEFAULTPAUSEEND];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
