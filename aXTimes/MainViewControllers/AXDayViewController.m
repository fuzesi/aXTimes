    //
//  AXDayViewController.m
//  aXTimes
//
//  Created by fuesec on 5/8/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXDayViewController.h"
#import "AXUtility.h"
#import "AXHourlyWageViewController.h"
#import "AXSettingsManager.h"
#import "AXPauseTableViewCell.h"
#import "AXCommentTableViewCell.h"
#import "NSDate+AXNSDateCategory.h"
#import <MEAlertView.h>
#import "AXCalendarViewController.h"
#import <SHActionSheetBlocks.h>
#import "UIImage+AXUIImageCategory.h"
#import "NSString+AXNSStringCategory.h"
#import "AXDatePickerTableViewCell.h"
#import "AXCpyViewController.h"
#import "NSNumber+AXNSNumberCategory.h"

// checkin + checkout
static const int NUMBEROFSROWSSBEFOREPAUSESSTART = 2;
static NSString *datePickeCell = @"DatePickerCell";
static NSString *commentCellString = @"CommentCell";
static NSString *pauseCell = @"PauseCell";


@interface AXDayViewController ()

@property (strong, nonatomic) NSMutableArray *fetchedDayEntries;
@property (nonatomic, strong) DayEntry *currentDayEntry;
@property (nonatomic, strong) DayEntry *lastDayEntry;
//@property (nonatomic, strong) AXTimePickerViewController *cpyPickerViewController;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatterCheckOutForRowDetailDayDifferent;
@property (strong, nonatomic) NSDateFormatter *dateFormatterCheckOutForRowDetailYearDifferent;
@property (nonatomic, strong) AXUtility *utility;
@property (nonatomic, strong) AXSettingsManager *settingsController;
@property (nonatomic) CGRect originalTableViewFrame;
@property (nonatomic) CGFloat buttonContainerViewheight;
@property (nonatomic, strong) NSMutableArray *nextEntryButtonConstraints;
@property (nonatomic, strong) NSMutableArray *previousEntryButtonConstraints;
@property (nonatomic, strong) NSMutableArray *entryNavigationLabelConstraints;
@property (nonatomic, strong) NSMutableArray *buttonContainerViewConstraints;
@property (nonatomic, strong) NSMutableArray *constraintsArray;
@property (nonatomic, strong) NSMutableArray *bottomViewsArray;
@property (nonatomic, strong) NSTimer *clockTimer;
@property (nonatomic, strong) NSNumberFormatter *decimalNumberFormatter;

@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;
@property NSInteger selectedRow;
@property NSInteger selectedEntry;
@property (strong, nonatomic) UITableView *activeTableViewCenter;
@property (strong, nonatomic) NSLayoutConstraint *activeTableViewContraint;

@property (nonatomic) CGFloat applicationFrameWidth;

@property (strong, nonatomic) NSIndexPath *datePickerIndexPath;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableView2Constraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstraintBottomSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableView2ConstraintBottomSpace;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableView *tableView2;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;
@property (strong, nonatomic) IBOutlet UIView *summaryCalculationView;
@property (strong, nonatomic) IBOutlet UILabel *netTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *grossTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *salaryLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleGrossTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleNetTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleSalaryLabel;
@property (strong, nonatomic) IBOutlet UIButton *nextEntryButton;
@property (strong, nonatomic) IBOutlet UIButton *previousEntryButton;
@property (strong, nonatomic) IBOutlet UILabel *entryNavigationLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonContainerViewConstraintToSummaryView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonVontainerViewConstraintToTableView2;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonVontainerViewConstraintToTableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonContainerViewHeightConstraint;

@end

@implementation AXDayViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
	self =  [super initWithCoder:aDecoder];
	if (self) {
		self.dateFormatter = [NSDateFormatter new];
		self.dateFormatter.dateFormat = DATEFORMATTERHOURMINUTE;

		self.dateFormatterCheckOutForRowDetailDayDifferent = [NSDateFormatter new];
		self.dateFormatterCheckOutForRowDetailDayDifferent.dateFormat = @"HH:mm d/M";

		self.dateFormatterCheckOutForRowDetailYearDifferent = [NSDateFormatter new];
		self.dateFormatterCheckOutForRowDetailYearDifferent.dateFormat = @"HH:mm d/M/yy";

		self.utility = [AXUtility new];
		self.settingsController = [AXSettingsManager new];

		self.decimalNumberFormatter = [NSNumberFormatter new];
		[self.decimalNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[self.decimalNumberFormatter setMaximumFractionDigits:2];
		[self.decimalNumberFormatter setMinimumFractionDigits:2];
		[self.decimalNumberFormatter setRoundingIncrement:[NSNumber numberWithDouble:0.01]];
		[self.decimalNumberFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
	}
	return self;
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
    self.tableView.backgroundColor = GLOBALBACKGROUNDCOLOR2;
    self.tableView2.backgroundColor = GLOBALBACKGROUNDCOLOR2;
    
    self.applicationFrameWidth = [UIScreen mainScreen].applicationFrame.size.width;

    self.constraintsArray = [NSMutableArray new];
    self.bottomViewsArray = [NSMutableArray new];
    
    self.buttonContainerViewheight = self.buttonContainerView.frame.size.height;
    self.buttonContainerViewConstraints = [[NSMutableArray alloc] initWithArray:self.buttonContainerView.constraints];
    self.previousEntryButtonConstraints = [[NSMutableArray alloc] initWithArray:self.previousEntryButton.constraints];
    self.nextEntryButtonConstraints = [[NSMutableArray alloc] initWithArray:self.nextEntryButton.constraints];
    self.entryNavigationLabelConstraints = [[NSMutableArray alloc] initWithArray:self.entryNavigationLabel.constraints];
    
    [self.constraintsArray addObject:self.buttonContainerViewConstraints];
    [self.constraintsArray addObject:self.previousEntryButtonConstraints];
    [self.constraintsArray addObject:self.nextEntryButtonConstraints];
    [self.constraintsArray addObject:self.entryNavigationLabelConstraints];
    
    [self.bottomViewsArray addObject:self.buttonContainerView];
    [self.bottomViewsArray addObject:self.previousEntryButton];
    [self.bottomViewsArray addObject:self.nextEntryButton];
    [self.bottomViewsArray addObject:self.entryNavigationLabel];
    
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousEntryAction:)];
    swipeGestureRight.direction = (UISwipeGestureRecognizerDirectionRight);
    swipeGestureRight.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipeGestureRight];
    
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextEntryAction:)];
    swipeGestureLeft.direction = (UISwipeGestureRecognizerDirectionLeft);
    swipeGestureLeft.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipeGestureLeft];
    
