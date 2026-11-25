//
//  AXMonthViewController.m
//  aXTimes
//
//  Created by fuesec on 4/29/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXMonthViewController.h"
#import "AXCalendarViewController.h"
#import "AXTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+AXNSDateCategory.h"
#import "AXCalculation.h"
#import "AXSettingsManager.h"
#import "AXUtility.h"
#import "UIImage+AXUIImageCategory.h"

@interface AXMonthViewController ()

@property (strong, nonatomic) NSMutableDictionary *fetchedDayEntries;
@property (strong, nonatomic) NSDateFormatter *dateFormatterForRow;
@property (strong, nonatomic) NSDateFormatter *dateFormatterForRowDetail;
@property (strong, nonatomic) NSDateFormatter *dateFormatterCheckOutForRowDetailDayDifferent;
@property (strong, nonatomic) NSDateFormatter *dateFormatterCheckOutForRowDetailYearDifferent;

@property (strong, nonatomic) AXSettingsManager *settingsController;
@property (strong, nonatomic) UITableView *activeTableViewCenter;
@property (strong, nonatomic) NSLayoutConstraint *activeTableViewContraint;
@property (strong, nonatomic) NSIndexPath *expandedPath;
@property (strong, nonatomic) NSIndexPath *infoPath;
@property (strong, nonatomic) NSArray *dayTypesArray;
@property (strong, nonatomic) NSArray *workSettingsArray;
@property (strong, nonatomic) NSCalendar *gregorianCalendar;
@property (strong, nonatomic) UIImage *upArrow;
@property (strong, nonatomic) UIImage *downArrow;
@property (strong, nonatomic) UIImage *vacationImage;
@property (strong, nonatomic) UIImage *sicknesImage;
@property (strong, nonatomic) UIImage *holidayImage;
@property (strong, nonatomic) NSDateFormatter *simpleDayDateFormatter;
@property (strong, nonatomic) NSDateFormatter *simpleYearDateFormatter;
@property (strong, nonatomic) NSDateFormatter *simpleMonthDateFormatter;
@property (strong, nonatomic) NSArray *fromUserSettingsWorkingWeekArray;
@property (strong, nonatomic) NSDateFormatter *calendarDateFormatter;
@property (strong, nonatomic) UIColor *colorGlobalFontColor;
@property (strong, nonatomic) UIColor *colorGlobalBackgroundColor;
@property (strong, nonatomic) UIColor *colorSelectionColor;
@property (strong, nonatomic) UIColor *colorNotWorkingCellColor;
@property (strong, nonatomic) UIFont *detailTextLabelFont;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableView2Constraint;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableView *tableView2;

@end

