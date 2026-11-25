//
//  AXCpyViewController.m
//  aXTimes
//
//  Created by fuesec on 05/07/15.
//  Copyright (c) 2015 aXimilate. All rights reserved.
//

#import "AXCpyViewController.h"
#import "NSDate+AXNSDateCategory.h"
#import "RESideMenu.h"
#import "AXDayEntryDetailsTableViewController.h"
#import "NSDate+AXNSDateCategory.h"
#import <os/log.h>

@implementation AXCpyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    

    
    self.navigationController.navigationBar.topItem.title = NSLS_COPYENTRY;
    self.view.backgroundColor = GLOBALBACKGROUNDCOLOR2;
    
    self.settingsController = [SettingsManager new];
    self.settingsWorkingweek = [NSMutableArray arrayWithArray:[[SettingsManager new] workingWeek]];
    
    for(NSNumber *n in self.settingsWorkingweek){
        os_log(OS_LOG_DEFAULT, "Number: %@", [n stringValue]);
        
    }
    

    NSDate *now = self.currentDayEntry.checkInTime;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *componentsTomorrow = [[NSDateComponents alloc] init];
    [componentsTomorrow setDay:1]; // Tomorrow
    NSDate *tomorrow = [gregorian dateByAddingComponents:componentsTomorrow toDate:now options:0];
    NSDate *nextPossibleWorkday = tomorrow;
    NSDateFormatter *nowDateFormatter = [[NSDateFormatter alloc] init];
    [nowDateFormatter setDateFormat:@"e"];
    NSInteger weekdayNumber = ((NSInteger)[[nowDateFormatter stringFromDate:tomorrow] integerValue]) - 1; // 0-6

    
    
    os_log(OS_LOG_DEFAULT, "the day is: %li",(long)weekdayNumber);
    
    int upperBound = 10;
    int offset = 0;
    while((upperBound-- > 0) && ( [([self.settingsWorkingweek objectAtIndex:(weekdayNumber)]) intValue] != 1)){
        weekdayNumber++;
        weekdayNumber = weekdayNumber % 7;
        offset++;
    }
    os_log(OS_LOG_DEFAULT, "the day is: %li",(long)weekdayNumber);
    os_log(OS_LOG_DEFAULT, "offset: %li",(long)offset);
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:offset]; // Tomorrow
    NSDate *offsetDay = [gregorian dateByAddingComponents:components toDate:tomorrow options:0];
    
    
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    NSDate *nowDate = [NSDate date];
    self.datePicker.maximumDate = nowDate;
    
    [self.datePicker
     setDate:offsetDay
     animated:YES];
    
}

- (IBAction)doneAction:(id)sender {
    BOOL notAllowedToCopy = NO;
    NSString *alertMessage = @"";
    
    NSDate *date = self.datePicker.date;
    
    NSDate *targetCheckInTime = [self.currentDayEntry.checkInTime updateDayMonthYearComponentWithDate:date];
    NSTimeInterval difference = [self.currentDayEntry.checkOutTime timeIntervalSinceDate:self.currentDayEntry.checkInTime];
    NSDate *targetCheckOutTime  = [NSDate dateWithTimeInterval:difference sinceDate:targetCheckInTime];
    
    DayEntry *dayEntry = [[AXDataStore sharedInstance]
                          previousDayEntryWithCheckinLesser:targetCheckInTime];
    
    if (dayEntry != nil && dayEntry.checkOutTime != nil &&
        [dayEntry.checkOutTime compare:targetCheckInTime] != NSOrderedAscending) {
        notAllowedToCopy = YES;
        alertMessage = NSLS_CANTCOPY_OVERLAP;
    }
    
    dayEntry = [[AXDataStore sharedInstance]
                previousDayEntryWithCheckinLesser:targetCheckOutTime];
    
    if (dayEntry != nil && dayEntry.checkInTime != nil &&
        [dayEntry.checkInTime compare:targetCheckInTime] != NSOrderedAscending) {
        notAllowedToCopy = YES;
        alertMessage = NSLS_CANTCOPY_OVERLAP;
    }
    
    NSDate *nowDate = [NSDate date];
    if ([targetCheckInTime compare:nowDate] != NSOrderedAscending ||
        [targetCheckOutTime compare:nowDate] != NSOrderedAscending) {
        notAllowedToCopy = YES;
        alertMessage = NSLS_CANTCOPY_FUTURE;
    }
    
    
    if (notAllowedToCopy) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLS_WARNINGPOPUP
                              message:alertMessage
                              delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:NSLS_OKPOPUP, nil];
        [alert show];
    }
    
    UINavigationController *navigationController;

    if ([self.presentingViewController isKindOfClass:[RESideMenu class]]) {
        RESideMenu *sideMenu = (RESideMenu *)self.presentingViewController;
        if ([sideMenu.contentViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBarController = (UITabBarController *)sideMenu.contentViewController;
            if ([tabBarController.viewControllers[1] isKindOfClass:[UINavigationController class]]) {
                navigationController = (UINavigationController *)tabBarController.viewControllers[1];
            }
        }
    }
    
    if (navigationController) {
        [navigationController popViewControllerAnimated:NO];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if (!notAllowedToCopy) {
            DayEntry *entry = [self.currentDayEntry deepCopyToTargetDate:date];

            [[NSNotificationCenter defaultCenter]
             postNotificationName:NOTIFICATION_JUMP_TO_DATE
             object:entry.checkInTime];
            
            if (navigationController) {
                AXDayEntryDetailsTableViewController *aXDayEntryDetailsTableViewController;
                aXDayEntryDetailsTableViewController = [AXDayEntryDetailsTableViewController new];
                aXDayEntryDetailsTableViewController.dayEntry = entry;
                
                [navigationController pushViewController:aXDayEntryDetailsTableViewController
                                                animated:YES];
            }
        }
    }];
}

- (IBAction)cancelAction:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