//    CGRect buttonContainerRect = self.summaryCalculationView.frame;
    
    CAShapeLayer *lineShape = nil;
    CGMutablePathRef linePath = nil;
    linePath = CGPathCreateMutable();
    lineShape = [CAShapeLayer layer];
    CGFloat lineWidth = 0.1f;
    lineShape.lineWidth = lineWidth;
    lineShape.lineCap = kCALineCapSquare;
    lineShape.strokeColor = [[UIColor blackColor] CGColor];
    CGFloat x = 0 + 0.9f; CGFloat y = 0 + 0.9f;
    CGFloat toX = x + self.applicationFrameWidth; CGFloat toY = y;
    CGPathMoveToPoint(linePath, NULL, x, y);
    CGPathAddLineToPoint(linePath, NULL, toX, toY);
    lineShape.path = linePath;
    CGPathRelease(linePath);
    [self.summaryCalculationView.layer addSublayer:lineShape];

	self.titleGrossTimeLabel.text = NSLS_GROSS;
	self.titleNetTimeLabel.text = NSLS_NET;
	self.titleSalaryLabel.text = NSLS_SALARY;
	self.buttonContainerView.backgroundColor = GLOBALBACKGROUNDCOLOR2;
	self.summaryCalculationView.backgroundColor = GLOBALBACKGROUNDCOLOR2;
	self.view.backgroundColor = GLOBALBACKGROUNDCOLOR2;

	CGRect frame = CGRectZero;
	frame.size.height = 1;
	[self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
	[self.tableView2 setTableHeaderView:[[UIView alloc] initWithFrame:frame]];

    self.tableView2Constraint.constant = self.applicationFrameWidth;
	[self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
	self.activeTableViewCenter = self.tableView;
	self.activeTableViewContraint = self.tableViewConstraint;
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([AXDatePickerTableViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:datePickeCell];
    [self.tableView2 registerNib:cellNib forCellReuseIdentifier:datePickeCell];
    
    UINib *commentCellNib = [UINib nibWithNibName:NSStringFromClass([AXCommentTableViewCell class]) bundle:nil];
    [self.tableView registerNib:commentCellNib forCellReuseIdentifier:commentCellString];
    [self.tableView2 registerNib:commentCellNib forCellReuseIdentifier:commentCellString];
    
    UINib *pauseCellNib = [UINib nibWithNibName:NSStringFromClass([AXPauseTableViewCell class]) bundle:nil];
    [self.tableView registerNib:pauseCellNib forCellReuseIdentifier:pauseCell];
    [self.tableView2 registerNib:pauseCellNib forCellReuseIdentifier:pauseCell];

    [[NSNotificationCenter defaultCenter]
				 addObserver:self
					selector:@selector(navigateTo:)
     name:NOTIFICATION_NAVIGATE_TO
     object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter]
				 addObserver:self
					selector:@selector(lastDayEntryChanged:)
     name:NOTIFICATION_OUTSIDECHANGE_OCCURED
     object:nil];

    [self setupWithDate:[[AXDateManager sharedInstance] currentDate]];
	self.lastDayEntry = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    if ([self datePickerIsShown]) {
        NSInteger maxRowsInTable = [self.activeTableViewCenter numberOfRowsInSection:0];
        [self updateTableRoutineWithMaxNumberOfRow:maxRowsInTable];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_OUTSIDECHANGE_OCCURED object:nil];
	self.lastDayEntry = self.currentDayEntry;
    if (self.clockTimer != nil) {
		[self.clockTimer invalidate];
		self.clockTimer = nil;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// NUMBEROFSROWSSBEFOREPAUSESSTART + pauses + addpause + comment + currency
    NSInteger numberOfRows = NUMBEROFSROWSSBEFOREPAUSESSTART + [[self.currentDayEntry pauses] count]  + 1 + 1 + 1;
    if ([self datePickerIsShown]) {
        numberOfRows++;
    }
    return numberOfRows;
}

- (AXDatePickerTableViewCell *)createPickerCell:(NSIndexPath *)indexPath {
    AXDatePickerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:datePickeCell];
        
    UIDatePicker *datePicker = cell.datePicker;
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];

    if (indexPath.row == 1 ||
        indexPath.row == 2) {
        datePicker.maximumDate = nil;
        datePicker.minimumDate = nil;
        // timezone reset
        datePicker.timeZone = [[NSTimeZone alloc] initWithName:[[NSTimeZone systemTimeZone] name]];

        self.selectedRow = indexPath.row;
        
        switch (indexPath.row) {
            case 1 : {
                datePicker.datePickerMode = UIDatePickerModeTime;
                
                NSDate *tempDate = nil;
                if (self.currentDayEntry != nil && self.currentDayEntry.checkInTime != nil) {
                    // timezone formatted
                    datePicker.timeZone = [[NSTimeZone alloc] initWithName:self.currentDayEntry.checkInTimeZone];
                    tempDate = self.currentDayEntry.checkInTime;
                } else {
                    tempDate = [[AXDateManager sharedInstance] currentDate];

                    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                    NSDateComponents *components = [calendar components:CALENDARUNITCOMPONENTS fromDate:tempDate];
                    components.hour = 8;
                    tempDate = [calendar dateFromComponents:components];
                }
                [datePicker setDate:tempDate];
                if (self.currentDayEntry != nil) {
                    Pause *pause =  [self.currentDayEntry getFirstSortedPause];
                    if (pause != nil) {
                        datePicker.maximumDate = pause.startTime;
                    } else if (self.currentDayEntry.checkOutTime != nil) {
                        datePicker.maximumDate = self.currentDayEntry.checkOutTime;
                    } else if ([[AXDateManager sharedInstance] isToday]) {
                        datePicker.maximumDate = [NSDate date];
                    }
                } else {
                    if ([[AXDateManager sharedInstance] isToday]) {
                        datePicker.maximumDate = [NSDate date];
                    }
                }
                
                DayEntry *dayEntry = [[AXDataStore sharedInstance] getLatestDayEntryForDate:tempDate];
                if (dayEntry != nil && dayEntry.checkOutTime != nil && [dayEntry.checkOutTime isSameDay:tempDate]) {
                    datePicker.minimumDate = dayEntry.checkOutTime;
                } else if (dayEntry != nil && dayEntry.checkInTime != nil && [dayEntry.checkInTime isSameDay:tempDate]) {
                    datePicker.minimumDate = dayEntry.checkInTime;
                }
                
                break;
            }
            case 2 : {
                datePicker.datePickerMode = UIDatePickerModeDateAndTime;
                if (self.currentDayEntry != nil) {
                    Pause *pause = [self.currentDayEntry getLastSortedPause];
                    
                    if (pause != nil) {
                        datePicker.minimumDate = pause.endTime;
                        [datePicker setDate:pause.endTime];
                    } else {
                        datePicker.minimumDate = self.currentDayEntry.checkInTime;
                        [datePicker setDate:self.currentDayEntry.checkInTime];
                    }
                }
                
                // if there is already a value set it
                if (self.currentDayEntry != nil && self.currentDayEntry.checkOutTime != nil) {
                    // timezone formatted
                    datePicker.timeZone = [[NSTimeZone alloc] initWithName:self.currentDayEntry.checkOutTimeZone];
                    [datePicker setDate:self.currentDayEntry.checkOutTime];
                }
                
                DayEntry *dayEntry = [[AXDataStore sharedInstance] getNextDayEntryForDate:datePicker.date];
                
                // FIXME durchaus möglich checkout ein paar sekunden vor checkin zu haben
                if (dayEntry != nil && dayEntry != self.currentDayEntry && dayEntry.checkInTime != nil) {
                    datePicker.maximumDate = dayEntry.checkInTime;
                } else {
                    datePicker.maximumDate = [NSDate date];
                }
                break;
            }
            default :
                break;
        }
        NSDate *nowDate = [NSDate date];
        if ([datePicker.maximumDate compare:nowDate] == NSOrderedDescending) {
            datePicker.maximumDate = nowDate;
            datePicker.date = nowDate;
        }
    }
    
    NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:self.datePickerIndexPath.section];
    UITableViewCell *dateCell = [self.activeTableViewCenter cellForRowAtIndexPath:tempIndexPath];
    dateCell.detailTextLabel.text = [self.dateFormatter stringFromDate:datePicker.date];
    //highlight the date as in the calendar App by Apple
    dateCell.detailTextLabel.textColor = SELECTIONCOLOR;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *normalCell = @"Cell";

	NSInteger maxRowsInTable = [tableView numberOfRowsInSection:0];

	AXPauseTableViewCell *cell = nil;
	AXCommentTableViewCell *commentCell = nil;
    
    if ([self datePickerIsShown] &&
        (self.datePickerIndexPath.row == indexPath.row)){
        
        AXDatePickerTableViewCell *pickerCell = [self createPickerCell:indexPath];
        return pickerCell;
    }

	if (indexPath.row >= NUMBEROFSROWSSBEFOREPAUSESSTART && indexPath.row < (maxRowsInTable - 3)) {
		cell = [tableView dequeueReusableCellWithIdentifier:pauseCell forIndexPath:indexPath];
		cell.timeRangeLabel.text = @"";
		cell.totalTimeLabel.text = @"";
		cell.totalTimeLabel.textColor = GLOBALDETAILFONTCOLOR;
		cell.timeRangeLabel.textColor = GLOBALDETAILFONTCOLOR;
		cell.timeRangeLabel.textAlignment = NSTextAlignmentRight;
	} else if (indexPath.row == maxRowsInTable - 2) {
		commentCell = [tableView dequeueReusableCellWithIdentifier:commentCellString forIndexPath:indexPath];
		commentCell.customTextLabel.text = @"";
		commentCell.commentLabel.text = @"";
		commentCell.textLabel.text = @"";
		commentCell.detailTextLabel.text = @" ";
		commentCell.userInteractionEnabled = YES;
		commentCell.accessoryType = UITableViewCellAccessoryNone;
		commentCell.accessoryView = nil;
		commentCell.selectionStyle = UITableViewCellSelectionStyleBlue;
		commentCell.backgroundColor = GLOBALBACKGROUNDCOLOR;
		commentCell.detailTextLabel.textColor = GLOBALDETAILFONTCOLOR;
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:normalCell forIndexPath:indexPath];
	}

    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @" ";
	cell.userInteractionEnabled = YES;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.accessoryView = nil;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
	cell.detailTextLabel.textColor = GLOBALDETAILFONTCOLOR;
    
	switch (indexPath.row) {
		case 0 :
			cell.textLabel.text = NSLS_CHECKIN;
			if (self.currentDayEntry != nil && [self.currentDayEntry checkInTime] != nil) {
				NSDateFormatter *tempDateFormatter = nil;
				if ([self.currentDayEntry.checkInTime isSameDay:[[AXDateManager sharedInstance] currentDate] withReceiverTimeZoneName:self.currentDayEntry.checkInTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
					tempDateFormatter = self.dateFormatter;
				} else if ([self.currentDayEntry.checkInTime isSameMonth:[[AXDateManager sharedInstance] currentDate] withReceiverTimeZoneName:self.currentDayEntry.checkInTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
					tempDateFormatter = self.dateFormatterCheckOutForRowDetailDayDifferent;
				} else {
					tempDateFormatter = self.dateFormatterCheckOutForRowDetailYearDifferent;
				}
				[tempDateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:self.currentDayEntry.checkInTimeZone]];

                NSString * detailText = [tempDateFormatter stringFromDate:[self.currentDayEntry checkInTime]];
                [cell.detailTextLabel setText:detailText];
			}
			break;
		case 1 : {
			cell.textLabel.text = NSLS_CHECKOUT;

			if (self.currentDayEntry != nil) {
				if ([self.currentDayEntry checkOutTime] != nil) {
					NSDateFormatter *tempDateFormatter = nil;
					if ([self.currentDayEntry.checkOutTime isSameDay:[[AXDateManager sharedInstance] currentDate] withReceiverTimeZoneName:self.currentDayEntry.checkOutTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
						tempDateFormatter = self.dateFormatter;
					} else if ([self.currentDayEntry.checkOutTime isSameMonth:[[AXDateManager sharedInstance] currentDate] withReceiverTimeZoneName:self.currentDayEntry.checkOutTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
						tempDateFormatter = self.dateFormatterCheckOutForRowDetailDayDifferent;
					} else {
						tempDateFormatter = self.dateFormatterCheckOutForRowDetailYearDifferent;
					}
					[tempDateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:self.currentDayEntry.checkOutTimeZone]];

					cell.detailTextLabel.text = [tempDateFormatter stringFromDate:[self.currentDayEntry checkOutTime]];

					if (![self.currentDayEntry.checkOutTimeZone isEqualToString:self.currentDayEntry.checkInTimeZone]) {
						cell.accessoryView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"globus_fine.png"] imageWithBurnTint:TIMEZONECOLOR]];
					}
				}

				Pause *pause = [self.currentDayEntry getLastSortedPause];
				if (pause != nil && pause.startTime != nil && pause.endTime == nil) {
					cell.userInteractionEnabled = NO;
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
				}
			} else {
				cell.userInteractionEnabled = NO;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			break;
		}
		default :
			break;
	}

	// pause cells
	if (indexPath.row >= NUMBEROFSROWSSBEFOREPAUSESSTART && indexPath.row < (maxRowsInTable - 3)) {
		cell.customTextLabel.text = NSLS_PAUSE;
		Pause *pause = [self.currentDayEntry sortedPauses][indexPath.row - NUMBEROFSROWSSBEFOREPAUSESSTART];

		NSDateFormatter *tempDateFormatter = nil;
		if ([pause.startTime isSameDay:[[AXDateManager sharedInstance] currentDate] withReceiverTimeZoneName:pause.startTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
			tempDateFormatter = self.dateFormatter;
		} else if ([pause.startTime isSameMonth:[[AXDateManager sharedInstance] currentDate]  withReceiverTimeZoneName:pause.startTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
			tempDateFormatter = self.dateFormatterCheckOutForRowDetailDayDifferent;
		} else {
			tempDateFormatter = self.dateFormatterCheckOutForRowDetailYearDifferent;
		}
		[tempDateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:pause.startTimeZone]];
		NSString *pauseRangeString = [NSString stringWithFormat:@"%@ - ", [tempDateFormatter stringFromDate:pause.startTime]];
		NSString *totalPauseTimeString = @"";
		if (pause.endTime != nil) {
			NSDateFormatter *tempDateFormatter = nil;
			if ([pause.endTime isSameDay:[[AXDateManager sharedInstance] currentDate] withReceiverTimeZoneName:pause.endTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
				tempDateFormatter = self.dateFormatter;
			} else if ([pause.endTime isSameMonth:[[AXDateManager sharedInstance] currentDate]  withReceiverTimeZoneName:pause.endTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
				tempDateFormatter = self.dateFormatterCheckOutForRowDetailDayDifferent;
			} else {
				tempDateFormatter = self.dateFormatterCheckOutForRowDetailYearDifferent;
			}
			[tempDateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:pause.endTimeZone]];
			pauseRangeString = [NSString stringWithFormat:@"%@%@", pauseRangeString, [tempDateFormatter stringFromDate:pause.endTime]];

			totalPauseTimeString = [pause hoursPausedDisplayValue];
		}
		cell.timeRangeLabel.text = pauseRangeString;
		cell.totalTimeLabel.text = totalPauseTimeString;
	}

	// add pause cell
	if (indexPath.row == (maxRowsInTable - 3)) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[pauseButton setFrame:CGRectMake(0, 0, 220, 35) ];
		[pauseButton setTitle:NSLS_ADDPAUSE forState:UIControlStateNormal];
		pauseButton.titleLabel.font =  [UIFont fontWithName:GLOBALFONTNAME2 size:17.0];
		pauseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

		[pauseButton setTitleColor:SELECTIONCOLOR forState:UIControlStateNormal];
		[pauseButton setTitleColor:NOTHIGHLIGHTED forState:UIControlStateDisabled];
		[pauseButton.titleLabel setHighlightedTextColor:NOTHIGHLIGHTED];

		[pauseButton addTarget:self action:@selector(addPause) forControlEvents:UIControlEventTouchUpInside];
		cell.accessoryView = pauseButton;
		Pause *pause = [self.currentDayEntry getLastSortedPause];
		if (self.currentDayEntry == nil || self.currentDayEntry.checkInTime == nil || (pause != nil && pause.startTime != nil && pause.endTime == nil)) {
			pauseButton.enabled = NO;
		}
	}

	// comment cell
	if (indexPath.row == (maxRowsInTable - 2)) {
		commentCell.customTextLabel.text = NSLS_COMMENT;
		commentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		commentCell.commentLabel.text = self.currentDayEntry.comment;

		if (self.currentDayEntry == nil) {
			commentCell.userInteractionEnabled = NO;
			commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		if (commentCell.userInteractionEnabled == NO) {
			commentCell.customTextLabel.textColor = NOTHIGHLIGHTED;
		} else {
			commentCell.customTextLabel.textColor = GLOBALFONTCOLOR;
		}
		return commentCell;
	}

	// hourly wage cell
	if (indexPath.row == (maxRowsInTable - 1)) {
		cell.textLabel.text = NSLS_HOURLYWAGE;
		if (self.currentDayEntry != nil) {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [self.currentDayEntry hourlyWageAsDecimalString], [self.settingsController getCurrencyIso]];
		} else {
			cell.userInteractionEnabled = NO;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}

	if (cell.userInteractionEnabled == NO) {
		cell.textLabel.textColor = NOTHIGHLIGHTED;
	} else {
		cell.textLabel.textColor = GLOBALFONTCOLOR;
	}

	return cell;
}

/**
 *  Method used with plain tableView style to eliminate the empty rows.
 */
// - (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//	return [[UIView alloc] initWithFrame:CGRectZero];
// }

/**
 *  When the last cell is about to be displayed reload the bottom part of the day-detail view.
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([indexPath row] == ((NSIndexPath *)[[tableView indexPathsForVisibleRows] lastObject]).row) {
		// end of table loading
		if (self.currentDayEntry != nil &&
            [self.currentDayEntry checkInTime] != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OPTIONS_BUTTON_NEEDSUPDATE object:@YES];
			[self updateEntryNavigationLabel];
		} else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OPTIONS_BUTTON_NEEDSUPDATE object:@NO];
			self.entryNavigationLabel.text = @"";
		}

		if (self.currentDayEntry != nil &&
            [self.currentDayEntry checkOutTime] != nil) {
			self.grossTimeLabel.text = [self.currentDayEntry grossTimeAsDecimalString];
			self.netTimeLabel.text = [self.currentDayEntry netHoursAsDecimalString];
			self.salaryLabel.text = [self.currentDayEntry salaryDisplayValue];
		} else if (self.clockTimer == nil) {
			self.grossTimeLabel.text = NULLSTRING;
			self.netTimeLabel.text = NULLSTRING;
			self.salaryLabel.text = NULLSTRING;
		}
	}
}

- (void)updateTableRoutineWithMaxNumberOfRow:(NSInteger)maxRowsInTable {
    NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:self.datePickerIndexPath.section];
    UITableViewCell *dateCell = [self.activeTableViewCenter cellForRowAtIndexPath:tempIndexPath];
    //highlight the date as in the calendar App by Apple
    dateCell.detailTextLabel.textColor = GLOBALFONTCOLOR;
    
    NSDate *checkinDate = self.currentDayEntry.checkInTime;
    // return pause if default pause will be inserted
    Pause *returnPause = [self saveCurrentRow];
    [self.activeTableViewCenter beginUpdates];
    [self hideExistingPicker];
    
    if (checkinDate == nil &&
        self.currentDayEntry.checkInTime) {
        NSArray *indexPaths = @[[NSIndexPath indexPathForRow:maxRowsInTable - 1 inSection:0],
                                [NSIndexPath indexPathForRow:maxRowsInTable - 2 inSection:0],
                                [NSIndexPath indexPathForRow:maxRowsInTable - 3 inSection:0],
                                [NSIndexPath indexPathForRow:maxRowsInTable - 4 inSection:0]];
        [self.activeTableViewCenter reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    if (returnPause) {
        NSArray *sortedPauses = [self.currentDayEntry sortedPauses];
        for (int i = 0; i < [sortedPauses count]; i++) {
            Pause *tempPause = sortedPauses[i];
            if (tempPause.startTime == returnPause.startTime &&
                tempPause.endTime == returnPause.endTime) {
                [self.activeTableViewCenter beginUpdates];
                NSArray *indexPaths = @[[NSIndexPath indexPathForRow:maxRowsInTable - 3 - [sortedPauses count] + i inSection:0]];
                
                [self.activeTableViewCenter insertRowsAtIndexPaths:indexPaths
                                                  withRowAnimation:UITableViewRowAnimationFade];
                [self.activeTableViewCenter endUpdates];
            }
        }
    }
    [self.activeTableViewCenter endUpdates];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger maxRowsInTable = [tableView numberOfRowsInSection:0];
    
    if ([self datePickerIsShown] &&
        (self.datePickerIndexPath.row != indexPath.row)) {
        
        [self updateTableRoutineWithMaxNumberOfRow:maxRowsInTable];
        return;
    }
    
    
    self.lastSelectedIndexPath = indexPath;
    
    if (indexPath.row <= 1) {
        NSIndexPath *newPickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
        [self showNewPickerAtIndex:newPickerIndexPath];
    } else if (indexPath.row == maxRowsInTable - 1) {
		// hourly wage
		AXHourlyWageViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AXHourlyWageViewController class])];
		[viewController setCurrentDayEntry:self.currentDayEntry];
		[self presentViewController:viewController animated:YES completion:^{
            self.lastSelectedIndexPath = nil;
        }];
	} else if (indexPath.row == maxRowsInTable - 2) {
		// comment
		[self comment];
	} else {
		if (indexPath.row != (maxRowsInTable - 3)) {
			AXPauseViewController *tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AXPauseViewController class])];
			Pause *pause = [self.currentDayEntry sortedPauses][indexPath.row - NUMBEROFSROWSSBEFOREPAUSESSTART];
			tableViewController.presenter = self;
			tableViewController.currentPause = pause;
			tableViewController.currentDayEntry = self.currentDayEntry;
			tableViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			[self.tabBarController presentViewController:tableViewController animated:YES completion:^{
                self.lastSelectedIndexPath = nil;
            }];
		}
	}
}

- (BOOL)datePickerIsShown {
    return self.datePickerIndexPath != nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = 44;
    if ([self datePickerIsShown] &&
        (self.datePickerIndexPath.row == indexPath.row)){
        rowHeight = 162;
    }
    return rowHeight;
}

- (void)hideExistingPicker {
    if ([self datePickerIsShown]) {
        [self.activeTableViewCenter deleteRowsAtIndexPaths:@[self.datePickerIndexPath]
                                          withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }
}

- (NSIndexPath *)calculateIndexPathForNewPicker:(NSIndexPath *)selectedIndexPath {
    NSIndexPath *newIndexPath;
    
    if (([self datePickerIsShown]) && (self.datePickerIndexPath.row < selectedIndexPath.row)){
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row - 1 inSection:0];
    } else {
        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row + 1 inSection:0];
    }
    
    return newIndexPath;
}

- (void)showNewPickerAtIndex:(NSIndexPath *)indexPath {
    [self.activeTableViewCenter beginUpdates];

    if (indexPath.row == 1 && self.currentDayEntry == nil) {
        if (![self allowedToCreateEntry]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS_WARNINGPOPUP message:NSLS_CANTCREATEENTRY delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLS_OKPOPUP, nil];
            [alert show];
            [self.activeTableViewCenter deselectRowAtIndexPath:self.lastSelectedIndexPath animated:NO];
            self.lastSelectedIndexPath = nil;
            return;
        } else if (![self allowedToCreateEntryFutureRule]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS_WARNINGPOPUP message:NSLS_FUTURERULE delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLS_OKPOPUP, nil];
            [alert show];
            [self.activeTableViewCenter deselectRowAtIndexPath:self.lastSelectedIndexPath animated:NO];
            self.lastSelectedIndexPath = nil;
            return;
        }
    }
    
    self.datePickerIndexPath = indexPath;
    NSArray *indexPaths = @[indexPath];

    [self.activeTableViewCenter insertRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.activeTableViewCenter endUpdates];
}

#pragma mark - datepicker methods
- (void)dateChanged:(id)sender {
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    if ([self datePickerIsShown]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:self.datePickerIndexPath.section];
        UITableViewCell *cell = [self.activeTableViewCenter cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = [self.dateFormatter stringFromDate:datePicker.date];
    }
}

#pragma mark - private methods
- (BOOL)allowedToCreateEntryFutureRule {
	NSDate *currentDate = [[AXDateManager sharedInstance] currentDate];
	NSDate *nowDate = [NSDate date];

	if ([currentDate compare:nowDate] == NSOrderedDescending) {
		return NO;
	}
	return YES;
}

- (BOOL)allowedToCreateEntry {
	NSDate *currentDate = [[AXDateManager sharedInstance] currentDate];
	DayEntry *tempDayEntry = [[AXDataStore sharedInstance] getLatestDayEntryForDate:currentDate];

	if (![tempDayEntry.checkInTime isSameDay:currentDate] && [tempDayEntry.checkInTime compare:currentDate] == NSOrderedAscending &&
		![tempDayEntry.checkOutTime isSameDay:currentDate] && [tempDayEntry.checkOutTime compare:currentDate] == NSOrderedDescending)
	{
		return NO;
	}

	return YES;
}

- (void)setupWithDate:(NSDate *)date {
	self.nextEntryButton.enabled = NO;
	self.currentDayEntry = nil;
	self.selectedEntry = 0;
    self.datePickerIndexPath = nil;
	if (self.clockTimer != nil) {
		[self.clockTimer invalidate];
		self.clockTimer = nil;
	}

	[[AXDateManager sharedInstance] setCurrentDate:date];
	NSArray *returnedEntries = [[AXDataStore sharedInstance] getDayEntriesForDate:date];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"checkInTime" ascending:YES];

	NSArray *sortDescriptorArray = [NSArray arrayWithObjects:sortDescriptor, nil];
	NSArray *returnArray = [returnedEntries sortedArrayUsingDescriptors:sortDescriptorArray];

	self.fetchedDayEntries = [[NSMutableArray alloc] initWithArray:returnArray];
	if (self.fetchedDayEntries.count > 0) {
		self.currentDayEntry = self.fetchedDayEntries[0];

		if (self.fetchedDayEntries.count > 1) {
			self.currentDayEntry = self.fetchedDayEntries[[self.fetchedDayEntries count] - 1];
			self.selectedEntry = [self.fetchedDayEntries count] - 1;
			for (int i = 0; i < [self.fetchedDayEntries count]; i++) {
				DayEntry *dayEntry = self.fetchedDayEntries[i];
				if (dayEntry == self.lastDayEntry) {
					self.currentDayEntry = self.fetchedDayEntries[i];
					self.selectedEntry = i;
				}
			}
		}
	}

	if (self.selectedEntry == 0) {
		self.previousEntryButton.enabled = NO;
	} else {
		self.previousEntryButton.enabled = YES;
	}

	if (self.selectedEntry == (self.fetchedDayEntries.count - 1)) {
		self.nextEntryButton.enabled = NO;
	} else {
		self.nextEntryButton.enabled = YES;
	}

	[self updateEntryNavigationLabel];
	NSDate *nowDate = [NSDate date];

	DayEntry *dayEntry = [[AXDataStore sharedInstance] getLatestDayEntryForDate:nowDate];
	if (self.currentDayEntry != nil &&
        self.currentDayEntry == dayEntry &&
        self.currentDayEntry.checkInTime != nil &&
        self.currentDayEntry.checkOutTime == nil &&
        self.clockTimer == nil) {
		[self updateClockLabels];
		self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
	}
    
    self.activeTableViewCenter.delegate = self;
    self.activeTableViewCenter.dataSource = self;

	[self.activeTableViewCenter reloadData];
}

- (Pause *)saveCurrentRow {
    if (![self datePickerIsShown]) {
        return nil;
    }

    Pause *returnPause = nil;
    AXDatePickerTableViewCell *cell = (AXDatePickerTableViewCell *)[self.activeTableViewCenter cellForRowAtIndexPath:self.datePickerIndexPath];
    UIDatePicker *datePicker = cell.datePicker;
	switch (self.datePickerIndexPath.row) {
		case 1 :
			if (self.currentDayEntry == nil) {
				self.currentDayEntry = [[AXDataStore sharedInstance] createDayEntry];
				self.fetchedDayEntries = [[NSMutableArray alloc] initWithArray:@[self.currentDayEntry]];
			}
			[self.currentDayEntry setCheckInTime:datePicker.date];
			break;
		case 2 :
            if (self.currentDayEntry.checkOutTime == nil) {
                if([self.settingsController isDefaultPause]) { //try to insert default pause
                    
                    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *checkInComponents =  [calendar components:CALENDARUNITCOMPONENTS fromDate:self.currentDayEntry.checkInTime];
                    NSDateComponents *startDefaultPauseComponents = [calendar components:CALENDARUNITCOMPONENTS fromDate:[self.settingsController getDefaultPauseStart]];
                    NSDateComponents *endDefaultPauseComponents = [calendar components:CALENDARUNITCOMPONENTS fromDate:[self.settingsController getDefaultPauseEnd]];
                    
                    startDefaultPauseComponents.year = checkInComponents.year;
                    startDefaultPauseComponents.month = checkInComponents.month;
                    startDefaultPauseComponents.day = checkInComponents.day;
                    startDefaultPauseComponents.timeZone = checkInComponents.timeZone;
                    
                    endDefaultPauseComponents.year = checkInComponents.year;
                    endDefaultPauseComponents.month = checkInComponents.month;
                    endDefaultPauseComponents.day = checkInComponents.day;
                    endDefaultPauseComponents.timeZone = checkInComponents.timeZone;
                    
                    NSDate *startDefaultPause = [calendar dateFromComponents:startDefaultPauseComponents];
                    NSDate *endDefaultPause = [calendar dateFromComponents:endDefaultPauseComponents];
                    NSDate *checkInTime = self.currentDayEntry.checkInTime;
                    NSDate *checkOutTime = datePicker.date;
                    BOOL mayInsertDefaultPause = NO;
                    
                    if ([startDefaultPause compare:checkInTime] != NSOrderedAscending &&
                        [startDefaultPause compare:checkOutTime] != NSOrderedDescending &&
                        [endDefaultPause compare:checkInTime] != NSOrderedAscending &&
                        [endDefaultPause compare:checkOutTime] != NSOrderedDescending) { // default pause is within bounds of dayentry
                        
                        mayInsertDefaultPause = YES;
                        
                        for (Pause *pause in self.currentDayEntry.pauses) {
                            //test whether default pause start or end is within an existing pause
                            if ([startDefaultPause compare:pause.startTime] != NSOrderedAscending &&
                                [startDefaultPause compare:pause.endTime] != NSOrderedDescending &&
                                [endDefaultPause compare:pause.startTime] != NSOrderedAscending &&
                                [endDefaultPause compare:pause.endTime] != NSOrderedDescending) {
                                
                                mayInsertDefaultPause = NO;
                                break;
                            }
                            //test whether a regular pause cuts the default pause
                            if ([pause.startTime compare:startDefaultPause] != NSOrderedAscending &&
                                [pause.startTime compare:endDefaultPause] != NSOrderedDescending &&
                                [pause.startTime compare:startDefaultPause] != NSOrderedAscending &&
                                [pause.startTime compare:endDefaultPause] != NSOrderedDescending) {
                                
                                mayInsertDefaultPause = NO;
                                break;
                            }
                        }
                    }
                    
                    if (mayInsertDefaultPause) {
                        Pause *defaultPause = [[AXDataStore sharedInstance] createPause];
                        defaultPause.startTime = startDefaultPause;
                        defaultPause.endTime = endDefaultPause;
                        [self.currentDayEntry addPausesObject:defaultPause];
                        returnPause = defaultPause;
                    }
                }
            }
            
			[self.currentDayEntry setCheckOutTime:datePicker.date];
            
			if (self.clockTimer != nil) {
				[self.clockTimer invalidate];
				self.clockTimer = nil;
            }
			break;
		default :
			break;
	}
    if (self.currentDayEntry != nil &&
        [self.currentDayEntry checkOutTime] != nil) {
        self.grossTimeLabel.text = [self.currentDayEntry grossTimeAsDecimalString];
        self.netTimeLabel.text = [self.currentDayEntry netHoursAsDecimalString];
        self.salaryLabel.text = [self.currentDayEntry salaryDisplayValue];
    }
    return returnPause;
}

- (void)addPause {
    if ([self datePickerIsShown]) {
        NSInteger maxRowsInTable = [self.activeTableViewCenter numberOfRowsInSection:0];
        [self updateTableRoutineWithMaxNumberOfRow:maxRowsInTable];
    }
    
	AXPauseViewController *tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AXPauseViewController class])];

	tableViewController.presenter = self;
	tableViewController.currentDayEntry = self.currentDayEntry;
	tableViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self.tabBarController presentViewController:tableViewController animated:YES completion:^{}];
}

//- (void)dismissDatePicker {
//	[self.utility hidePicker:self.cpyPickerViewController withTable:self.activeTableViewCenter withOriginalFrame:self.originalTableViewFrame];
//	if (self.lastSelectedIndexPath != nil) {
//		[self.activeTableViewCenter deselectRowAtIndexPath:self.lastSelectedIndexPath animated:NO];
//		self.lastSelectedIndexPath = nil;
//	}
//}

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

- (void)updateEntryNavigationLabel {
	if ([self.fetchedDayEntries count] > 1) {
        NSString *deviceLanguageLocaleString = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSString *labelString;
        NSInteger currentIndex = self.selectedEntry + 1;
        if (![deviceLanguageLocaleString isEqualToString:@"tr"]) {
            labelString = [NSString stringWithFormat:@"%@ %ld %@ %lu", NSLS_ENTRY, (long)currentIndex, NSLS_OF, (unsigned long)self.fetchedDayEntries.count];
        } else {
            // türkischer Sonderfall
            labelString = [NSString stringWithFormat:@"%lu %@ %ld",(unsigned long)self.fetchedDayEntries.count, NSLS_OF, (long)currentIndex];
        }

        self.entryNavigationLabel.text = labelString;
        
        if (self.buttonContainerView.alpha == 0) {
            self.buttonContainerViewHeightConstraint.constant = 50;
            self.buttonContainerView.alpha = 1;
        }
    } else {
        if (self.buttonContainerView.alpha != 0) {
            self.buttonContainerViewHeightConstraint.constant = 0;
            self.buttonContainerView.alpha = 0;
        }
    }
    [self.view layoutIfNeeded];

	if (self.clockTimer != nil) {
		[self.clockTimer invalidate];
		self.clockTimer = nil;
	}
	NSDate *nowDate = [NSDate date];

	DayEntry *dayEntry = [[AXDataStore sharedInstance] getLatestDayEntryForDate:nowDate];
	if (self.currentDayEntry != nil && self.currentDayEntry == dayEntry && self.currentDayEntry.checkInTime != nil && self.currentDayEntry.checkOutTime == nil && self.clockTimer == nil) {
		[self updateClockLabels];
		self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
	}
}

- (void)updateClock {
    if (self.currentDayEntry != nil &&
        self.currentDayEntry.checkInTime != nil &&
        self.currentDayEntry.checkOutTime == nil) {
        [self updateClockLabels];
    }
}

- (void)updateClockLabels {
	// TODO evtl basierend auf der selben info
	NSNumber *grossTimeUntilNowNumber = [NSNumber numberWithDouble:(([self.currentDayEntry secondsWorkedUntilNowAsDouble] / 60) / 60)];

	self.grossTimeLabel.text = [grossTimeUntilNowNumber timeFormatted];

	NSNumber *netTimeUntilNowNumber = [NSNumber numberWithDouble:([self.currentDayEntry netMinutesWorkedUntilNowAsDouble] / 60)];
	self.netTimeLabel.text = [netTimeUntilNowNumber timeFormatted];

	NSString *currencyString = [self.settingsController getCurrencyIso];
	NSString *currencyUntilNow = [[self.currentDayEntry salaryUntilNowDisplayValue] appendStringWithWhiteSpace:currencyString];
	self.salaryLabel.text = currencyUntilNow;
}

#pragma mark - ax calendar protocol methods
- (void)navigateForward:(BOOL)forward {
    [self saveCurrentRow];
    [self.activeTableViewCenter beginUpdates];
    [self hideExistingPicker];
    [self.activeTableViewCenter endUpdates];

	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [cal components:CALENDARUNITCOMPONENTS fromDate:[[AXDateManager sharedInstance] currentDate]];

	CGRect finalPositionForNewTable = self.activeTableViewCenter.frame;
	UITableView *newTable = [self getNonActiveTableView];

	if (forward) {
		CGRect finalPositionForNewRightTable =  self.activeTableViewCenter.frame;
		finalPositionForNewRightTable.origin.x = finalPositionForNewRightTable.origin.x + finalPositionForNewRightTable.size.width;

		CGRect finalPositonForOldTable =  self.activeTableViewCenter.frame;
		finalPositonForOldTable.origin.x = finalPositonForOldTable.origin.x - finalPositonForOldTable.size.width;

		newTable.frame = finalPositionForNewRightTable;
		[self getConstraint:newTable].constant = self.applicationFrameWidth;

		self.activeTableViewCenter = newTable;
		newTable.delegate = self;
		newTable.dataSource = self;

		[components setDay:components.day + 1];
		[self setupWithDate:[cal dateFromComponents:components]];

		[UIView animateWithDuration:ANIMATIONDURATION
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
			 self.activeTableViewCenter.frame = finalPositionForNewTable;
			 [self getConstraint:self.activeTableViewCenter].constant = 0;

			 [[self getNonActiveTableView] setFrame:finalPositonForOldTable];
			 [self getConstraint:[self getNonActiveTableView]].constant = -self.applicationFrameWidth;
		 } completion:^(BOOL finished) {
			 UITableView *nonactive = [self getNonActiveTableView];
			 nonactive.delegate = nil;
			 nonactive.dataSource = nil;
             [self.activeTableViewCenter reloadData];
			 [self.activeTableViewCenter scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
		 }];
	} else {
		CGRect finalPositionForNewLeftTable =  self.activeTableViewCenter.frame;
		finalPositionForNewLeftTable.origin.x = finalPositionForNewLeftTable.origin.x - finalPositionForNewLeftTable.size.width;

		CGRect finalPositonForOldTable =  self.activeTableViewCenter.frame;
		finalPositonForOldTable.origin.x = finalPositonForOldTable.origin.x + finalPositonForOldTable.size.width;

		newTable.frame = finalPositionForNewLeftTable;
		[self getConstraint:newTable].constant = -self.applicationFrameWidth;

		self.activeTableViewCenter = newTable;
		newTable.delegate = self;
		newTable.dataSource = self;

		[components setDay:components.day - 1];
		[self setupWithDate:[cal dateFromComponents:components]];

		[UIView animateWithDuration:ANIMATIONDURATION
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
			 self.activeTableViewCenter.frame = finalPositionForNewTable;
			 [self getConstraint:self.activeTableViewCenter].constant = 0;

			 [[self getNonActiveTableView] setFrame:finalPositonForOldTable];
			 [self getConstraint:[self getNonActiveTableView]].constant = self.applicationFrameWidth;
		 } completion:^(BOOL finished) {
			 UITableView *nonactive = [self getNonActiveTableView];
			 nonactive.delegate = nil;
			 nonactive.dataSource = nil;
             [self.activeTableViewCenter reloadData];
			 [self.activeTableViewCenter scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
		 }];
	}
}

- (void)goToToday {
	NSDate *nowDate = [NSDate date];
	[self setupWithDate:nowDate];
}

- (void)reverseCheckout {
    // sanity check
    if (self.currentDayEntry.checkInTime != nil &&
        self.currentDayEntry.checkOutTime != nil) {
        [self.currentDayEntry setCheckOutTime:nil];
        
        [self.activeTableViewCenter reloadData];
    }
}

- (void)deleteEntry {
	MEAlertView *alertView = [[MEAlertView alloc] initWithTitle:NSLS_WARNINGPOPUP message:NSLS_DELETEENTRYQ];

	[alertView setCancelButtonWithTitle:NSLS_NO_ALERTVIEW_ANSWER];

	[alertView addOtherButtonWithTitle:NSLS_YES_ALERTVIEW_ANSWER onTapped:^{
		 if (self.currentDayEntry != nil) {
			 [[AXDataStore sharedInstance] deleteObject:self.currentDayEntry];
			 [self setupWithDate:[[AXDateManager sharedInstance] currentDate]];
		 }
	 }];
	[alertView show];
}

- (void)deleteAllEntries {
	if ([self.fetchedDayEntries count] == 0) {
		return;
	}
	MEAlertView *alertView = [[MEAlertView alloc] initWithTitle:NSLS_WARNINGPOPUP message:NSLS_DELETEDAYQ];

	[alertView setCancelButtonWithTitle:NSLS_NO_ALERTVIEW_ANSWER];

	[alertView addOtherButtonWithTitle:NSLS_YES_ALERTVIEW_ANSWER onTapped:^{
		 for (DayEntry * dayEntry in self.fetchedDayEntries) {
			 [[AXDataStore sharedInstance] deleteObject:dayEntry];
		 }
		 [self setupWithDate:[[AXDateManager sharedInstance] currentDate]];
	 }];
	[alertView show];
}

- (void)addEntry {
	DayEntry *lastEntry = self.fetchedDayEntries[[self.fetchedDayEntries count] - 1];

	if ([lastEntry checkOutTime] == nil ||
        ![[lastEntry checkOutTime] isSameDay:[[AXDateManager sharedInstance] currentDate] withReceiverTimeZoneName:lastEntry.checkInTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS_WARNINGPOPUP message:NSLS_CANTADD_INCOMPLETE delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLS_OKPOPUP, nil];
		[alert show];
		return;
	}

	DayEntry *newDayEntry = [[AXDataStore sharedInstance] createDayEntry];

	[newDayEntry setCheckInTime:self.currentDayEntry.checkOutTime];
	[self.fetchedDayEntries addObject:newDayEntry];

	self.nextEntryButton.enabled = NO;
	self.previousEntryButton.enabled = YES;
	self.currentDayEntry = newDayEntry;
	self.selectedEntry = [self.fetchedDayEntries count] - 1;

	[self updateEntryNavigationLabel];
	[self.activeTableViewCenter reloadData];
}

- (void)comment {
	__weak DayEntry *dayEntry = self.currentDayEntry;
	NSString *textToDisplay = self.currentDayEntry.comment;

	[self.utility showNoteControllerWithTextToDisplay:textToDisplay onCompletion:^(NSString *textViewString) {
        
        if ([textViewString isEqualToString:dayEntry.comment]) {
            // nothing to do since the string did not change
            return;
        }
        
        // new comment
        if (![[textViewString trim] isEqualToString:@""]) {
            Comment *comment = [[AXDataStore sharedInstance] getComment:textViewString];
            if (comment) {
                comment.usage = @([comment.usage intValue] + 1);
                comment.lastUsedDate = [NSDate date];
            } else {
                comment = [[AXDataStore sharedInstance] createCommentEntity];
                comment.commentText = textViewString;
            }
        }
        
        // handle the old comment if the dayentry had one
        if (![dayEntry.comment isEqualToString:@""]) {
            Comment *comment = [[AXDataStore sharedInstance] getComment:dayEntry.comment];
            if ([comment.usage isEqualToNumber:@(1)]) {
                [[AXDataStore sharedInstance] deleteObject:comment];
            } else {
                comment.usage = @([comment.usage intValue] - 1);
            }
        }
        
        dayEntry.comment = textViewString;
        
	 } withViewController:self];
}

- (void)copyEntry {
	if (self.currentDayEntry != nil &&
        self.currentDayEntry.checkOutTime == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS_WARNINGPOPUP message:NSLS_CANTCOPY_INCOMPLETE delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLS_OKPOPUP, nil];
		[alert show];
		return;
	}

    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"CopyNavigationController"];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    AXCpyViewController *viewController = (AXCpyViewController *)navigationController.viewControllers[0];
    [viewController setCurrentDayEntry:self.currentDayEntry];

    [self presentViewController:navigationController animated:YES completion:^{
        NSDate *tempDate;
        
        if (self.currentDayEntry != nil &&
            self.currentDayEntry.checkInTime != nil) {
            tempDate = self.currentDayEntry.checkInTime;
        } else {
            // das kann gar nicht passieren
            tempDate = [[AXDateManager sharedInstance] currentDate];
        }
        
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDateComponents *components = [NSDateComponents new];
        components.day = -1;
        [viewController.datePicker setDate:[cal dateByAddingComponents:components toDate:tempDate options:0]];
    }];
}

- (void)showOptions {
    [self saveCurrentRow];
    [self.activeTableViewCenter beginUpdates];
    [self hideExistingPicker];
    [self.activeTableViewCenter endUpdates];

    DayEntry *dayEntry = [[AXDataStore sharedInstance] getLatestDayEntryForDate:[NSDate date]];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        alert.view.tintColor = SELECTIONCOLOR;
        
        UIAlertAction *addEntryAction = [UIAlertAction actionWithTitle:NSLS_ADDENTRY style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   [self addEntry];
                                                               }];
        
        UIAlertAction *deleteEntryAction = [UIAlertAction actionWithTitle:NSLS_DELETEENTRY style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [self deleteEntry];
                                                                  }];
        UIAlertAction *deleteAllEntriesAction = [UIAlertAction actionWithTitle:NSLS_DELETEDAY style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction *action) {
                                                                           [self deleteAllEntries];
                                                                       }];
        UIAlertAction *reverseCheckoutAction = [UIAlertAction actionWithTitle:NSLS_UNDOCHECKOUT style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action) {
                                                                          [self reverseCheckout];
                                                                      }];
        UIAlertAction *copyEntryAction = [UIAlertAction actionWithTitle:NSLS_COPYENTRY style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action) {
                                                                          [self copyEntry];
                                                                      }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLS_CANCEL style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *action) {
                                                            }];
        
        [alert addAction:copyEntryAction];
        [alert addAction:addEntryAction];
        [alert addAction:deleteEntryAction];
        [alert addAction:deleteAllEntriesAction];
        
        if ([self.currentDayEntry isEqual:dayEntry] &&
            self.currentDayEntry.checkOutTime != nil) {
            // reverse checkout option has to be shown, too
            [alert addAction:reverseCheckoutAction];
        }
        
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        UIActionSheet *sheet = nil;
        
        if ([self.currentDayEntry isEqual:dayEntry] &&
            self.currentDayEntry.checkOutTime != nil) {
            // reverse checkout option has to be shown, too
            sheet = [UIActionSheet SH_actionSheetWithTitle:nil buttonTitles:@[NSLS_COPYENTRY, NSLS_ADDENTRY,  NSLS_DELETEENTRY, NSLS_DELETEDAY, NSLS_UNDOCHECKOUT] cancelTitle:NSLS_CANCEL destructiveTitle:nil withBlock:^(NSInteger theButtonIndex) {
                switch (theButtonIndex) {
                    case 1 :
                        [self addEntry];
                        break;
                    case 2 :
                        [self deleteEntry];
                        break;
                    case 3 :
                        [self deleteAllEntries];
                        break;
                    case 4 :
                        [self reverseCheckout];
                        break;
                    default :
                        break;
                }
            }];
        } else {
            sheet = [UIActionSheet SH_actionSheetWithTitle:nil buttonTitles:@[NSLS_COPYENTRY, NSLS_ADDENTRY, NSLS_DELETEENTRY, NSLS_DELETEDAY] cancelTitle:NSLS_CANCEL destructiveTitle:nil withBlock:^(NSInteger theButtonIndex) {
                switch (theButtonIndex) {
                    case 1 :
                        [self addEntry];
                        break;
                    case 2 :
                        [self deleteEntry];
                        break;
                    case 3 :
                        [self deleteAllEntries];
                        break;
                    default :
                        break;
                }
            }];
        }
        
        [sheet SH_setDidDismissBlock:^(UIActionSheet *theActionSheet, NSInteger theButtonIndex) {
            switch (theButtonIndex) {
                case 0 :
                    [self copyEntry];
                    break;
                    
                default :
                    break;
            }
        }];
        
        [sheet showInView:self.view.window];
    }
}

#pragma mark - outlet user actions
- (IBAction)nextEntryAction:(id)sender {
	if (self.selectedEntry == ([self.fetchedDayEntries count] - 1) ||
        [self.fetchedDayEntries count] ==  0) {
		[((AXCalendarViewController *)self.parentViewController)navigateForward: YES];
		return;
	}
    [self saveCurrentRow];
    [self.activeTableViewCenter beginUpdates];
    [self hideExistingPicker];
    [self.activeTableViewCenter endUpdates];
    self.selectedEntry = self.selectedEntry + 1;
	self.currentDayEntry = self.fetchedDayEntries[self.selectedEntry];
	NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
	[self.activeTableViewCenter reloadSections:indexSet withRowAnimation:UITableViewRowAnimationLeft];
	if (self.selectedEntry == (self.fetchedDayEntries.count - 1)) {
		self.nextEntryButton.enabled = NO;
	}
	self.previousEntryButton.enabled = YES;
	[self updateEntryNavigationLabel];
	[self.activeTableViewCenter scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)previousEntryAction:(id)sender {
	if (self.selectedEntry == 0) {
		[((AXCalendarViewController *) self.parentViewController)navigateForward:NO];
		return;
	}
    [self saveCurrentRow];
    [self.activeTableViewCenter beginUpdates];
    [self hideExistingPicker];
    [self.activeTableViewCenter endUpdates];
    self.selectedEntry = self.selectedEntry - 1;
	self.currentDayEntry = self.fetchedDayEntries[self.selectedEntry];
	NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
	[self.activeTableViewCenter reloadSections:indexSet withRowAnimation:UITableViewRowAnimationRight];
	if (self.selectedEntry == 0) {
		self.previousEntryButton.enabled = NO;
	}
	self.nextEntryButton.enabled = YES;
	[self updateEntryNavigationLabel];
	[self.activeTableViewCenter scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - AXPauseViewControllerProtocol methods
- (void)dismissPauseTableViewController:(Pause *)pause {
	if (pause != nil) {
		[self.currentDayEntry addPausesObject:pause];
		[pause setDayentry:self.currentDayEntry];
	}
	[self.tabBarController dismissViewControllerAnimated:YES completion:^{}];
	[self.activeTableViewCenter reloadData];
}

#pragma mark - Notification methods
- (void)navigateTo:(NSNotification *)notification {
    self.lastSelectedIndexPath = nil;
    self.lastDayEntry = [self.currentDayEntry deepCopyWithDate:notification.object];
    [self setupWithDate:notification.object];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAVIGATION_TRIGGERED object:nil];
}

- (void)lastDayEntryChanged:(NSNotification *)notification {
    [self setupWithDate:[[AXDateManager sharedInstance] currentDate]];
}
@end
