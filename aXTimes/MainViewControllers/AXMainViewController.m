//
//  AXMainViewController.m
//  aXTimes
//
//  Created by fuesec on 4/27/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXMainViewController.h"
#import "AXUtility.h"
#import "NSNumber+AXNSNumberCategory.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+AXUIImageCategory.h"
#import "AXRoundButton.h"
#import "NSDate+AXNSDateCategory.h"
#import "UAAppReviewManager.h"
#import "NSString+AXNSStringCategory.h"
#import "AXAttendanceRecorder.h"
#import "NSCalendar+AXNSCalendarCategory.h"
#import "NSDateFormatter+AXDateFormatters.h"

@interface AXMainViewController ()
@property (nonatomic, strong) NSDate *todayDate;
@property (nonatomic, strong) NSDate *todayMidnightDate;
@property (nonatomic, strong) NSDate *todayEndDate;
@property (nonatomic, strong) NSDateComponents *dateComponentsTodayDate;
@property (nonatomic, strong) DayEntry *currentDayEntry;
@property (nonatomic, strong) NSArray *monthDayEntries;
@property (nonatomic, strong) NSArray *yearDayEntries;
@property (nonatomic, strong) Pause *currentPause;
@property (nonatomic, strong) NSTimer *clockTimer;
@property (nonatomic, strong) NSDateFormatter *checkInDateFormatter;
@property (strong, nonatomic) NSDateFormatter *checkInDateFormatterDayDifferent;
@property (strong, nonatomic) NSDateFormatter *checkInDateFormatterYearDifferent;
@property (nonatomic, strong) NSDateFormatter *clockDateFormatter;
@property (nonatomic, strong) SettingsManager *settingsController;
@property (nonatomic, strong) NSNumberFormatter *decimalNumberFormatter;

@property (nonatomic) BOOL checkedIn;
@property (nonatomic) BOOL paused;

@property (nonatomic) BOOL hidesDoppelpunkt;

@property (strong, nonatomic)  UILabel *checkInLabel;
@property (strong, nonatomic)  UILabel *elapsedTimeLabel;
@property (strong, nonatomic)  UILabel *zeroLowerSmallLabel;
@property (strong, nonatomic)  UILabel *firstLowerSmallLabel;
@property (strong, nonatomic)  UILabel *secondLowerSmallLabel;

@property (strong, nonatomic)  UILabel *doppelPunkt;
@property (strong, nonatomic)  UILabel *doppelPunkt2;

@property (strong, nonatomic)  UILabel *elapsedTimeLabelSmall;
@property (strong, nonatomic)  UILabel *moneyEarnedLabel;
@property (strong, nonatomic)  UILabel *currencyLabel;

@property (strong, nonatomic)  UILabel *elapsedTimeLabelSmallYear;
@property (strong, nonatomic)  UILabel *moneyEarnedLabelYear;
@property (strong, nonatomic)  UILabel *currencyLabelYear;

@property (strong, nonatomic)  UILabel *elapsedTimeLabelSmallMonth;
@property (strong, nonatomic)  UILabel *moneyEarnedLabelMonth;
@property (strong, nonatomic)  UILabel *currencyLabelMonth;

typedef void (^animationFinishBlock_t)(BOOL finished);
@property (nonatomic, strong) animationFinishBlock_t checkOutAnimationBlock;
@property (nonatomic, strong) animationFinishBlock_t pauseOutAnimationBlock;

@property ( nonatomic) CGRect originalCheckinButtonFrame;
@property ( nonatomic) CGRect originalButtonFrame;
@property ( nonatomic) CGRect originalRightButtonFrame;
@property ( nonatomic) CGRect originalLeftButtonFrame;
@property ( nonatomic) CGRect originalReverseButtonFrame;
@property ( nonatomic) CGRect miniFrame;
@property ( nonatomic) CGFloat miniFrameCornerRadius;
@property ( nonatomic) CGFloat regularCornerRadius;

@property (strong, nonatomic) AXRoundButton *checkInButton;
@property (strong, nonatomic) AXRoundButton *pauseButton;
@property (strong, nonatomic) AXRoundButton *noteButton;
@property (strong, nonatomic) AXRoundButton *checkInOnProjectButton;

//@property (strong, nonatomic) AXRoundButton *reverseCheckoutButton;

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIView *buttonView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *dataBarButtonItem;
@property (nonatomic, strong) SettingsManager *settingsManager;

@end

@implementation AXMainViewController

