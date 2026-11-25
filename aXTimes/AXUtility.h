//
//  AXUtility.h
//  aXTimes
//
//  Created by fuesec on 5/21/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//


@interface AXUtility : NSObject

+ (NSString *)localeToExportLanguageString:(NSString *)localeString;

+ (NSUInteger)standardizeWeekDayFromDateComponents:(NSUInteger)weekDayFromComponents;

+ (void)dayTypeChangedWithIndex:(NSInteger)selectedSegment withDate:(NSDate *)date;

+ (void)dayTypeArrayChanged:(NSInteger)selectedSegment withDateArray:(NSMutableArray *)dateArray;

+ (void)handleCommentChange:(DayEntry *)dayEntry andText:(NSString *)textViewString;

@end