@implementation AXMonthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self =  [super initWithCoder:aDecoder];
	if (self) {
		self.fetchedDayEntries = [NSMutableDictionary new];
		self.dateFormatterForRow = [NSDateFormatter new];
		self.dateFormatterForRow.dateFormat = @"dd EEE";
		self.settingsController = [AXSettingsManager new];
		self.dateFormatterForRowDetail = [NSDateFormatter new];
		self.dateFormatterForRowDetail.dateFormat = DATEFORMATTERHOURMINUTE;

		self.dateFormatterCheckOutForRowDetailDayDifferent = [NSDateFormatter new];
		self.dateFormatterCheckOutForRowDetailDayDifferent.dateFormat = @"HH:mm d/M";

		self.dateFormatterCheckOutForRowDetailYearDifferent = [NSDateFormatter new];
		self.dateFormatterCheckOutForRowDetailYearDifferent.dateFormat = @"HH:mm d/M/yy";
		self.gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [self.gregorianCalendar setFirstWeekday:2];
        [self.gregorianCalendar setMinimumDaysInFirstWeek:4];
		self.upArrow = [[UIImage imageNamed:@"up_arrow_black.png"] imageWithBurnTint:GLOBALFONTCOLOR];
		self.downArrow = [[UIImage imageNamed:@"down_arrow_black.png"] imageWithBurnTint:GLOBALFONTCOLOR];
		self.vacationImage = [[UIImage imageNamed:@"sun-7.png"] imageWithBurnTint:C_CANTALOUPE];
		self.sicknesImage = [[UIImage imageNamed:@"medical-box-7.png"] imageWithBurnTint:C_SALMON];
		self.holidayImage = [[UIImage imageNamed:@"candle_black_2.png"] imageWithBurnTint:C_CLOVER];
		self.simpleDayDateFormatter = [NSDateFormatter new];
		self.simpleDayDateFormatter.dateFormat = @"dd";
		self.simpleYearDateFormatter = [NSDateFormatter new];
		self.simpleYearDateFormatter.dateFormat = @"yyyy";
		self.simpleMonthDateFormatter = [NSDateFormatter new];
		self.simpleMonthDateFormatter.dateFormat = @"MM";
		self.calendarDateFormatter = [NSDateFormatter new];
		[self.calendarDateFormatter setDateFormat:@"yyyy_MM_dd"];
		self.colorGlobalBackgroundColor = GLOBALBACKGROUNDCOLOR;
		self.colorGlobalFontColor = GLOBALFONTCOLOR;
		self.colorSelectionColor = SELECTIONCOLOR;
		self.colorNotWorkingCellColor = NOTWORKINGCELLCOLOR;
		self.detailTextLabelFont =  [UIFont fontWithName:TICKERFONTNAME size:17.0];
	}
	return self;
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.tableView2Constraint.constant = [UIScreen mainScreen].applicationFrame.size.width;
	[self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
	self.activeTableViewCenter = self.tableView;
	self.activeTableViewContraint = self.tableViewConstraint;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setupWithDate:[[AXDateManager sharedInstance] currentDate]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSRange days = [self.gregorianCalendar rangeOfUnit:NSDayCalendarUnit
												inUnit:NSMonthCalendarUnit
											   forDate:[[AXDateManager sharedInstance] currentDate]];

	return days.length;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	AXTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

	// reset color
	cell.timeRangeLabel.textColor = self.colorGlobalFontColor;
	cell.totalTimeLabel.textColor = self.colorGlobalFontColor;
	cell.detailTextLabel.font = self.detailTextLabelFont;
	cell.timeRangeLabel.textAlignment = NSTextAlignmentRight;
	cell.typeSegmentedControl.tintColor = self.colorSelectionColor;

	if (self.expandedPath != nil && [self.expandedPath compare:indexPath] == NSOrderedSame) {
		[cell.arrowButton setImage:self.upArrow forState:UIControlStateNormal];
		cell.infoButton.hidden = NO;
		cell.typeSegmentedControl.hidden = NO;
	} else {
		[cell.arrowButton setImage:self.downArrow forState:UIControlStateNormal];
		cell.infoButton.hidden = YES;
		cell.typeSegmentedControl.hidden = YES;
	}

	NSDateComponents *components = [self.gregorianCalendar components:(NSYearCalendarUnit |
                                                                       NSMonthCalendarUnit |
                                                                       NSDayCalendarUnit |
                                                                       NSHourCalendarUnit |
                                                                       NSMinuteCalendarUnit |
                                                                       NSSecondCalendarUnit |
                                                                       NSTimeZoneCalendarUnit |
                                                                       NSWeekdayCalendarUnit |
                                                                       NSCalendarUnitWeekOfYear |
                                                                       NSCalendarUnitYearForWeekOfYear)
                                                             fromDate:[[AXDateManager sharedInstance] currentDate]];

	[components setDay:[indexPath row] + 1];

	NSDate *tempDate = [self.gregorianCalendar dateFromComponents:components];
    NSUInteger weekday = [self.gregorianCalendar ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:tempDate];
	[self setCellAppearanceBasedOnDayType:cell withDate:tempDate];

	NSString *displayString = [self.dateFormatterForRow stringFromDate:tempDate];
    if (weekday == 1) {
        NSDateComponents *components = [self.gregorianCalendar components:NSYearCalendarUnit |
                                        NSMonthCalendarUnit |
                                        NSDayCalendarUnit |
                                        NSHourCalendarUnit |
                                        NSMinuteCalendarUnit |
                                        NSSecondCalendarUnit |
                                        NSTimeZoneCalendarUnit |
                                        NSWeekdayCalendarUnit |
                                        NSCalendarUnitWeekOfYear |
                                        NSCalendarUnitYearForWeekOfYear
                                                                 fromDate:tempDate];
        NSInteger weekOfYear = [components weekOfYear];
        cell.customTextLabel.text = [NSString stringWithFormat:@"%@ (%@ %ld)",
                                     displayString,
                                     NSLS_CW,
                                     (long)weekOfYear];
    } else {
        cell.customTextLabel.text = displayString;
    }

	// TODO kann optimiert werden
	NSMutableArray *tempArray = [self.fetchedDayEntries objectForKey:[NSNumber numberWithInteger:[indexPath row] + 1]];
	if (tempArray != nil) {
		NSUInteger tempArrayLength = tempArray.count;
		NSString *timeRangeString = @"";
		NSString *totalTimeString = @"";
		if (tempArrayLength == 1) {
			DayEntry *tempDayEntry = tempArray[0];

			NSDateFormatter *dateFormatter = nil;
			if ([tempDayEntry.checkInTime isSameDay:tempDate withReceiverTimeZoneName:tempDayEntry.checkInTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
				dateFormatter = self.dateFormatterForRowDetail;
			} else if ([tempDayEntry.checkInTime isSameMonth:tempDate withReceiverTimeZoneName:tempDayEntry.checkInTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
				dateFormatter = self.dateFormatterCheckOutForRowDetailDayDifferent;
			} else {
				dateFormatter = self.dateFormatterCheckOutForRowDetailYearDifferent;
			}
			[dateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:tempDayEntry.checkInTimeZone]];

			timeRangeString = [NSString stringWithFormat:@"%@ - ", [dateFormatter stringFromDate:tempDayEntry.checkInTime]];
			if (tempDayEntry.checkOutTime != nil) {
				NSDateFormatter *dateFormatter = nil;
				if ([tempDayEntry.checkOutTime isSameDay:tempDate withReceiverTimeZoneName:tempDayEntry.checkOutTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
					dateFormatter = self.dateFormatterForRowDetail;
				} else if ([tempDayEntry.checkOutTime isSameMonth:tempDate withReceiverTimeZoneName:tempDayEntry.checkOutTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
					dateFormatter = self.dateFormatterCheckOutForRowDetailDayDifferent;
				} else {
					dateFormatter = self.dateFormatterCheckOutForRowDetailYearDifferent;
				}
				[dateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:tempDayEntry.checkOutTimeZone]];
				timeRangeString = [NSString stringWithFormat:@"%@%@", timeRangeString, [dateFormatter stringFromDate:tempDayEntry.checkOutTime]];

				totalTimeString = [tempDayEntry netHoursAsDecimalString];
			} else {
				// mark incomplete dayentries red
				NSDateComponents *nowComponents = [self.gregorianCalendar components:CALENDARUNITCOMPONENTS fromDate:[NSDate date]];
				if (nowComponents.year != components.year || nowComponents.day != components.day || nowComponents.month != components.month) {
					// mark only red if it is not today
					cell.timeRangeLabel.textColor = REDCOLOR;
				}
			}
		} else {
			timeRangeString = [NSString stringWithFormat:@"%lu %@", (unsigned long)tempArrayLength, NSLS_ENTRIES];
			BOOL incomplete = NO;

			for (DayEntry *dayEntry in tempArray) {
				if (dayEntry.checkOutTime == nil) {
					incomplete = YES;
					break;
				}
			}

			if (incomplete) {
				// mark incomplete dayentries red
				NSDateComponents *nowComponents = [self.gregorianCalendar components:CALENDARUNITCOMPONENTS fromDate:[NSDate date]];
				if (nowComponents.year != components.year || nowComponents.day != components.day || nowComponents.month != components.month) {
					// mark only red if it is not today
					cell.timeRangeLabel.textColor = REDCOLOR;
				}
			}
			totalTimeString = [[AXCalculation new] getNetTimeForArrayAsString:tempArray];
		}

		cell.timeRangeLabel.text = timeRangeString;
		cell.totalTimeLabel.text = totalTimeString;
	} else {
		cell.timeRangeLabel.text = @"";
		cell.totalTimeLabel.text = @"";
	}

	return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDateComponents *components = [self.gregorianCalendar components:CALENDARUNITCOMPONENTS fromDate:[[AXDateManager sharedInstance] currentDate]];

	[components setDay:indexPath.row + 1];
	[[AXDateManager sharedInstance] setCurrentDate:[self.gregorianCalendar dateFromComponents:components]];
	[[NSNotificationCenter defaultCenter]
		 postNotificationName:NOTIFICATION_MOVETODAYDETAIL object:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.expandedPath != nil && [self.expandedPath compare:indexPath] == NSOrderedSame) {
		return 88;
	} else {
		return 44;
	}
}

#pragma mark - private methods
- (void)setupWithDate:(NSDate *)date {
	self.expandedPath = nil;
	if (self.infoPath != nil) {
		self.expandedPath = self.infoPath;
		self.infoPath  = nil;
	}
	NSDateComponents *components = [self.gregorianCalendar components:CALENDARUNITCOMPONENTS fromDate:date];

	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	[components setDay:1];
	NSDate *beginDate = [self.gregorianCalendar dateFromComponents:components];

	[[AXDateManager sharedInstance] setCurrentDate:date];

	self.dayTypesArray = [[AXDataStore sharedInstance] getListDayTypesForTimeUnit:MONTH andDate:date withType:NOTSPECIFIED];
	self.workSettingsArray = [[AXDataStore sharedInstance] getListWorkingWeekSettingsForTimeUnit:MONTH andDate:beginDate];
	self.fromUserSettingsWorkingWeekArray = [self.settingsController getWorkingweek];

	[self getDayEntries];
	[self.activeTableViewCenter reloadData];

	NSDate *tempDate = [NSDate date];

	if (self.expandedPath != nil) {
		[self.activeTableViewCenter scrollToRowAtIndexPath:self.expandedPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
	} else if ([date isSameMonth:tempDate]) {
		// scroll to current day if it is today
		NSUInteger currentDay = [[self.simpleDayDateFormatter stringFromDate:tempDate] integerValue];
		[self.activeTableViewCenter scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:currentDay - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	} else {
		[self.activeTableViewCenter scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	}
}

- (void)getDayEntries {
	[self.fetchedDayEntries removeAllObjects];

	NSArray *results = [[AXDataStore sharedInstance] getListDayEntryForMonthInDetailView:[[AXDateManager sharedInstance] currentDate]];
	if (results != nil && [results count] > 0) {
		for (DayEntry *dayEntry in results) {
			NSDateComponents *components = [self.gregorianCalendar components:( NSDayCalendarUnit  ) fromDate:[dayEntry checkInTime]];
			NSMutableArray *array = [self.fetchedDayEntries objectForKey:[NSNumber numberWithInteger:[components day]]];
			if (array == nil) {
				NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:@[dayEntry]];
				[self.fetchedDayEntries setObject:newArray forKey:[NSNumber numberWithInteger:[components day]]];
			} else {
				[array addObject:dayEntry];
			}
		}
	}
}

- (UITableView *)getNonActiveTableView {
	if (self.activeTableViewCenter == self.tableView) {
		return self.tableView2;
	} else {
		return self.tableView;
	}
}

- (NSLayoutConstraint *)getConstraint:(UITableView *)tableView {
	if (tableView == self.tableView2) {
		return self.tableView2Constraint;
	} else {
		return self.tableViewConstraint;
	}
}

- (void)setCellAppearanceBasedOnDayType:(AXTableViewCell *)cell withDate:(NSDate *)date {
	UISegmentedControl *segmentedControl = cell.typeSegmentedControl;
	BOOL setNotWorkingColor = NO;
	// TODO kann optimiert werden
	NSString *calendarDay = [self.calendarDateFormatter stringFromDate:date];

	NSArray *tempDayTypesArray = [self.dayTypesArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(calendarDay == %@)", calendarDay]];

	DayType *dayType = nil;

	if (tempDayTypesArray != nil && [tempDayTypesArray count] >= 1) {
		dayType = tempDayTypesArray[0];
	}

	[cell.typeImageView setImage:nil];

	if (dayType != nil) {
		if ([[dayType vacation]boolValue]) {
			[cell.typeImageView setImage:self.vacationImage];
		} else if ([[dayType sickness]boolValue]) {
			[cell.typeImageView setImage:self.sicknesImage];
		} else if ([[dayType holiday]boolValue]) {
			setNotWorkingColor = YES;
			[cell.typeImageView setImage:self.holidayImage];
		}

		if (![[dayType work]boolValue] && ![[dayType vacation]boolValue] && ![[dayType sickness]boolValue] && ![[dayType holiday]boolValue]) {
			setNotWorkingColor = YES;
		}

		if ([[dayType vacation]boolValue]) {
			[segmentedControl setSelectedSegmentIndex:VACATIONDAY];
		} else if ([[dayType sickness]boolValue]) {
			[segmentedControl setSelectedSegmentIndex:SICKDAY];
		} else if ([[dayType holiday]boolValue]) {
			[segmentedControl setSelectedSegmentIndex:HOLIDAY];
		} else if ([[dayType work]boolValue]) {
			[segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
		} else {
			[segmentedControl setSelectedSegmentIndex:NOTAWORKINGDAY];
		}
	} else {
		WorkingWeekSetting *workingWeekSetting = nil;

		if ([self.workSettingsArray count] != 0) {
			// TODO kann optimiert werden

			NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
			[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
			NSNumber *yearNumber = [numberFormatter numberFromString:[self.simpleYearDateFormatter stringFromDate:date]];
			NSNumber *monthNumber = [numberFormatter numberFromString:[self.simpleMonthDateFormatter stringFromDate:date]];
			NSNumber *dayNumber = [numberFormatter numberFromString:[self.simpleDayDateFormatter stringFromDate:date]];

			// TODO kann optimiert werden
			NSArray *tempDayTypesArray = [self.workSettingsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"((year = %@) AND (month = %@) AND (day >= %@)) OR ((year = %@) AND (month > %@) AND (day >=%@))  OR ((year > %@) AND (month => %@) AND (day => %@))", yearNumber, monthNumber, dayNumber, yearNumber, monthNumber, [NSNumber numberWithInt:1], yearNumber, [NSNumber numberWithInt:1], [NSNumber numberWithInt:1]] ];

			if ([tempDayTypesArray count] != 0) {
				if ([tempDayTypesArray count] > 1) {
					NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"validUntil" ascending:YES];
					NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
					NSArray *sortedArray = [tempDayTypesArray sortedArrayUsingDescriptors:sortDescriptors];

					workingWeekSetting = sortedArray[0];
				} else {
					workingWeekSetting = tempDayTypesArray[0];
				}
			}
		}

		// TODO kann optimiert werden

		NSDateComponents *components = [self.gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSTimeZoneCalendarUnit | NSWeekdayCalendarUnit) fromDate:date];

		NSDate *tempDate =  [self.gregorianCalendar dateFromComponents:components];
		NSDateComponents *tempComponents = [self.gregorianCalendar components:NSWeekdayCalendarUnit fromDate:tempDate];
		NSUInteger weekday = [tempComponents weekday];
		NSInteger position = fmod(weekday + 5, 7);
		NSArray *settingsWorkingweek = nil;

		if (workingWeekSetting == nil) {
			settingsWorkingweek = self.fromUserSettingsWorkingWeekArray;
		} else {
			settingsWorkingweek = [NSKeyedUnarchiver unarchiveObjectWithData:workingWeekSetting.workingWeekArray];
		}

		if (![((NSNumber *)settingsWorkingweek[position])boolValue]) {
			setNotWorkingColor = YES;
			[segmentedControl setSelectedSegmentIndex:NOTAWORKINGDAY];
		} else {
			[segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
		}
	}

	if (setNotWorkingColor) {
		cell.backgroundColor = self.colorNotWorkingCellColor;
	} else {
		cell.backgroundColor = self.colorGlobalBackgroundColor;
	}
}

#pragma mark - AXCalendarViewControllerProtocol methods
- (void)navigateForward:(BOOL)forward {
	NSDateComponents *components = [self.gregorianCalendar components:CALENDARUNITCOMPONENTS fromDate:[[AXDateManager sharedInstance] currentDate]];

    CGFloat containerWidth = self.view.superview.bounds.size.width;
	CGRect finalPositionForNewTable =  self.activeTableViewCenter.frame;
	UITableView *newTable = [self getNonActiveTableView];

	if (forward) {
		CGRect finalPositionForNewRightTable =  self.activeTableViewCenter.frame;
		finalPositionForNewRightTable.origin.x = finalPositionForNewRightTable.origin.x + finalPositionForNewRightTable.size.width;

		CGRect finalPositonForOldTable =  self.activeTableViewCenter.frame;
		finalPositonForOldTable.origin.x = finalPositonForOldTable.origin.x - finalPositonForOldTable.size.width;

		newTable.frame = finalPositionForNewRightTable;
		[self getConstraint:newTable].constant = containerWidth;


		self.activeTableViewCenter = newTable;
		newTable.delegate = self;
		newTable.dataSource = self;

		[components setMonth:components.month + 1];
		[self setupWithDate:[self.gregorianCalendar dateFromComponents:components]];

		[UIView animateWithDuration:ANIMATIONDURATION
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
			 self.activeTableViewCenter.frame = finalPositionForNewTable;
			 [self getConstraint:self.activeTableViewCenter].constant = 0;

			 [[self getNonActiveTableView] setFrame:finalPositonForOldTable];
			 [self getConstraint:[self getNonActiveTableView]].constant = -containerWidth;
		 } completion:^(BOOL finished) {
			 UITableView *nonactive = [self getNonActiveTableView];
			 nonactive.delegate = nil;
			 nonactive.dataSource = nil;
		 }];
	} else {
		CGRect finalPositionForNewLeftTable =  self.activeTableViewCenter.frame;
		finalPositionForNewLeftTable.origin.x = finalPositionForNewLeftTable.origin.x - finalPositionForNewLeftTable.size.width;

		CGRect finalPositonForOldTable =  self.activeTableViewCenter.frame;
		finalPositonForOldTable.origin.x = finalPositonForOldTable.origin.x + finalPositonForOldTable.size.width;

		newTable.frame = finalPositionForNewLeftTable;
		[self getConstraint:newTable].constant = -containerWidth;


		self.activeTableViewCenter = newTable;
		newTable.delegate = self;
		newTable.dataSource = self;

		[components setMonth:components.month - 1];
		[self setupWithDate:[self.gregorianCalendar dateFromComponents:components]];

		[UIView animateWithDuration:ANIMATIONDURATION
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
			 self.activeTableViewCenter.frame = finalPositionForNewTable;
			 [self getConstraint:self.activeTableViewCenter].constant = 0;

			 [[self getNonActiveTableView] setFrame:finalPositonForOldTable];
			 [self getConstraint:[self getNonActiveTableView]].constant = containerWidth;
		 } completion:^(BOOL finished) {
			 UITableView *nonactive = [self getNonActiveTableView];
			 nonactive.delegate = nil;
			 nonactive.dataSource = nil;
		 }];
	}
}

- (void)goToToday {
	[self setupWithDate:[NSDate date]];
}

#pragma mark - outlet actions
- (IBAction)increaseCellHeightAction:(id)sender {
	UIButton *senderButton = (UIButton *)sender;
	CGPoint center = senderButton.center;
	CGPoint rootViewPoint = [[sender superview] convertPoint:center toView:self.activeTableViewCenter];
	NSIndexPath *currentIndexpath = [self.activeTableViewCenter indexPathForRowAtPoint:rootViewPoint];
	AXTableViewCell *cell = (AXTableViewCell *)[self.activeTableViewCenter cellForRowAtIndexPath:currentIndexpath];

	NSMutableArray *tempArray = [NSMutableArray new];

	if (self.expandedPath != nil && [self.expandedPath compare:currentIndexpath] == NSOrderedSame) {
		self.expandedPath = nil;
		[cell.arrowButton setImage:self.downArrow forState:UIControlStateNormal];
		cell.infoButton.hidden = YES;
		cell.typeSegmentedControl.hidden = YES;
	} else {
		if (self.expandedPath != nil) {
			AXTableViewCell *oldCell = (AXTableViewCell *)[self.activeTableViewCenter cellForRowAtIndexPath:self.expandedPath];
			[oldCell.arrowButton setImage:self.downArrow forState:UIControlStateNormal];
			oldCell.infoButton.hidden = YES;
			oldCell.typeSegmentedControl.hidden = YES;
		}
		self.expandedPath = currentIndexpath;
		[cell.arrowButton setImage:self.upArrow forState:UIControlStateNormal];
		cell.infoButton.hidden = NO;
		cell.typeSegmentedControl.hidden = NO;
	}

	[tempArray addObject:currentIndexpath];

	[UIView setAnimationsEnabled:NO];

	[self.activeTableViewCenter beginUpdates];
    
	[self.activeTableViewCenter endUpdates];
	[UIView setAnimationsEnabled:YES];

	if (currentIndexpath.row == [self.activeTableViewCenter numberOfRowsInSection:0] - 1) {
		[self.activeTableViewCenter scrollToRowAtIndexPath:currentIndexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
}

- (IBAction)typeChangedAction:(id)sender {
	UIButton *senderButton = (UIButton *)sender;
	CGPoint center = senderButton.center;
	CGPoint rootViewPoint = [[sender superview] convertPoint:center toView:self.activeTableViewCenter];
	NSIndexPath *currentIndexpath = [self.activeTableViewCenter indexPathForRowAtPoint:rootViewPoint];
	AXTableViewCell *cell = (AXTableViewCell *)[self.activeTableViewCenter cellForRowAtIndexPath:currentIndexpath];

	NSDateComponents *components = [self.gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSTimeZoneCalendarUnit | NSWeekdayCalendarUnit) fromDate:[[AXDateManager sharedInstance] currentDate]];

	[components setDay:[currentIndexpath row] + 1];
	NSDate *tempDate =  [self.gregorianCalendar dateFromComponents:components];

	[AXUtility dayTypeChanged:((AXTableViewCell *)cell).typeSegmentedControl withDate:tempDate];
	self.dayTypesArray = [[AXDataStore sharedInstance] getListDayTypesForTimeUnit:MONTH andDate:tempDate withType:NOTSPECIFIED];

	[self setCellAppearanceBasedOnDayType:cell withDate:tempDate];
}

- (IBAction)infoButtonAction:(id)sender {
	self.infoPath = self.expandedPath;
	[self performSegueWithIdentifier:@"infoSegue" sender:self];
}

@end