#pragma mark - view lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
    self.settingsManager = [SettingsManager new];

    self.title = NSLS_TABMAIN;

	self.hidesDoppelpunkt = NO;
	self.scrollView.backgroundColor = [UIColor clearColor];

	self.pageControl.currentPageIndicatorTintColor = SELECTIONCOLOR;
	self.pageControl.pageIndicatorTintColor = LIGHTGREYCOLOR;

	self.checkInDateFormatter = [NSDateFormatter new];
	[self.checkInDateFormatter setDateFormat:@"HH:mm:ss"];

	self.checkInDateFormatterDayDifferent = [NSDateFormatter new];
	self.checkInDateFormatterDayDifferent.dateFormat = @"HH:mm:ss (d. MMM)";

	self.checkInDateFormatterYearDifferent = [NSDateFormatter new];
	self.checkInDateFormatterYearDifferent.dateFormat = @"HH:mm:ss (d. MMM yy)";

	self.clockDateFormatter = [NSDateFormatter new];
	[self.clockDateFormatter setDateFormat:DATEFORMATTERDAYMAIN];

	self.settingsController = [SettingsManager new];

	self.decimalNumberFormatter = [NSNumberFormatter new];
	[self.decimalNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[self.decimalNumberFormatter setMaximumFractionDigits:2];
	[self.decimalNumberFormatter setMinimumFractionDigits:2];
	[self.decimalNumberFormatter setRoundingIncrement:[NSNumber numberWithDouble:0.01]];
	[self.decimalNumberFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];

	CGSize pagesScrollViewSize = self.scrollView.frame.size;
    
    // Other width values which were returned were not correct
    CGFloat widthApplicationFrame = [UIScreen mainScreen].applicationFrame.size.width;
	self.scrollView.contentSize = CGSizeMake(widthApplicationFrame * self.pageControl.numberOfPages, pagesScrollViewSize.height);
	self.scrollView.delegate = self;

	CGRect frame = self.scrollView.bounds;
	frame.origin.x = 10.0f;
	frame.origin.y = 10.0f;
	frame.size.width = widthApplicationFrame - 20.0f;
	frame.size.height = frame.size.height;

	UIView *timeLabelsContainerView = [[UIView alloc] initWithFrame:frame];
	timeLabelsContainerView.contentMode = UIViewContentModeScaleAspectFit;

    [self.scrollView addSubview:timeLabelsContainerView];

	frame.origin.x = (frame.size.width * 1) + (20 * 1) + 10;

	UIView *moneyLabelsContainerView = [[UIView alloc] initWithFrame:frame];
	[self.scrollView addSubview:moneyLabelsContainerView];

	frame.origin.x = (frame.size.width * 2) + (20 * 2) + 10;

	UIView *monthMoneyLabelsContainerView = [[UIView alloc] initWithFrame:frame];
	[self.scrollView addSubview:monthMoneyLabelsContainerView];

	frame.origin.x = (frame.size.width * 3) + (20 * 3) + 10;

	UIView *yearMoneyLabelsContainerView = [[UIView alloc] initWithFrame:frame];
	[self.scrollView addSubview:yearMoneyLabelsContainerView];

	[self setupTimeTickerUI:timeLabelsContainerView];

	self.elapsedTimeLabelSmall = [UILabel new];
	self.moneyEarnedLabel = [UILabel new];
	self.currencyLabel = [UILabel new];
	self.elapsedTimeLabelSmallMonth = [UILabel new];
	self.moneyEarnedLabelMonth = [UILabel new];
	self.currencyLabelMonth = [UILabel new];
	self.elapsedTimeLabelSmallYear = [UILabel new];
	self.moneyEarnedLabelYear = [UILabel new];
	self.currencyLabelYear = [UILabel new];

	[self setupMoneyTickerUIWithContainerView:moneyLabelsContainerView withTopLabel:self.elapsedTimeLabelSmall withMidLabel:self.moneyEarnedLabel withBottomLabel:self.currencyLabel];
	[self setupMoneyTickerUIWithContainerView:monthMoneyLabelsContainerView withTopLabel:self.elapsedTimeLabelSmallMonth withMidLabel:self.moneyEarnedLabelMonth withBottomLabel:self.currencyLabelMonth];
	[self setupMoneyTickerUIWithContainerView:yearMoneyLabelsContainerView withTopLabel:self.elapsedTimeLabelSmallYear withMidLabel:self.moneyEarnedLabelYear withBottomLabel:self.currencyLabelYear];

	__weak typeof(self) weakSelf = self;

	self.checkOutAnimationBlock = ^(BOOL finished) {
		[weakSelf.pauseButton setHidden:YES];
		[weakSelf.noteButton setHidden:YES];

		weakSelf.pauseButton.transform = CGAffineTransformMakeScale(1, 1);
		weakSelf.noteButton.transform = CGAffineTransformMakeScale(1, 1);
		weakSelf.checkInButton.layer.cornerRadius = weakSelf.originalCheckinButtonFrame.size.width / 2;
        weakSelf.pauseButton.layer.cornerRadius =  weakSelf.miniFrameCornerRadius;
		weakSelf.noteButton.layer.cornerRadius =  weakSelf.miniFrameCornerRadius;
		[weakSelf.pauseButton setFrame:weakSelf.miniFrame];
        [weakSelf.noteButton setFrame:weakSelf.miniFrame];
		[weakSelf.checkInButton setImage:[UIImage imageNamed:@"Check-In"] forState:UIControlStateNormal];
	};

	self.pauseOutAnimationBlock = ^(BOOL finished) {
		[weakSelf.pauseButton setSignalColor:C_CLOVER];
		[weakSelf.pauseButton setImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];

		if (weakSelf.currentDayEntry != nil) {
			NSString *checkInPrefix = NSLS_CHECKED_IN_AT;
			NSDateFormatter *tempDateFormatter = nil;
			if ([weakSelf.currentDayEntry.checkInTime isSameDay:weakSelf.todayDate withReceiverTimeZoneName:weakSelf.currentDayEntry.checkInTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
				tempDateFormatter = weakSelf.checkInDateFormatter;
			} else if ([weakSelf.currentDayEntry.checkInTime isSameMonth:weakSelf.todayDate withReceiverTimeZoneName:weakSelf.currentDayEntry.checkInTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
				tempDateFormatter = weakSelf.checkInDateFormatterDayDifferent;
			} else {
				tempDateFormatter = weakSelf.checkInDateFormatterYearDifferent;
			}
			[tempDateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:weakSelf.currentDayEntry.checkInTimeZone]];
			NSString *checkIntime = [tempDateFormatter stringFromDate:weakSelf.currentDayEntry.checkInTime];
			weakSelf.checkInLabel.text = [NSString stringWithFormat:@"%@ %@", checkInPrefix, checkIntime];

            [weakSelf.zeroLowerSmallLabel setText:[weakSelf.currentDayEntry.project displayName]];
			[weakSelf.firstLowerSmallLabel setText:weakSelf.currentDayEntry.comment];
			[weakSelf.secondLowerSmallLabel setText:@""];

			// for quicker UI update
			weakSelf.elapsedTimeLabel.text = [weakSelf.currentDayEntry secondsWorkedUntilNowDisplayValue];
			[weakSelf doppelPunktCheck:([[weakSelf.currentDayEntry minutesWorkedUntilNow] doubleValue] / (double)60.0)];

			NSString *elapsedTimeLabelSmallPrefix = NSLocalizedString(@"Working time", @"Small label on main screen for displaying the working time above money counter. Translate the prefix: Working time");
			NSString *elapsedTimeLabelSmallTime = [weakSelf.currentDayEntry secondsWorkedUntilNowDisplayValue];
			weakSelf.elapsedTimeLabelSmall.text = [NSString stringWithFormat:@"%@ %@", elapsedTimeLabelSmallPrefix, elapsedTimeLabelSmallTime];;
			weakSelf.moneyEarnedLabel.text = [weakSelf.currentDayEntry incomeUntilNowDisplayValue];
            NSDecimalNumber *monthValue = [weakSelf.currentDayEntry.incomeUntilNow decimalNumberByAdding:[DayEntry incomeForArray:weakSelf.monthDayEntries]];
			weakSelf.moneyEarnedLabelMonth.text = [weakSelf.decimalNumberFormatter stringFromNumber:monthValue];
            NSDecimalNumber *yearValue = [weakSelf.currentDayEntry.incomeUntilNow decimalNumberByAdding:[DayEntry incomeForArray:weakSelf.yearDayEntries]];
			weakSelf.moneyEarnedLabelYear.text = [weakSelf.decimalNumberFormatter stringFromNumber:yearValue];
		}

		[weakSelf.checkInButton setHidden:NO];
		weakSelf.buttonView.backgroundColor = GLOBALBACKGROUNDCOLOR2;
		weakSelf.pageControl.pageIndicatorTintColor = LIGHTGREYCOLOR;

		weakSelf.topView.backgroundColor = GLOBALBACKGROUNDCOLOR;
		weakSelf.doppelPunkt.backgroundColor = GLOBALBACKGROUNDCOLOR;
		weakSelf.doppelPunkt2.backgroundColor = GLOBALBACKGROUNDCOLOR;

		weakSelf.doppelPunkt.text = @":";
		weakSelf.doppelPunkt2.text = @":";
	};
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    NSString *currency = [self.settingsManager currencyIso];
	self.currencyLabel.text = currency;
	self.currencyLabelMonth.text = currency;
	self.currencyLabelYear.text = currency;
	self.elapsedTimeLabelSmallMonth.text = NSLS_MONEYEARNEDMONTH;
	self.elapsedTimeLabelSmallYear.text = NSLS_MONEYEARNEDYEAR;

	[self setupButtons];
    
    // initial setting of date label later update with daytransition
    self.dataBarButtonItem.title = [self.clockDateFormatter stringFromDate:[NSDate date]];
    [self.dataBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: GLOBALBACKGROUNDCOLOR}
                                          forState:UIControlStateNormal];
    [self.dataBarButtonItem setEnabled:NO];

	[self updateDateLabel];

    [self setupTodayDate];
    [self setupUI];

	if (self.clockTimer == nil) {
		self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
	}

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataModelChange:) name:NOTIFICATION_OUTSIDECHANGE_OCCURED object:nil];

    // The legacy review prompt uses UIAlertView, unavailable with scenes.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    // http://stackoverflow.com/questions/13703140/trying-to-detect-a-shake-motionended-is-never-called
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	// FIXME low priority. geht auch schöner, ist wegen ticket Ticket #336717 liegt wahrscheinlich am CAffine zeug
	[self.checkInButton removeFromSuperview];
	[self.noteButton removeFromSuperview];
	[self.pauseButton removeFromSuperview];
    [self.checkInOnProjectButton removeFromSuperview];

    [self.clockTimer invalidate];
    self.clockTimer = nil;
    
	[super viewDidDisappear:animated];
}

