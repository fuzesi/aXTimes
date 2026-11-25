//
//  AXTimeLineViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 02/06/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXTimeLineViewController.h"
#import "NSDate+DDCalendar.h"
#import "DDCalendarEvent.h"
#import "EventView.h"
#import "AXDayEntryDetailsTableViewController.h"

@interface AXTimeLineViewController ()
@property(strong, nonatomic) DDCalendarView *dDCalendarView;
@end

@implementation AXTimeLineViewController

#pragma mark - lifecycle view

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = GLOBALBACKGROUNDCOLOR;
    
    self.dDCalendarView = [DDCalendarView new];
    self.dDCalendarView.numberOfDays = 1;
    self.dDCalendarView.showsTimeMarker = YES;
    self.dDCalendarView.showsDayName = NO;
    self.dDCalendarView.showsTimeMarker = NO;
//    self.dDCalendarView.showsTomorrow = NO;
    self.dDCalendarView.date = self.date;
    self.dDCalendarView.delegate = self;
    self.dDCalendarView.dataSource = self;
    
    [self refresh];

    [self.view addSubview:self.dDCalendarView];
    self.dDCalendarView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.dDCalendarView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.dDCalendarView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.dDCalendarView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.dDCalendarView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

#pragma mark - private methods

- (void)refresh {
    [self.dDCalendarView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.dDCalendarView scrollDateToVisible:self.date animated:NO];
    });
}

#pragma mark DDCalendarViewDelegate

- (void)calendarView:(DDCalendarView * _Nonnull)view focussedOnDay:(NSDate * _Nonnull)date {
//    if(view.numberOfDays > 1) {
//        NSDate *toDate = [date dateByAddingTimeInterval:(view.numberOfDays-1) * (60*60*24)];
//        self.dayLabel.text = [NSString stringWithFormat:@"%@ - %@", date.stringWithDateOnly, toDate.stringWithDateOnly];
//    }
//    else {
//        self.dayLabel.text = date.stringWithDateOnly;
//    }
}

- (void)calendarView:(DDCalendarView * _Nonnull)view didSelectEvent:(id<DDCalendarEventProtocol> _Nonnull)event {
    NSLog(@"%@", event);
    AXDayEntryDetailsTableViewController *aXDayEntryDetailsTableViewController;
    aXDayEntryDetailsTableViewController = [AXDayEntryDetailsTableViewController new];
//    aXDayEntryDetailsTableViewController.dayEntry = event;
    
    [self.navigationController pushViewController:aXDayEntryDetailsTableViewController
                                         animated:YES];
}

- (BOOL)calendarView:(DDCalendarView * _Nonnull)view allowEditingEvent:(id<DDCalendarEventProtocol> _Nonnull)event {
    return YES;
}

- (void)calendarView:(DDCalendarView * _Nonnull)view commitEditEvent:(id<DDCalendarEventProtocol> _Nonnull)event {
    NSLog(@"%@", event);
    //should do conflict validation and maybe save ;) or revert :P
}

#pragma mark DDCalendarViewDataSource

- (NSArray<DDCalendarEventProtocol> *)calendarView:(DDCalendarView *)view eventsForDay:(NSDate *)date {
    
    if (![date isEqualDay:self.date]) {
        return nil;
    }
    
    NSMutableArray<DDCalendarEventProtocol> *returnArray = [NSMutableArray<DDCalendarEventProtocol> new];
    for (DayEntry *entry in self.entries) {
//        DDCalendarEvent *event8 = [DDCalendarEvent new];
//        [event8 setTitle: @"test1"];
//        [event8 setDateBegin:entry.checkInTime];
//        [event8 setDateEnd:entry.checkOutTime];
        [returnArray addObject:entry];
    }

    return returnArray;
}

//optionally provide a view
- (DDCalendarEventView *)calendarView:(DDCalendarView *)view viewForEvent:(id<DDCalendarEventProtocol>)event {
    return [[EventView alloc] initWithEvent:event];
}

@end
