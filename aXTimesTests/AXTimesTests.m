//
//  AXTimesTests.m
//  aXTimes
//
//  Created by fuesec on 24/09/14.
//  Copyright (c) 2014 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
//#import "AXDataStore.h"
//import "DayEntry.h"

@interface AXTimesTests : XCTestCase
//@property (nonatomic, strong) DayEntry *startWeekDayEntry;
//@property (nonatomic, strong) DayEntry *endWeekDayEntry;
@property (nonatomic, strong) NSDate *midWeekDate;

@end

@implementation AXTimesTests

- (void)setUp
{
    [super setUp];
    
    //    NSDate * now = [NSDate date];
    //    NSTimeInterval timeSince1970 = [now timeIntervalSince1970];
    //    double asdf = fmod(timeSince1970, 1);
    //    float asdf2 = fmod(timeSince1970, 1);
    //
    //    NSTimeInterval timeSince19702 = timeSince1970- fmod(timeSince1970, 1); // subtract away any extra seconds
    //
    //    NSDate *nowMinus = [NSDate dateWithTimeIntervalSince1970:timeSince19702];
    //
    //    NSTimeInterval timeSince19703 = [nowMinus timeIntervalSince1970];
    
}

- (void)tearDown
{
//    NSArray * dayEntriesArray = [[AXDataStore sharedInstance] getAllManagedObjectsForClass:[DayEntry class]];
//    for (DayEntry * dayEntry in dayEntriesArray){
//        [[AXDataStore sharedInstance] deleteObject:dayEntry];
//    }
    [super tearDown];
}

- (void)testWeekBorders {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [cal setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSDateComponents *components = [NSDateComponents new];
    [components setMonth:10];
    [components setDay:28];
    [components setYear:2013];
    [components setMinute:0];
    [components setHour:0];
    [components setSecond:0];
    //    [components setTimeZone:[NSTimeZone systemTimeZone]];
    
//    NSDate *checkInStartWeek = [cal dateFromComponents:components];
    
    [components setHour:8];
//    NSDate *checkOutStartWeek = [cal dateFromComponents:components];
    
    [components setMonth:11];
    [components setDay:1];
    
    self.midWeekDate = [NSDate dateWithTimeInterval:0.999 sinceDate:[cal dateFromComponents:components]];
    
    [components setDay:3];
    [components setMinute:59];
    [components setHour:23];
    [components setSecond:59];
//    NSDate *checkInEndWeek = [cal dateFromComponents:components];
    
//    NSDate *checkOutEndWeek = [cal dateFromComponents:components];
    
    
    
//    self.startWeekDayEntry = [[AXDataStore sharedInstance] createDayEntry];
//    
//    self.startWeekDayEntry.checkInTime = checkInStartWeek;
//    self.startWeekDayEntry.checkOutTime = checkOutStartWeek;
//    
//    self.endWeekDayEntry = [[AXDataStore sharedInstance] createDayEntry];
//    
//    
//    self.endWeekDayEntry.checkInTime = [NSDate dateWithTimeInterval:0.999 sinceDate:checkInEndWeek];
//    
//    self.endWeekDayEntry.checkOutTime = self.endWeekDayEntry.checkInTime;
//    
//    XCTAssertNotNil(self.startWeekDayEntry, @"DayEntry is nil");
//    XCTAssertNotNil(self.startWeekDayEntry.checkInTime, @"DayEntry.checkInTime is nil");
//    XCTAssertNotNil(self.startWeekDayEntry.checkOutTime, @"DayEntry.checkOutTime is nil");
//    
//    XCTAssertNotNil(self.endWeekDayEntry, @"DayEntry is nil");
//    XCTAssertNotNil(self.endWeekDayEntry.checkInTime, @"DayEntry.checkInTime is nil");
//    XCTAssertNotNil(self.endWeekDayEntry.checkOutTime, @"DayEntry.checkOutTime is nil");
//    
//    XCTAssertNotNil(self.midWeekDate, @"Mid week date is nil");
//    
//    NSArray * dayEntriesArray = [[AXDataStore sharedInstance] getListDayEntryForWeek:self.midWeekDate];
//    NSLog(@"%@", [NSString stringWithFormat:@"%lu", (unsigned long)dayEntriesArray.count]);
//    NSDate *nowDate= [NSDate date];
//    NSDateFormatter *dayFormatter = [NSDateFormatter new];
//    [dayFormatter setLocale:[NSLocale currentLocale]];
//    [dayFormatter setDateFormat:@"yyyy_MM_dd__HH"];
//    NSLog(@"%@", [dayFormatter stringFromDate:nowDate]);
//    XCTAssertTrue(dayEntriesArray.count == 2, @"Not both DayEntries were found");
//    
//    [[AXDataStore sharedInstance]  deleteObject:self.startWeekDayEntry];
//    [[AXDataStore sharedInstance]  deleteObject:self.endWeekDayEntry];
//    
//    dayEntriesArray = [[AXDataStore sharedInstance] getListDayEntryForWeek:self.midWeekDate];
//    XCTAssertTrue(dayEntriesArray.count == 0, @"Not both DayEntries were found");
    
}

- (void) testNetHourRounding{
    double netHours = 2.5555555;
    double roundedValue = round(100 * netHours);
    double returnValue = roundedValue/ 100;
    XCTAssertTrue(returnValue == 2.56, @"Net rounding broken");
    
}

- (void)testMonthBorders
{
    //    STFail(@"Unit tests are not implemented yet in AllTimesTests");
}

- (void)testYearBorders
{
    //    STFail(@"Unit tests are not implemented yet in AllTimesTests");
}


@end