- (void)handleDataModelChange:(NSNotification *)notification {
    [self.checkInButton removeFromSuperview];
    [self.noteButton removeFromSuperview];
    [self.pauseButton removeFromSuperview];
    [self.checkInOnProjectButton removeFromSuperview];

    [self.clockTimer invalidate];
    self.clockTimer = nil;
    
    [self setupButtons];
    
    // initial setting of date label later update with daytransition
    self.dataBarButtonItem.title = [self.clockDateFormatter stringFromDate:[NSDate date]];
    
    [self updateDateLabel];
    
    [self setupTodayDate];
    [self setupUI];
    
    if (self.clockTimer == nil) {
        self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
    }
}

#pragma mark - private methods
- (void)checkAction {
	if (!self.checkedIn) {
        [self checkIn:nil];
	} else {
		[self checkOut];
	}
}

- (void)checkProjectAction {
    [self presentProjecSelectionViewController];
}

- (void)pauseAction {
	if (!self.paused) {
		[self pauseIn];
	} else {
		[self pauseOut];
	}
}

- (void)noteAction {
    //TODO
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    AXNoteViewController *noteViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AXNoteViewController class])];
    noteViewController.textToDisplay = self.currentDayEntry.comment;
    noteViewController.delegate = self;
    
    [self.navigationController pushViewController:noteViewController
                                         animated:YES];
}

- (void)presentProjecSelectionViewController {
    AXProjectCheckinSettingsViewController *aXProjectCheckinSettingsViewController;
    aXProjectCheckinSettingsViewController = [AXProjectCheckinSettingsViewController new];
    aXProjectCheckinSettingsViewController.checkInOnProjectDelegate = self;
    aXProjectCheckinSettingsViewController.isShowCancelAndDone = YES;
    aXProjectCheckinSettingsViewController.doneButtonTitle = NSLS_CHECKIN;
    aXProjectCheckinSettingsViewController.controllerTitle = NSLS_SETTINGS_DEFAULTPROJECT;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:aXProjectCheckinSettingsViewController];
    navigationController.extendedLayoutIncludesOpaqueBars = YES;
    
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

- (void)reverseCheckoutAction {
    NSDate *nowDate = [NSDate date];
    
    DayEntry *dayEntry = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:nowDate];
    // sanity check
    if (dayEntry.checkInTime != nil &&
        dayEntry.checkOutTime != nil) {
        [dayEntry setCheckOutTime:nil];
        
        [self setupTodayDate];
        
        [self getEntriesForSeparateMoneyCounters]; //TODO
        
        self.currentDayEntry = dayEntry;
        
        [self setCheckInUI:YES];
        
        if (self.clockTimer == nil) {
            self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
        }
    }
}

- (void)setupTodayDate {
	NSCalendar *calendar = [NSCalendar defaultCalendar_Static:YES];

	self.todayDate = [NSDate date];

    self.dataBarButtonItem.title = [self.clockDateFormatter stringFromDate:self.todayDate];

	NSDateComponents *components = [calendar components:CALENDARUNITCOMPONENTS fromDate:self.todayDate];

	self.dateComponentsTodayDate = components;

	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];

	self.todayMidnightDate = [calendar dateFromComponents:components];

	[components setHour:23];
	[components setMinute:59];
	[components setSecond:59];

	self.todayEndDate = [calendar dateFromComponents:components];
}

- (void)setupMoneyTickerUIWithContainerView:(UIView *)view withTopLabel:(UILabel *)topLabel withMidLabel:(UILabel *)midLabel withBottomLabel:(UILabel *)bottomLabel {
	CGRect subframe = view.bounds;

	subframe.origin.y = subframe.origin.y + 26;
	subframe.size.height = 20.0f;

	topLabel.frame = subframe;
	topLabel.font = [UIFont fontWithName:GLOBALFONTNAME2 size:14];
	topLabel.textAlignment = NSTextAlignmentRight;
	topLabel.textColor = GLOBALFONTCOLOR;
	[view addSubview:topLabel ];

	subframe.origin.y = subframe.origin.y + 90;

	bottomLabel.frame = subframe;
	bottomLabel.font = [UIFont fontWithName:GLOBALFONTNAME2 size:14];
	bottomLabel.textAlignment = NSTextAlignmentRight;
	bottomLabel.textColor = GLOBALFONTCOLOR;
	[view addSubview:bottomLabel];

	subframe.origin.y = 20 + 26;

	subframe.size.height = 70;

	midLabel.frame = subframe;
	midLabel.font = [UIFont fontWithName:TICKERFONTNAME size:COUNTERFONTSIZE];
	midLabel.textAlignment = NSTextAlignmentRight;
	midLabel.textColor = GLOBALFONTCOLOR;
	midLabel.adjustsFontSizeToFitWidth = YES;
	[view addSubview:midLabel];
}

- (void)setupTimeTickerUI:(UIView *)view {
	CGRect subframe = view.bounds;

	subframe.origin.y = subframe.origin.y + 26;
	subframe.size.height = 20.0f;

	self.checkInLabel = [[UILabel alloc] initWithFrame:subframe];
	self.checkInLabel.font = [UIFont fontWithName:GLOBALFONTNAME2 size:14];
	self.checkInLabel.textAlignment = NSTextAlignmentRight;
	self.checkInLabel.textColor = GLOBALFONTCOLOR;
	[view addSubview:self.checkInLabel ];

	subframe.origin.y = subframe.origin.y + 90;
    
    self.zeroLowerSmallLabel = [[UILabel alloc] initWithFrame:subframe];
    self.zeroLowerSmallLabel.font = [UIFont fontWithName:GLOBALFONTNAME2 size:14];
    self.zeroLowerSmallLabel.textAlignment = NSTextAlignmentRight;
    self.zeroLowerSmallLabel.textColor = GLOBALFONTCOLOR;
    [view addSubview:self.zeroLowerSmallLabel];
    
    subframe.origin.y = subframe.origin.y + 20;

	self.firstLowerSmallLabel = [[UILabel alloc] initWithFrame:subframe];
	self.firstLowerSmallLabel.font = [UIFont fontWithName:GLOBALFONTNAME2 size:14];
	self.firstLowerSmallLabel.textAlignment = NSTextAlignmentRight;
	self.firstLowerSmallLabel.textColor = GLOBALFONTCOLOR;
	[view addSubview:self.firstLowerSmallLabel];

	subframe.origin.y = subframe.origin.y + 20;

	self.secondLowerSmallLabel = [[UILabel alloc] initWithFrame:subframe];
	self.secondLowerSmallLabel.font = [UIFont fontWithName:GLOBALFONTNAME2 size:14];
	self.secondLowerSmallLabel.textAlignment = NSTextAlignmentRight;
	self.secondLowerSmallLabel.textColor = GLOBALFONTCOLOR;
	[view addSubview:self.secondLowerSmallLabel];

	subframe.origin.y = 20 + 26;

	subframe.size.height = 70;

	self.elapsedTimeLabel = [[UILabel alloc] initWithFrame:subframe];
	self.elapsedTimeLabel.font = [UIFont fontWithName:TICKERFONTNAME size:COUNTERFONTSIZE];
	self.elapsedTimeLabel.textAlignment = NSTextAlignmentRight;
	self.elapsedTimeLabel.textColor = GLOBALFONTCOLOR;
	self.elapsedTimeLabel.adjustsFontSizeToFitWidth = YES;
	[view addSubview:self.elapsedTimeLabel];

    CGFloat widthApplicationFrame = [UIScreen mainScreen].applicationFrame.size.width;
    CGFloat xCoordinateDoppelPunkt = 87;
    if (widthApplicationFrame == 375) {
        xCoordinateDoppelPunkt = xCoordinateDoppelPunkt + 375 - 320;
    } else if (widthApplicationFrame == 414) {
        xCoordinateDoppelPunkt = xCoordinateDoppelPunkt + 414 - 320;
    }
	self.doppelPunkt = [[UILabel alloc] initWithFrame:CGRectMake(xCoordinateDoppelPunkt, 0, 15, 70)];
	self.doppelPunkt.font = [UIFont fontWithName:@"AvenirNextCondensed-UltraLight" size:COUNTERFONTSIZE];
	self.doppelPunkt.textColor = GLOBALFONTCOLOR;
	self.doppelPunkt.backgroundColor = GLOBALBACKGROUNDCOLOR;
	self.doppelPunkt.text = @":";

	[self.elapsedTimeLabel addSubview:self.doppelPunkt];

    xCoordinateDoppelPunkt = xCoordinateDoppelPunkt + 107;
	self.doppelPunkt2 = [[UILabel alloc] initWithFrame:CGRectMake(xCoordinateDoppelPunkt, 0, 15, 70)];
	self.doppelPunkt2.font = [UIFont fontWithName:@"AvenirNextCondensed-UltraLight" size:COUNTERFONTSIZE];
	self.doppelPunkt2.textColor = GLOBALFONTCOLOR;
	self.doppelPunkt2.backgroundColor = GLOBALBACKGROUNDCOLOR;
	self.doppelPunkt2.text = @":";

	[self.elapsedTimeLabel addSubview:self.doppelPunkt2];

	// bring checkinlabel to front. do not let doppelpunkt labels cover it.
	[view bringSubviewToFront:self.checkInLabel];
    [view bringSubviewToFront:self.zeroLowerSmallLabel];
	[view bringSubviewToFront:self.firstLowerSmallLabel];
	[view bringSubviewToFront:self.secondLowerSmallLabel];
}

- (void)setupButtons {
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	CGFloat startCheckInDimension = 70.0;
	CGFloat clickedCheckInDimension = 65.0;
	CGRect checkinButtonFrame = CGRectMake((screenRect.size.width / 2.0) - startCheckInDimension / 2.0, self.pageControl.frame.origin.y + 80.0, startCheckInDimension, startCheckInDimension);
	CGRect pressedCheckInButtonFrame = CGRectMake((screenRect.size.width / 2.0) - clickedCheckInDimension / 2.0, self.pageControl.frame.origin.y + 80.0, clickedCheckInDimension, clickedCheckInDimension);

	self.originalButtonFrame = pressedCheckInButtonFrame;
	self.originalCheckinButtonFrame = checkinButtonFrame;
	self.regularCornerRadius = self.originalButtonFrame.size.width / 2;

	self.checkInButton = [[AXRoundButton alloc] initWithFrame:checkinButtonFrame andColor:SELECTIONCOLOR andBackgroudColor:GLOBALBACKGROUNDCOLOR];
	[self.checkInButton addTarget:self action:@selector(checkAction) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.checkInButton];
    
    
    CGRect rect = checkinButtonFrame;
    rect.origin.y = rect.origin.y + rect.size.height + 20;
    self.checkInOnProjectButton = [[AXRoundButton alloc] initWithFrame:rect
                                                              andColor:C_SICKNESS
                                                     andBackgroudColor:GLOBALBACKGROUNDCOLOR];
    [self.checkInOnProjectButton setImage:[UIImage imageNamed:@"projectCheckIn"] forState:UIControlStateNormal];
    [self.checkInOnProjectButton addTarget:self
                                    action:@selector(checkProjectAction)
                          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.checkInOnProjectButton];

	CGRect miniFrame = CGRectMake((screenRect.size.width / 2.0)  - 2.5, self.pageControl.frame.origin.y + 80.0 + (self.originalCheckinButtonFrame.size.height / 2  ) - 2.5, 5.0, 5.0);
	self.miniFrame = miniFrame;
	self.miniFrameCornerRadius = miniFrame.size.width / 2;

	self.pauseButton = [[AXRoundButton alloc] initWithFrame:miniFrame andColor:C_CLOVER andBackgroudColor:GLOBALBACKGROUNDCOLOR];
	[self.pauseButton addTarget:self action:@selector(pauseAction) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.pauseButton];

	self.noteButton = [[AXRoundButton alloc] initWithFrame:miniFrame andColor:GLOBALFONTCOLOR andBackgroudColor:GLOBALBACKGROUNDCOLOR];
	[self.noteButton setImage:[UIImage imageNamed:@"notes"] forState:UIControlStateNormal];
	[self.noteButton addTarget:self action:@selector(noteAction) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.noteButton];

	CGRect pausInButtonTargetFrame = self.originalButtonFrame;
	pausInButtonTargetFrame.origin.x = pausInButtonTargetFrame.origin.x - 90;
	self.originalLeftButtonFrame = pausInButtonTargetFrame;
	CGRect noteButtonTargetFrame = self.originalButtonFrame;
	noteButtonTargetFrame.origin.x = noteButtonTargetFrame.origin.x + 90;
	self.originalRightButtonFrame = noteButtonTargetFrame;
}

- (void)setupUI {
    NSDate *nowDate = [NSDate date];
    
    DayEntry *dayEntry = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:nowDate];
    
    [self setPauseOutUI:NO];
    [self setCheckOutUI:NO];
    if (dayEntry != nil &&
        dayEntry.checkInTime != nil &&
        dayEntry.checkOutTime == nil) {
        
        self.currentDayEntry = dayEntry;
        
        [self getEntriesForSeparateMoneyCounters];
        [self setCheckInUI:NO];
        
        Pause *pause = [self.currentDayEntry lastSortedPause];
        if (pause != nil && pause.startTime != nil && pause.endTime == nil) {
            self.currentPause = pause;
            [self setPauseInUI:NO];
        }
    }
}

- (void)getEntriesForSeparateMoneyCounters {
    NSDate *monthStart;
    NSDate *yearStart;
	NSCalendar *calendar = [NSCalendar defaultCalendar_Static:YES];
	NSDateComponents *components = [calendar components:CALENDARUNITCOMPONENTS
                                               fromDate:self.todayMidnightDate];
	[components setDay:1];
	NSDate *toDate = [NSDate date];
	if (self.currentDayEntry != nil) {
		toDate = self.currentDayEntry.checkInTime;
	}
    
    monthStart = [calendar dateFromComponents:components];
	self.monthDayEntries = [[AXDataStore sharedInstance]
                            getListDayEntriesDateBetween:monthStart
                            andDate:toDate];
	[components setMonth:1];
    yearStart = [calendar dateFromComponents:components];
	self.yearDayEntries = [[AXDataStore sharedInstance]
                           getListDayEntriesDateBetween:yearStart
                           andDate:toDate];
    DebugLog(@"monthStart %@ yearStart %@",
             [[NSDateFormatter formatter_fulltimeStamp:YES] stringFromDate:monthStart],
             [[NSDateFormatter formatter_fulltimeStamp:YES] stringFromDate:yearStart]);
}

- (void)checkIn:(Project *)project {
	NSDate *nowDate;

	[self setupTodayDate];
	[self getEntriesForSeparateMoneyCounters];
    
	nowDate = [NSDate date];
    
	self.currentDayEntry = [[[AXDataStore sharedInstance] managedObjectContext] newDayEntryEntityWithStart:nowDate];
    [AXAttendanceRecorder performCheckInForEntry:self.currentDayEntry
                                        withTime:nowDate
                                     withProject:project];

	[self setCheckInUI:YES];
}

- (void)setCheckInUI:(BOOL)animated {
	self.checkedIn = YES;
	[self.pauseButton setHidden:NO];
	[self.noteButton setHidden:NO];

	if (animated) {
		self.pauseButton.alpha = 0.0;
		self.noteButton.alpha = 0.0;

		[UIView animateWithDuration:ANIMATIONDURATION
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
			 self.pauseButton.alpha = 1.0;
			 self.noteButton.alpha = 1.0;

			 self.checkInButton.frame = self.originalButtonFrame;
			 self.pauseButton.frame = self.originalLeftButtonFrame;
			 self.noteButton.frame = self.originalRightButtonFrame;

			 CABasicAnimation *makeBiggerAnim = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
			 makeBiggerAnim.fromValue = [NSNumber numberWithDouble:self.miniFrameCornerRadius];
			 makeBiggerAnim.toValue = [NSNumber numberWithDouble:self.regularCornerRadius];
			 makeBiggerAnim.duration = ANIMATIONDURATION;
			 makeBiggerAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

			 CABasicAnimation *makeBiggerAnim2 = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
			 makeBiggerAnim2.fromValue = [NSNumber numberWithDouble:self.originalCheckinButtonFrame.size.width / 2.0];
			 makeBiggerAnim2.toValue = [NSNumber numberWithDouble:self.regularCornerRadius];
			 makeBiggerAnim2.duration = ANIMATIONDURATION;
			 makeBiggerAnim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

			 [self.checkInButton.layer addAnimation:makeBiggerAnim2 forKey:@"cornerRadius"];

			 [self.noteButton.layer addAnimation:makeBiggerAnim forKey:@"cornerRadius"];
			 [self.pauseButton.layer addAnimation:makeBiggerAnim forKey:@"cornerRadius"];

			 self.checkInButton.layer.cornerRadius = self.regularCornerRadius;
			 self.noteButton.layer.cornerRadius = self.regularCornerRadius;
			 self.pauseButton.layer.cornerRadius = self.regularCornerRadius;
		 } completion:^(BOOL finished) {
//             [self.reverseCheckoutButton setHidden:YES];
//             
//             self.reverseCheckoutButton.transform = CGAffineTransformMakeScale(1, 1);
//
//             self.reverseCheckoutButton.layer.cornerRadius =  self.miniFrameCornerRadius;
//             [self.reverseCheckoutButton setFrame:self.miniFrame];
		 }];
	} else {
//        [self.reverseCheckoutButton setHidden:YES];
//        
//        self.reverseCheckoutButton.transform = CGAffineTransformMakeScale(1, 1);
//        
//        self.reverseCheckoutButton.layer.cornerRadius =  self.miniFrameCornerRadius;
//        [self.reverseCheckoutButton setFrame:self.miniFrame];
        
		self.checkInButton.frame = self.originalButtonFrame;
		self.pauseButton.frame = self.originalLeftButtonFrame;
		self.noteButton.frame = self.originalRightButtonFrame;
		self.checkInButton.layer.cornerRadius = self.regularCornerRadius;
		self.noteButton.layer.cornerRadius = self.regularCornerRadius;
		self.pauseButton.layer.cornerRadius = self.regularCornerRadius;
	}

	[self.checkInButton setImage:[UIImage imageNamed:@"Check-Out"] forState:UIControlStateNormal];

	NSString *checkInPrefix = NSLS_CHECKED_IN_AT;
	NSDateFormatter *tempDateFormatter = nil;
	if ([self.currentDayEntry.checkInTime isSameDay:self.todayDate withReceiverTimeZoneName:self.currentDayEntry.checkInTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
		tempDateFormatter = self.checkInDateFormatter;
	} else if ([self.currentDayEntry.checkInTime isSameMonth:self.todayDate withReceiverTimeZoneName:self.currentDayEntry.checkInTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
		tempDateFormatter = self.checkInDateFormatterDayDifferent;
	} else {
		tempDateFormatter = self.checkInDateFormatterYearDifferent;
	}
	[tempDateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:self.currentDayEntry.checkInTimeZone]];
	NSString *checkIntime = [tempDateFormatter stringFromDate:self.currentDayEntry.checkInTime];
	self.checkInLabel.text = [NSString stringWithFormat:@"%@ %@", checkInPrefix, checkIntime];

    [self.zeroLowerSmallLabel setText:[self.currentDayEntry.project displayName]];

	[self.firstLowerSmallLabel setText:self.currentDayEntry.comment];
    
	// for quicker UI update
	self.elapsedTimeLabel.text = [self.currentDayEntry secondsWorkedUntilNowDisplayValue];
	[self doppelPunktCheck:([[self.currentDayEntry minutesWorkedUntilNow] doubleValue] / (double)60.0)];

	self.moneyEarnedLabel.text = [self.currentDayEntry incomeUntilNowDisplayValue];
    
    NSDecimalNumber *monthValue = [self.currentDayEntry.incomeUntilNow decimalNumberByAdding:[DayEntry incomeForArray:self.monthDayEntries]];
	self.moneyEarnedLabelMonth.text = [self.decimalNumberFormatter stringFromNumber:monthValue];
    NSDecimalNumber *yearValue = [self.currentDayEntry.incomeUntilNow decimalNumberByAdding:[DayEntry incomeForArray:self.yearDayEntries]];
	self.moneyEarnedLabelYear.text = [self.decimalNumberFormatter stringFromNumber:yearValue];

	NSString *elapsedTimeLabelSmallPrefix = NSLocalizedString(@"Working time", @"Small label on main screen for displaying the working time above money counter. Translate the prefix: Working time");
	NSString *elapsedTimeLabelSmallTime = [self.currentDayEntry secondsWorkedUntilNowDisplayValue];
	self.elapsedTimeLabelSmall.text = [NSString stringWithFormat:@"%@ %@", elapsedTimeLabelSmallPrefix, elapsedTimeLabelSmallTime];;
}

- (void)checkOut {
    NSDate *date = [NSDate date];
    UITabBarController *tabController = (UITabBarController *) [[self navigationController] parentViewController];
    if (tabController.viewControllers[1] != nil) {
        AXOverviewViewController *overViewController = [((UINavigationController *) tabController.viewControllers[1]) viewControllers].firstObject;
        if (overViewController != nil) {
            overViewController.selectedDateViewModel.currentlySelectedDate = date;
        }
    }
    [AXAttendanceRecorder performCheckOutForEntry:self.currentDayEntry withTime:date];
	[self setCheckOutUI:YES];
}

- (void)setCheckOutUI:(BOOL)animated {
	self.currentDayEntry = nil;
	[self getEntriesForSeparateMoneyCounters];
//    [self.reverseCheckoutButton setHidden:NO];

	// if possible show information about today's dayentry
	DayEntry *dayEntry = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:[NSDate date]];

	if (dayEntry) {
		if (dayEntry.checkOutTime != nil) {
			NSString *checkOutPrefix = NSLS_CHECKED_OUT_AT;
			NSDateFormatter *tempDateFormatter = nil;
			if ([dayEntry.checkOutTime isSameDay:self.todayDate withReceiverTimeZoneName:self.currentDayEntry.checkOutTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
				tempDateFormatter = self.checkInDateFormatter;
			} else if ([dayEntry.checkOutTime isSameMonth:self.todayDate withReceiverTimeZoneName:dayEntry.checkOutTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
				tempDateFormatter = self.checkInDateFormatterDayDifferent;
			} else {
				tempDateFormatter = self.checkInDateFormatterYearDifferent;
			}
			[tempDateFormatter setTimeZone:[[NSTimeZone alloc] initWithName:self.currentDayEntry.checkOutTimeZone]];
			NSString *checkOuttime = [tempDateFormatter stringFromDate:dayEntry.checkOutTime];
			self.checkInLabel.text = [NSString stringWithFormat:@"%@ %@", checkOutPrefix, checkOuttime];
            [self.zeroLowerSmallLabel setText:[dayEntry.project displayName]];
			[self.firstLowerSmallLabel setText:dayEntry.comment];
			self.elapsedTimeLabelSmall.text =  NSLocalizedString(@"Currently earned money", @"Small label on main screen for displaying the total money earned for last/current entry. Translate the prefix: Currently earned money");
            NSDecimalNumber *value = [[dayEntry netMinutes] decimalNumberByMultiplyingBy:[NSDecimalNumber sixty]];
			self.elapsedTimeLabel.text = [value numberAsSecondsToCountdownString];
			[self doppelPunktCheck:[[dayEntry netHours] doubleValue]];

			self.moneyEarnedLabel.text = [dayEntry incomeDisplayValueForCounter];

			self.moneyEarnedLabelMonth.text = [self.decimalNumberFormatter stringFromNumber:[DayEntry incomeForArray:self.monthDayEntries]];
			self.moneyEarnedLabelYear.text = [self.decimalNumberFormatter stringFromNumber:[DayEntry incomeForArray:self.yearDayEntries]];
		}
	} else {
		[self resetLabels];
	}

	if (animated) {
//        self.reverseCheckoutButton.alpha = 0.0;

		[UIView animateWithDuration:ANIMATIONDURATION
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
//             self.reverseCheckoutButton.alpha = 1.0;
//             self.reverseCheckoutButton.frame = self.originalReverseButtonFrame;
                             
//                             CABasicAnimation *makeBiggerAnim = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
//                             makeBiggerAnim.fromValue = [NSNumber numberWithDouble:self.miniFrameCornerRadius];
//                             makeBiggerAnim.toValue = [NSNumber numberWithDouble:self.regularCornerRadius];
//                             makeBiggerAnim.duration = ANIMATIONDURATION;
//                             makeBiggerAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//                             [self.reverseCheckoutButton.layer addAnimation:makeBiggerAnim forKey:@"cornerRadius"];
//
//                             self.reverseCheckoutButton.layer.cornerRadius = self.regularCornerRadius;

			 self.checkInButton.frame = self.originalCheckinButtonFrame;

			 self.noteButton.alpha = 0.0;
			 self.pauseButton.alpha = 0.0;

			 self.pauseButton.transform = CGAffineTransformMakeScale(0.1, 0.1);
			 self.noteButton.transform = CGAffineTransformMakeScale(0.1, 0.1);

			 CABasicAnimation *makeCornerBiggerAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
			 makeCornerBiggerAnimation.fromValue = [NSNumber numberWithDouble:self.regularCornerRadius];
			 makeCornerBiggerAnimation.toValue = [NSNumber numberWithDouble:self.originalCheckinButtonFrame.size.width / 2];
			 makeCornerBiggerAnimation.duration = ANIMATIONDURATION;
			 makeCornerBiggerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

			 [self.checkInButton.layer addAnimation:makeCornerBiggerAnimation forKey:@"cornerRadius"];
		 } completion:self.checkOutAnimationBlock];
	} else {
//        self.reverseCheckoutButton.frame = self.originalReverseButtonFrame;
//        self.reverseCheckoutButton.layer.cornerRadius = self.regularCornerRadius;
		self.checkOutAnimationBlock(NO);
	}
	self.checkedIn = NO;
}

- (void)resetLabels {
	self.checkInLabel.text =  NSLS_NOT_WORKED_TODAY;
    [self.zeroLowerSmallLabel setText:@""];
	[self.firstLowerSmallLabel setText:@""];
	[self.secondLowerSmallLabel setText:@""];
	self.elapsedTimeLabel.text = [[NSNumber numberWithDouble:(double)0]numberAsSecondsToCountdownString];

	self.elapsedTimeLabelSmall.text = NSLS_NOT_WORKED_TODAY;
	self.moneyEarnedLabel.text =  [NSString stringWithFormat:@" 0%@00", [[NSNumberFormatter new] decimalSeparator]];
	self.moneyEarnedLabelMonth.text = [self.decimalNumberFormatter stringFromNumber:[DayEntry incomeForArray:self.monthDayEntries]];
	self.moneyEarnedLabelYear.text = [self.decimalNumberFormatter stringFromNumber:[DayEntry incomeForArray:self.yearDayEntries]];
}

- (void)pauseIn {
	self.currentPause = [self.currentDayEntry.managedObjectContext newPauseEntityWithStart:[NSDate date]];
	[self.currentDayEntry addPausesObject:self.currentPause];
	[self setPauseInUI:YES];
}

- (void)setPauseInUI:(BOOL)animated {
	self.paused = YES;
    
    [self.zeroLowerSmallLabel setText:[self.currentDayEntry.project displayName]];
	[self.firstLowerSmallLabel setText:self.currentDayEntry.comment];
	[self.secondLowerSmallLabel setText:NSLS_PAUSE];

	[self.pauseButton setSignalColor:SELECTIONCOLOR];
	[self.pauseButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];

	if (animated) {
		[UIView animateWithDuration:ANIMATIONDURATION
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
			 self.checkInButton.alpha = 0.0;
			 self.checkInButton.transform = CGAffineTransformMakeScale(0.1, 0.1);
		 } completion:^(BOOL finished) {
			 [self.checkInButton setHidden:YES];
			 self.buttonView.backgroundColor = GLOBALBACKGROUNDCOLOR;
			 self.topView.backgroundColor = GLOBALBACKGROUNDCOLOR2;
			 self.pageControl.pageIndicatorTintColor = GLOBALBACKGROUNDCOLOR;
			 self.doppelPunkt.backgroundColor = GLOBALBACKGROUNDCOLOR2;
			 self.doppelPunkt2.backgroundColor = GLOBALBACKGROUNDCOLOR2;
		 }];
	} else {
		self.checkInButton.alpha = 0.0;
		self.checkInButton.transform = CGAffineTransformMakeScale(0.1, 0.1);

		[self.checkInButton setHidden:YES];
		self.buttonView.backgroundColor = GLOBALBACKGROUNDCOLOR;
		self.topView.backgroundColor = GLOBALBACKGROUNDCOLOR2;
		self.pageControl.pageIndicatorTintColor = GLOBALBACKGROUNDCOLOR;
		self.doppelPunkt.backgroundColor = GLOBALBACKGROUNDCOLOR2;
		self.doppelPunkt2.backgroundColor = GLOBALBACKGROUNDCOLOR2;
	}

	// for quicker UI update
	self.checkInLabel.text = [NSString stringWithFormat:@"%@ %@", NSLS_TIME_WORKED_TODAY, self.elapsedTimeLabel.text];
	self.elapsedTimeLabelSmall.text = [NSString stringWithFormat:@"%@ %@", NSLS_TIME_WORKED_TODAY, self.elapsedTimeLabel.text];
	self.elapsedTimeLabel.text = [self.currentPause totalTimeUntilNowWithSeconds];
	[self doppelPunktCheck:[self.currentPause hoursPaused]];

	int currentPage = 0;
	CGFloat pageWidth = self.scrollView.frame.size.width;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ANIMATIONDURATION];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	self.scrollView.contentOffset = CGPointMake(pageWidth * currentPage, 0.0f);

    [UIView commitAnimations];
}

- (void)pauseOut {
    [self.currentPause configureWithEnd:[NSDate date]
                            andTimeZone:[[NSTimeZone systemTimeZone] name]];
	if ([self.currentPause minutesPaused] < 1) {
		[[AXDataStore sharedInstance] deleteObject:self.currentPause];
    } 
	[self setPauseOutUI:YES];
}

- (void)setPauseOutUI:(BOOL)animated {
	self.currentPause = nil;

	if (animated) {
		[self.checkInButton setHidden:NO];
		[UIView animateWithDuration:ANIMATIONDURATION
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
			 self.checkInButton.alpha = 1.0;
			 self.checkInButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
		 } completion:self.pauseOutAnimationBlock];
	} else {
		self.pauseOutAnimationBlock(NO);
	}
	self.paused = NO;
}

- (CGAffineTransform)translatedAndScaledTransformUsingViewRect:(CGRect)viewRect fromRect:(CGRect)fromRect {
	CGSize scales = CGSizeMake(viewRect.size.width / fromRect.size.width, viewRect.size.height / fromRect.size.height);
	return CGAffineTransformMake(scales.width, 0, 0, scales.height, 0, 0);
}

- (void)updateDateLabel {

	if (self.todayDate != nil) {
		NSDate *nowDate = [NSDate date];

        NSInteger differenceBetweenDays = [self.todayDate daysBetween:nowDate];

		if (differenceBetweenDays > 0) {
			// setting of date label since date changed
            self.dataBarButtonItem.title = [self.clockDateFormatter stringFromDate:nowDate];
		}
	}
}

- (void)updateClock {
	[self updateDateLabel];

	if (self.currentDayEntry != nil && self.currentPause == nil) {
		if (self.currentDayEntry.checkInTime != nil && self.currentDayEntry.checkOutTime == nil) {
			self.elapsedTimeLabel.text = [self.currentDayEntry secondsWorkedUntilNowDisplayValue];
			[self doppelPunktCheck:([[self.currentDayEntry minutesWorkedUntilNow] doubleValue] / (double)60.0)];
			NSString *elapsedTimeLabelSmallPrefix = NSLocalizedString(@"Working time", @"Small label on main screen for displaying the working time above money counter. Translate the prefix: Working time");
			NSString *elapsedTimeLabelSmallTime = [self.currentDayEntry secondsWorkedUntilNowDisplayValue];
			self.elapsedTimeLabelSmall.text =   [NSString stringWithFormat:@"%@ %@", elapsedTimeLabelSmallPrefix, elapsedTimeLabelSmallTime];;
			self.moneyEarnedLabel.text = [self.currentDayEntry incomeUntilNowDisplayValue];
            NSDecimalNumber *monthValue = [self.currentDayEntry.incomeUntilNow decimalNumberByAdding:[DayEntry incomeForArray:self.monthDayEntries]];
            self.moneyEarnedLabelMonth.text = [self.decimalNumberFormatter stringFromNumber:monthValue];
            NSDecimalNumber *yearValue = [self.currentDayEntry.incomeUntilNow decimalNumberByAdding:[DayEntry incomeForArray:self.yearDayEntries]];
            self.moneyEarnedLabelYear.text = [self.decimalNumberFormatter stringFromNumber:yearValue];
		}
	} else if (self.currentPause != nil) {
		if (self.currentPause.startTime != nil && self.currentPause.endTime == nil) {
			self.elapsedTimeLabel.text = [self.currentPause totalTimeUntilNowWithSeconds];
            // FIXME long pauses UI bug
			if (self.hidesDoppelpunkt) {
				self.hidesDoppelpunkt = NO;
				self.doppelPunkt.text = @"";
				self.doppelPunkt2.text = @"";
			} else {
				self.hidesDoppelpunkt = YES;
				self.doppelPunkt.text = @":";
				self.doppelPunkt2.text = @":";
			}
		}
	}
}

- (void)doppelPunktCheck:(double)hours {
	if (hours >= 100) {
		self.doppelPunkt.hidden = YES;
		self.doppelPunkt2.hidden = YES;
	} else {
		self.doppelPunkt.hidden = NO;
		self.doppelPunkt2.hidden = NO;
	}
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	// First, determine which page is currently visible
	CGFloat pageWidth = self.scrollView.frame.size.width;
	NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));

	// Update the page control
	self.pageControl.currentPage = page;
}

#pragma mark - outlet actions
- (IBAction)pageControlAction:(id)sender {
	NSUInteger currentPage = self.pageControl.currentPage;
	CGFloat pageWidth = self.scrollView.frame.size.width;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ANIMATIONDURATION];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	self.scrollView.contentOffset = CGPointMake(pageWidth * currentPage, 0.0f);

    [UIView commitAnimations];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if (![self.settingsManager isShakeToUndo]) {
        return;
    }
    
    if (motion == UIEventSubtypeMotionShake) {
        DebugLog(@"Shake detected");
        
        // sanity check
        NSDate *nowDate = [NSDate date];
        DayEntry *dayEntry = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:nowDate];
        if (dayEntry.checkInTime != nil &&
            dayEntry.checkOutTime != nil) {
            
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:NSLS_UNDOCHECKOUT
                                        message:nil
                                        preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *undo = [UIAlertAction
                                   actionWithTitle:NSLS_UNDO
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       [self reverseCheckoutAction];
                                   }];
            
            UIAlertAction *cancel = [UIAlertAction
                                     actionWithTitle:NSLS_CANCEL
                                     style:UIAlertActionStyleCancel
                                     handler:nil];
            
            [alert addAction:undo];
            [alert addAction:cancel];
            
            [self presentViewController:alert
                               animated:YES
                             completion:nil];
        }
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - AXInitiateCheckInOnSpecificProjectProtocol

- (void)triggerCheckInOnProject:(Project *)project {
    if (!self.checkedIn) {
        [self checkIn:project];
    } else if (self.checkedIn &&
               self.paused) {
        [self pauseOut];
        [self checkOut];
        [self checkIn:project];
    } else if (self.checkedIn &&
               !self.paused) {
        //make sure to checkout before checking in
        [self checkOut];
        [self checkIn:project];
    }
}

#pragma mark - AXNoteViewControllerProtocol

- (void)doneChangingComment:(NSString *)comment {
    [AXUtility handleCommentChange:self.currentDayEntry
                           andText:comment];
}

@end
