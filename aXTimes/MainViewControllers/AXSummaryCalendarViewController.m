//
//  AXSummaryCalendarViewController.m
//  aXTimes
//
//  Created by fuesec on 5/11/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//
#import <os/log.h>

#import "AXSummaryCalendarViewController.h"
#import "AXCalculation.h"
#import "AXActivityMailItem.h"
#import "AXActivityMail.h"
#import "AXActivityMessages.h"
#import "AXActivityMessagesItem.h"
#import "AXPauseTableViewCell.h"
#import "UIImage+AXUIImageCategory.h"
#import "AXSummaryCalculationResult.h"
#import "AXSummaryAllTableViewCell.h"
#import "AXSummaryRegularTableViewCell.h"
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "SKSTableViewCellIndicator.h"
#import "NSDateFormatter+AXDateFormatters.h"
#import "NSCalendar+AXNSCalendarCategory.h"
#import "NSDate+AXNSDateCategory.h"
#import "NSNumber+AXNSNumberCategory.h"
#import "NSString+AXNSStringCategory.h"
#import "AXProjectsSummaryViewController.h"
#import "PureLayout.h"

typedef NS_ENUM (NSUInteger, SegmentType) {
    SegmentTypeWeek = 0,
    SegmentTypeMonth,
    SegmentTypeYear,
    SegmentTypeProjects
};

static NSString *summaryAllCellString = @"SummaryAllCell";
static NSString *summaryRegularCellString = @"SummaryRegularCell";
static NSString *dayTypesSummaryCellString = @"DayTypesSummaryTableViewCell";

@interface AXSummaryCalendarViewController ()

@property (strong, nonatomic) AXProjectsSummaryViewController *aXProjectsSummaryViewController;

@property (strong, nonatomic) NSMutableArray<DayEntry *> *fetchedDayEntries;
@property (strong, nonatomic) NSDateFormatter *currentlyActiveDateFormatter;
@property (strong, nonatomic) NSDateFormatter *currentlyActiveExportDateFormatter;

@property (strong, nonatomic) NSArray *dateFormatters;
@property (strong, nonatomic) NSArray *exportDateFormatters;

@property (strong, nonatomic) NSDateFormatter *yearDateFormatter;
@property (strong, nonatomic) NSDateFormatter *monthDateFormatter;
@property (strong, nonatomic) NSDateFormatter *yearExportDateFormatter;
@property (strong, nonatomic) NSDateFormatter *monthExportDateFormatter;
@property (strong, nonatomic) NSCalendar *calendar;
@property (nonatomic, strong) AXCalculation *axcalculator;
@property (nonatomic, strong) AXSummaryCalculationResult *calculationResult;
@property (strong, nonatomic) UIImage *plannedWorkImage;
@property (strong, nonatomic) UIImage *cashImage;
@property (strong, nonatomic) UIImage *overtimeImage;
@property (strong, nonatomic) UIImage *averageImage;
@property (strong, nonatomic) UIColor *globalBackgroundColor;
@property (strong, nonatomic) UIColor *globalFontColor;
@property UIEdgeInsets cellEdgeInsets;

@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (strong, nonatomic) SKSTableView *activeTableViewCenter;
@property (strong, nonatomic) NSLayoutConstraint *activeTableViewContraint;

@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UIButton *previousButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableView2Constraint;
@property (strong, nonatomic) IBOutlet SKSTableView *tableView;
@property (strong, nonatomic) IBOutlet SKSTableView *tableView2;
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *calendarSegmentedControl;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *dateHeaderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateHeaderViewHeight;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSMutableDictionary<NSManagedObjectID *, AXSummaryCalculationResult *> *projectResults;

@property (nonatomic, strong) SettingsManager *settingsManager;

@end

@implementation AXSummaryCalendarViewController
@synthesize fetchedResultsController = __fetchedResultsController;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self =  [super initWithCoder:aDecoder];
	if (self) {
		/*A common mistake is to use YYYY. yyyy specifies the calendar year whereas YYYY specifies the year (of "Week of Year"), used in the ISO year-week calendar. In most cases, yyyy and YYYY yield the same number, however they may be different. Typically you should use the calendar year. */

        self.calendar = [NSCalendar defaultCalendar_Static:YES];
        
		self.monthDateFormatter = [NSDateFormatter formatter_Month_Year_Static:NO];

		self.yearDateFormatter = [NSDateFormatter new];
		self.yearDateFormatter.dateFormat = @"yyyy";

		self.monthExportDateFormatter = [NSDateFormatter new];
		self.monthExportDateFormatter.dateFormat = @"yyyy_MM";

		self.yearExportDateFormatter = [NSDateFormatter new];
		self.yearExportDateFormatter.dateFormat = @"yyyy";

		self.dateFormatters = @[self.monthDateFormatter, self.yearDateFormatter];
		self.exportDateFormatters = @[self.monthExportDateFormatter, self.yearExportDateFormatter];

		self.currentlyActiveDateFormatter = self.dateFormatters[0];
		self.currentlyActiveExportDateFormatter = self.exportDateFormatters[0];
		self.headerLabel.text = [[self.currentlyActiveDateFormatter stringFromDate:self.selectedDateViewModel.currentlySelectedDate] capitalizedString];
		self.axcalculator = [AXCalculation new];
        
        self.plannedWorkImage = [[UIImage imageNamed:@"working_time"] imageWithBurnTint:C_SKY];
        self.overtimeImage = [[UIImage imageNamed:@"overtime"] imageWithBurnTint:C_MAROON];
        self.averageImage = [[UIImage imageNamed:@"average"] imageWithBurnTint:C_MOCHA];
        self.cashImage = [[UIImage imageNamed:@"income"] imageWithBurnTint:C_FERN];
        
		self.globalBackgroundColor = GLOBALBACKGROUNDCOLOR;
		self.globalFontColor = GLOBALFONTCOLOR;
		self.cellEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
	}
	return self;
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingsManager = [SettingsManager new];

    self.projectResults = [NSMutableDictionary new];
    
    self.title = NSLS_TABSUMMARY;
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                  target:self
                                                                                  action:@selector(shareAction)];
    self.navigationItem.rightBarButtonItem = actionButton;

    UIBarButtonItem *sideMenuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showSideMenu)];
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:NSLS_TODAY
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(today)];
    self.navigationItem.leftBarButtonItems = @[sideMenuButton, todayButton];

    self.headerView.backgroundColor = GLOBALBACKGROUNDCOLOR;

	// bug storyboard localization does not work so we set title manually
	[self.calendarSegmentedControl setTitle:NSLS_WEEK
                          forSegmentAtIndex:SegmentTypeWeek];
	[self.calendarSegmentedControl setTitle:NSLS_MONTH
                          forSegmentAtIndex:SegmentTypeMonth];
	[self.calendarSegmentedControl setTitle:NSLS_YEAR
                          forSegmentAtIndex:SegmentTypeYear];
    [self.calendarSegmentedControl setTitle:NSLS_PROJECTS
                          forSegmentAtIndex:SegmentTypeProjects];

    CGFloat applicationFrameWidth = [UIScreen mainScreen].bounds.size.width;
	self.tableView2Constraint.constant = applicationFrameWidth;

    UINib *summaryAllCellNib = [UINib nibWithNibName:NSStringFromClass([AXSummaryAllTableViewCell class]) bundle:nil];
    [self.tableView registerNib:summaryAllCellNib forCellReuseIdentifier:summaryAllCellString];
    [self.tableView2 registerNib:summaryAllCellNib forCellReuseIdentifier:summaryAllCellString];
    UINib *summaryRegularCellNib = [UINib nibWithNibName:NSStringFromClass([AXSummaryRegularTableViewCell class]) bundle:nil];
    [self.tableView registerNib:summaryRegularCellNib forCellReuseIdentifier:summaryRegularCellString];
    [self.tableView2 registerNib:summaryRegularCellNib forCellReuseIdentifier:summaryRegularCellString];
    UINib *dayTypesSummaryCellNib = [UINib nibWithNibName:dayTypesSummaryCellString bundle:nil];
    [self.tableView registerNib:dayTypesSummaryCellNib forCellReuseIdentifier:dayTypesSummaryCellString];
    [self.tableView2 registerNib:dayTypesSummaryCellNib forCellReuseIdentifier:dayTypesSummaryCellString];

    self.tableView.SKSTableViewDelegate = self;

	self.activeTableViewCenter = self.tableView;
	self.activeTableViewContraint = self.tableViewConstraint;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView2.rowHeight = UITableViewAutomaticDimension;
    self.tableView2.estimatedRowHeight = 44.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView2.separatorStyle = UITableViewCellSeparatorStyleNone;

    
    // fix for empty space at the top
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, CGFLOAT_MIN)];
    self.tableView2.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView2.bounds.size.width, CGFLOAT_MIN)];
    
    self.aXProjectsSummaryViewController = [AXProjectsSummaryViewController new];
    self.aXProjectsSummaryViewController.fetchedResultsController = self.fetchedResultsController;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(contextDidSave:)
     name:NSManagedObjectContextDidSaveNotification
     object:[[AXDataStore sharedInstance] managedObjectContext]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self setupWithDate:self.selectedDateViewModel.currentlySelectedDate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Fix for glitch since iOS 8
    [self.activeTableViewCenter reloadData];
}

#pragma mark - barbuttonitem methods

- (void)showSideMenu {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)today {
    [self setupWithDate:[NSDate date]];
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        // net time, overtime, average time per day, salary
        return 4;
    } else {
        // alles in einer zelle: sollarbeitszeit, days off, public holiday, vacation, sickness
        return 1;
    }
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtSection:(NSInteger)section atRow:(NSInteger)row {
    if (section == 1) {
        return [self numberOfProjects];
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubSubRowsAtSection:(NSInteger)section atRow:(NSInteger)row atSubRow:(NSInteger)subRow {
    if (section == 1) {
        if ([self.fetchedResultsController sections] == nil) {
            return 0;
        }
        Project *tempProject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:subRow - 1 inSection:0]];
        
        return [[tempProject sortedSubProjectsWithFilterActivated] count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(SKSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0 ||
            indexPath.row == 1) {
            AXSummaryAllTableViewCell *summaryAllCell = nil;
            summaryAllCell = [tableView dequeueReusableCellWithIdentifier:summaryAllCellString
                                                             forIndexPath:indexPath.indexPath];
            [summaryAllCell setSecondaryColor:GLOBALBACKGROUNDCOLOR2];
            summaryAllCell.backgroundColor = GLOBALBACKGROUNDCOLOR;
            
            summaryAllCell.expandable = YES;
            summaryAllCell.selectionStyle = UITableViewCellSelectionStyleDefault;
            summaryAllCell.timeRangeLabel.text = @"";
            summaryAllCell.totalTimeLabel.text = @"";
            summaryAllCell.totalTimeLabel.textColor = self.globalFontColor;
            summaryAllCell.totalTimeLabel.textAlignment = NSTextAlignmentRight;
            summaryAllCell.timeRangeLabel.textColor = self.globalFontColor;
            summaryAllCell.timeRangeLabel.textAlignment = NSTextAlignmentRight;
            //        [summaryAllCell setSeparatorInset:self.cellEdgeInsets];
            
            if (indexPath.row == 0) {
                summaryAllCell.customTextLabel.text = NSLS_WORKINGTIME;
                summaryAllCell.customImageView.image = self.plannedWorkImage;
                //            summaryAllCell.iconBackground.backgroundColor = SELECTIONCOLOR;
                summaryAllCell.iconBackground.backgroundColor = GLOBALBACKGROUNDCOLOR;
                summaryAllCell.timeRangeLabel.text = self.calculationResult.displayInfo.netWorkingTimeHours;
                // HIER
                summaryAllCell.totalTimeLabel.text = self.calculationResult.displayInfo.netWorkingTimeDays;
            } else if (indexPath.row == 1) {
                summaryAllCell.expandable = NO;
                summaryAllCell.selectionStyle = UITableViewCellSelectionStyleNone;

                summaryAllCell.customTextLabel.text = NSLS_OVERTIME;
                summaryAllCell.customImageView.image = self.overtimeImage;
                //            summaryAllCell.iconBackground.backgroundColor = C_MAROON;
                summaryAllCell.iconBackground.backgroundColor = GLOBALBACKGROUNDCOLOR;
                summaryAllCell.timeRangeLabel.text = self.calculationResult.displayInfo.overtimeHours;
                summaryAllCell.totalTimeLabel.text = self.calculationResult.displayInfo.overtimeDays;
                if (self.calculationResult.displayInfo.overtimeUseColor) {
                    summaryAllCell.timeRangeLabel.textColor = self.calculationResult.displayInfo.overTimeColor;
                    summaryAllCell.totalTimeLabel.textColor = self.calculationResult.displayInfo.overTimeColor;
                } else {
                    summaryAllCell.timeRangeLabel.textColor = self.globalFontColor;
                    summaryAllCell.totalTimeLabel.textColor = self.globalFontColor;
                }
            }
            return summaryAllCell;
        } else {
            AXSummaryRegularTableViewCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:summaryRegularCellString
                                                   forIndexPath:indexPath.indexPath];
            [cell setSecondaryColor:GLOBALBACKGROUNDCOLOR2];
            cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
            cell.expandable = YES;

            if (indexPath.row == 2) {
                cell.customTextLabel.text = NSLS_AVERAGE_TIME_PER_DAY;
                cell.customImageView.image = self.averageImage;
                //            cell.iconBackground.backgroundColor = C_MOCHA;
                cell.iconBackground.backgroundColor = GLOBALBACKGROUNDCOLOR;
                cell.customDetailTextLabel.text = self.calculationResult.displayInfo.averageTimePerDay;
            } else if (indexPath.row == 3) {
                cell.customTextLabel.text = NSLS_SALARY;
                cell.customImageView.image = self.cashImage;
                //            cell.iconBackground.backgroundColor = C_FERN;
                cell.iconBackground.backgroundColor = GLOBALBACKGROUNDCOLOR;
                cell.customDetailTextLabel.text = self.calculationResult.displayInfo.income;
            }
            return cell;
        }
    } else {
        DayTypesSummaryTableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:dayTypesSummaryCellString
                                               forIndexPath:indexPath.indexPath];
        cell.workDayLabel.text = self.calculationResult.displayInfo.plannedWorkingTimeDays;
        cell.dayOffLabel.text = self.calculationResult.displayInfo.dayOff;
        cell.publicHolidayLabel.text = self.calculationResult.displayInfo.publicHolidays;
        cell.vacationLabel.text = self.calculationResult.displayInfo.vacation;
        cell.sicknessLabel.text = self.calculationResult.displayInfo.sickness;
        
        return cell;
    }
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubSubRowsOfCellAtSection:(NSInteger)section atRow:(NSInteger)row atSubRow:(NSInteger)subRow {
    return NO;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(SKSIndexPath *)indexPath {
    NSIndexPath *fetchIndexPath = [NSIndexPath indexPathForRow:indexPath.subRow - 1
                                                     inSection:0];
    Project *tempProject = [self.fetchedResultsController objectAtIndexPath:fetchIndexPath];
    AXSummaryCalculationResult *calculationResult = self.projectResults[tempProject.objectID];
    
    if (indexPath.row == 0) {
        AXSummaryAllTableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:summaryAllCellString
                                               forIndexPath:indexPath.indexPath];
        [cell setSecondaryColor:GLOBALBACKGROUNDCOLOR];
        [cell setBackgroundColor:GLOBALBACKGROUNDCOLOR2];
        cell.expandable = YES;
        cell.timeRangeLabel.text = NULLSTRING;
        cell.totalTimeLabel.text = NULLSTRING;
        
        cell.customTextLabel.text = [tempProject displayName];
        if ([[tempProject sortedSubProjectsWithFilterActivated] count] > 0) {
            cell.expandable = YES;
        } else {
            cell.expandable = NO;
        }
        
        if (calculationResult) {
            if (indexPath.row == 0) {
                cell.timeRangeLabel.text = calculationResult.displayInfo.netWorkingTimeHours;
                cell.totalTimeLabel.text = calculationResult.displayInfo.netWorkingTimeDays;
                
            } else if (indexPath.row == 1) {
                cell.timeRangeLabel.text = calculationResult.displayInfo.overtimeHours;
                cell.totalTimeLabel.text = calculationResult.displayInfo.overtimeDays;
                if (self.calculationResult.displayInfo.overtimeUseColor) {
                    cell.timeRangeLabel.textColor = calculationResult.displayInfo.overTimeColor;
                    cell.totalTimeLabel.textColor = calculationResult.displayInfo.overTimeColor;
                } else {
                    cell.timeRangeLabel.textColor = self.globalFontColor;
                    cell.totalTimeLabel.textColor = self.globalFontColor;
                }
            }
        }
        
        cell.customImageView.image = nil;

        return cell;
    } else {
        AXSummaryRegularTableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:summaryRegularCellString
                                               forIndexPath:indexPath.indexPath];
        [cell setSecondaryColor:GLOBALBACKGROUNDCOLOR];
        [cell setBackgroundColor:GLOBALBACKGROUNDCOLOR2];
        
        cell.customTextLabel.text = [tempProject displayName];
        if ([[tempProject sortedSubProjectsWithFilterActivated] count] > 0) {
            cell.expandable = YES;
        } else {
            cell.expandable = NO;
        }
        
        if (calculationResult) {
            if (indexPath.row == 2) {
                cell.customDetailTextLabel.text = calculationResult.displayInfo.averageTimePerDay;
            } else if (indexPath.row == 3) {
                cell.customDetailTextLabel.text = calculationResult.displayInfo.income;
            }
        }
        cell.customImageView.image = nil;
        return cell;
    }
}

- (UITableViewCell *)tableView:(SKSTableView *)tableView cellForSubSubRowAtIndexPath:(SKSIndexPath *)indexPath {
    Project *tempProject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.subRow - 1
                                                                                               inSection:0]];
    
    NSArray<Project *> *subProjects = [tempProject sortedSubProjectsWithFilterActivated];
    Project *subProject = subProjects[indexPath.subSubRow - 1];
    AXSummaryCalculationResult *calculationResult = self.projectResults[subProject.objectID];
    
    if (indexPath.row == 0 ||
        indexPath.row == 1) {
        AXSummaryAllTableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:summaryAllCellString
                                               forIndexPath:indexPath.indexPath];
        cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
        cell.timeRangeLabel.text = NULLSTRING;
        cell.totalTimeLabel.text = NULLSTRING;
        cell.expandable = NO;
        cell.customTextLabel.text = subProject.name;
        
        if (calculationResult) {
            if (indexPath.row == 0) {
                cell.timeRangeLabel.text = calculationResult.displayInfo.netWorkingTimeHours;
                cell.totalTimeLabel.text = calculationResult.displayInfo.netWorkingTimeDays;
                
            } else if (indexPath.row == 1) {
                cell.timeRangeLabel.text = calculationResult.displayInfo.overtimeHours;
                cell.totalTimeLabel.text = calculationResult.displayInfo.overtimeDays;
                if (self.calculationResult.displayInfo.overtimeUseColor) {
                    cell.timeRangeLabel.textColor = calculationResult.displayInfo.overTimeColor;
                    cell.totalTimeLabel.textColor = calculationResult.displayInfo.overTimeColor;
                } else {
                    cell.timeRangeLabel.textColor = self.globalFontColor;
                    cell.totalTimeLabel.textColor = self.globalFontColor;
                }
            }
        }
        cell.customImageView.image = nil;
        return cell;
    } else {
        AXSummaryRegularTableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:summaryRegularCellString
                                               forIndexPath:indexPath.indexPath];
        cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
        cell.expandable = NO;
        cell.customTextLabel.text = subProject.name;
        
        if (calculationResult) {
            if (indexPath.row == 2) {
                cell.customDetailTextLabel.text = calculationResult.displayInfo.averageTimePerDay;
            } else if (indexPath.row == 3) {
                cell.customDetailTextLabel.text = calculationResult.displayInfo.income;
                
            }
        }
        cell.customImageView.image = nil;
        return cell;
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"Section: %d, Row:%d, Subrow:%d", indexPath.section, indexPath.row, indexPath.subRow);
//    
//}
//
//- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"Section: %d, Row:%d, Subrow:%d", indexPath.section, indexPath.row, indexPath.subRow);
//    
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 2) {
//        return 144.0;
//    }
//    return UITableViewAutomaticDimension;
//}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return 144.0;
    }
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}


#pragma mark - user outlet actions

- (IBAction)segementedControlAction:(id)sender {
    if (self.calendarSegmentedControl.selectedSegmentIndex == SegmentTypeProjects) {
        self.fetchedResultsController = nil;
        self.aXProjectsSummaryViewController.fetchedResultsController = self.fetchedResultsController;            
        [self.view addSubview:self.aXProjectsSummaryViewController.view];
        [self.aXProjectsSummaryViewController.view autoPinEdge:ALEdgeTop
                              toEdge:ALEdgeBottom
                              ofView:self.dateHeaderView];
        [self.aXProjectsSummaryViewController.view autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
        [self.aXProjectsSummaryViewController.view autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
        [self.aXProjectsSummaryViewController.view autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        self.dateHeaderViewHeight.constant = 0;
        self.nextButton.hidden = YES;
        self.previousButton.hidden = YES;
        self.headerLabel.hidden = YES;
        return;
    } else {
        self.dateHeaderViewHeight.constant = 44;
        self.nextButton.hidden = NO;
        self.previousButton.hidden = NO;
        self.headerLabel.hidden = NO;
        [self.aXProjectsSummaryViewController.view removeFromSuperview];
    }
    
    
    if ([self.calendarSegmentedControl selectedSegmentIndex] == SegmentTypeMonth) {
        self.currentlyActiveDateFormatter = self.dateFormatters[0];
        self.currentlyActiveExportDateFormatter = self.exportDateFormatters[0];
    } else if ([self.calendarSegmentedControl selectedSegmentIndex] == SegmentTypeYear) {
        self.currentlyActiveDateFormatter = self.dateFormatters[1];
        self.currentlyActiveExportDateFormatter = self.exportDateFormatters[1];
    }

	[self setupWithDate:self.selectedDateViewModel.currentlySelectedDate];
}

- (IBAction)nextAction:(id)sender {
	[self navigateForward:YES];
}

- (IBAction)previousAction:(id)sender {
	[self navigateForward:NO];
}

#pragma mark - private methods

- (NSUInteger)numberOfProjects {
    if ([self.fetchedResultsController sections] == nil) {
        return 0;
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (void)showIntermediaryView { //TODO currently unused
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"My Alert"
                                                                   message:@"This is an alert."
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Regular report"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self shareAction];
                                                          }];
    UIAlertAction *projecReportAction = [UIAlertAction actionWithTitle:@"Project report"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {}];
    UIAlertAction *projectReportAllDetailsAction = [UIAlertAction actionWithTitle:@"Project report with all details"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLS_CANCEL
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:defaultAction];
    [alert addAction:projecReportAction];
    [alert addAction:projectReportAllDetailsAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

- (void)shareAction {
    NSString *fileExtension = @"csv";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = NSTemporaryDirectory();
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filenameToDelete;
    
    while ((filenameToDelete = [e nextObject])) {
        if ([[filenameToDelete pathExtension] isEqualToString:fileExtension]) {
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filenameToDelete] error:NULL];
        }
    }
    
    NSData *data = nil;

    NSError *error = nil;
    SettingsManager *settingsManager = [SettingsManager new];
    @try {
        NSMutableArray<DayEntry *> *tempArray = [NSMutableArray new];
        for (DayEntry *entry in self.fetchedDayEntries) {
            if (entry.project.parent != nil) {
                if ([self.fetchedResultsController.fetchedObjects containsObject:entry.project.parent]) {
                    [tempArray addObject:entry];
                }
            } else if ([self.fetchedResultsController.fetchedObjects containsObject:entry.project]) {
                [tempArray addObject:entry];
            }
        }
        
        if (self.calendarSegmentedControl.selectedSegmentIndex == SegmentTypeWeek ||
            self.calendarSegmentedControl.selectedSegmentIndex == SegmentTypeMonth ) {
            EntriesExport *entriesExport = [[EntriesExport alloc]
                                            initWithEntries:tempArray
                                            projects:self.fetchedResultsController.fetchedObjects
                                            mainResult:self.calculationResult
                                            projectResults:self.projectResults
                                            settingsManager:settingsManager];
            data = [entriesExport dataAndReturnError:&error];
        } else if (self.calendarSegmentedControl.selectedSegmentIndex == SegmentTypeProjects) {
            ProjectExport *projectExport = [[ProjectExport alloc]
                                            initWithProjects:self.fetchedResultsController.fetchedObjects
                                            settingsManager:settingsManager];
            data = [projectExport dataAndReturnError:&error];
        } else {
            EntriesYearExport *entriesYearExport = [[EntriesYearExport alloc]
                                                    initWithEntries:tempArray
                                                    settingsManager:settingsManager
                                                    calculation:[AXCalculation new]];
            data = [entriesYearExport dataAndReturnError:&error];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS_WARNINGPOPUP
                                                        message:exception.reason
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLS_OKPOPUP, nil];
        [alert show];
    }
    
    NSString *recipientFromSettings = [self.settingsManager exportEmail];
    NSString *recipient;
    if ([recipientFromSettings isEqualToString:@""]) {
        recipient = @"";
    } else {
        recipient = [NSString stringWithFormat:@"%@", recipientFromSettings];
    }
    
    NSArray *recipientsArray = @[recipient];
    NSMutableArray *activityItems = [NSMutableArray array];
    
    NSString *subjectDateFormatted = @"";
    if ([self.calendarSegmentedControl selectedSegmentIndex] == SegmentTypeWeek) {
        subjectDateFormatted = [self.selectedDateViewModel.currentlySelectedDate formatAs_weekOfYear_yearForWeekOfYear];
    } else {
        subjectDateFormatted = [self.currentlyActiveDateFormatter stringFromDate:self.selectedDateViewModel.currentlySelectedDate];
    }
    
    NSString *mailSubject = [NSString stringWithFormat:@"%@ %@ %@", APPLICATIONNAME, NSLS_REPORT, subjectDateFormatted];
    
    NSString *fileName = @"_";
    
    NSString *scope = [self.calendarSegmentedControl titleForSegmentAtIndex:self.calendarSegmentedControl.selectedSegmentIndex];
    
    NSString *dateFormatted = @"";
    if ([self.calendarSegmentedControl selectedSegmentIndex] == SegmentTypeWeek) {
        dateFormatted = [self.selectedDateViewModel.currentlySelectedDate formatAs_weekOfYear_yearForWeekOfYear];
    } else {
        dateFormatted = [self.currentlyActiveExportDateFormatter stringFromDate:self.selectedDateViewModel.currentlySelectedDate];
    }
    
    fileName = [NSString stringWithFormat:@"%@_%@_%@.%@", APPLICATIONNAME, scope, dateFormatted, fileExtension];
    
    NSString *tempFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    [data writeToFile:tempFileTemplate atomically:YES];
    NSURL *urlForOpenIn = [NSURL fileURLWithPath:tempFileTemplate];
    
    [activityItems addObject:urlForOpenIn];
    
    __weak typeof(self) weakSelf = self;
    [activityItems addObject:[AXActivityMailItem mailActivityItemWithSelectionHandler:^(MFMailComposeViewController *mailController) {
        mailController.navigationBar.tintColor = [UIColor whiteColor];
        
        [mailController setToRecipients:recipientsArray];
        [mailController setSubject:mailSubject];
        [mailController setMessageBody:CHEERS isHTML:NO];
        [mailController addAttachmentData:data mimeType:@"text/csv" fileName:fileName];
        return (UIViewController *)weakSelf;
        
    }]];
    
    [activityItems addObject:[AXActivityMessagesItem messageActivityItemWithSelectionHandler:^(MFMessageComposeViewController *messageController) {
        [messageController addAttachmentData:data typeIdentifier:@"public.data" filename:fileName];
        return (UIViewController *)weakSelf;
    }]];
    
    [activityItems addObject:data];
    NSString *csvString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [activityItems addObject:csvString];
    
    // The system share sheet offers compatible apps for the CSV file URL.
    NSArray *activities = (@[[AXActivityMail new], [AXActivityMessages new]]);
    
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                    applicationActivities:activities];
    // turn off Apple's activities
    // do it before setting the tintcolor
    // http://stackoverflow.com/questions/30078598/cant-exclude-uiactivitytypeposttofacebook-from-uiactivityviewcontroller-exclud
    self.activityViewController.excludedActivityTypes = (@[ UIActivityTypeMail,
                                                            UIActivityTypeMessage,
                                                            UIActivityTypePostToFacebook,
                                                            UIActivityTypePostToTwitter,
                                                            UIActivityTypePostToWeibo,
                                                            UIActivityTypePrint,
                                                            UIActivityTypeSaveToCameraRoll,
                                                            UIActivityTypePostToTencentWeibo,
                                                            UIActivityTypePostToFlickr,
                                                            UIActivityTypeAssignToContact,
                                                            UIActivityTypeAddToReadingList,
                                                            UIActivityTypeAirDrop
                                                            ]);
    
    [self presentViewController:self.activityViewController
                       animated:YES
                     completion:nil];
}



- (void)setupWithDate:(NSDate *)date {
    self.fetchedResultsController = nil;
    
    if (self.calendarSegmentedControl.selectedSegmentIndex == SegmentTypeProjects) {
        self.aXProjectsSummaryViewController.fetchedResultsController = self.fetchedResultsController;
        [self.aXProjectsSummaryViewController reload];
        
        //EXIT
        return;
    }

    self.selectedDateViewModel.currentlySelectedDate = date;

	if ([self.calendarSegmentedControl selectedSegmentIndex] == SegmentTypeWeek) {
		self.headerLabel.text = [date formatAs_weekOfYear_yearForWeekOfYear];
	} else {
		self.headerLabel.text = [[self.currentlyActiveDateFormatter stringFromDate:date] capitalizedString];
	}

	[self getDayEntries];
    AXDayTypesCalculationResult *dayTypecalculationsResult;

    DayEntry *entry = nil;
    
    if ([self.fetchedDayEntries count] > 0) {
        entry = self.fetchedDayEntries[[self.fetchedDayEntries count] - 1];
    }
    
    NSInteger selectedIndex = [self.calendarSegmentedControl
                               selectedSegmentIndex] + 1;
    
    dayTypecalculationsResult = [self.axcalculator
                                 getTargetWorkingDaysForTimeUnit:selectedIndex
                                 andDate:date
                                 andLastDayEntry:entry];
    
    [self.projectResults removeAllObjects];
    // DORT
    NSMutableArray<AXSummaryCalculationResult *> *tempParentResults = [NSMutableArray new];
    for (Project *project in self.fetchedResultsController.fetchedObjects) {

        NSArray<Project *> *subProjects = [project.subProjects allObjects];
        
        if ([subProjects count] > 0) { // -> has subprojects
            NSMutableArray<AXSummaryCalculationResult *> *tempResults = [NSMutableArray new];
            for (Project *subProject in subProjects) {
                if(![subProject.filterActive boolValue]){
                    continue;
                }
                AXSummaryCalculationResult *calculationsResult = [self
                                                                  processEntriesForProject:subProject
                                                                  withDayTypesCalculationResult:dayTypecalculationsResult];
                os_log(OS_LOG_DEFAULT, "Processing: Project %@ with Sub[%s]: %@  time: %@", project.name, [subProject.filterActive boolValue]?"active":"inactive", subProject.name, calculationsResult.displayInfo.netWorkingTimeHours);
            
                [self.projectResults setObject:calculationsResult
                                        forKey:subProject.objectID];
                [tempResults addObject:calculationsResult];
            }
            AXSummaryCalculationResult *parentResult = [[AXSummaryCalculationResult alloc]
                                                        initWithCalculationResults:tempResults
                                                        withDayTypesCalculationResult:dayTypecalculationsResult];
            [self.projectResults setObject:parentResult
                                    forKey:project.objectID];
            [tempParentResults addObject:parentResult];
        } else { // -> NO subprojects
            AXSummaryCalculationResult *result = [self
                                                  processEntriesForProject:project
                                                  withDayTypesCalculationResult:dayTypecalculationsResult];
            [self.projectResults setObject:result
                                    forKey:project.objectID];
            [tempParentResults addObject:result];
        }
    }
    
    AXSummaryCalculationResult *overAll = [[AXSummaryCalculationResult alloc]
                                           initWithCalculationResults:tempParentResults
                                           withDayTypesCalculationResult:dayTypecalculationsResult];
    self.calculationResult = overAll;
    
    [self.activeTableViewCenter refreshData];
}

- (AXSummaryCalculationResult *)processEntriesForProject:(Project *)project
                           withDayTypesCalculationResult:(AXDayTypesCalculationResult *)dayTypesCalculationResult {
    NSMutableArray<DayEntry *> *tempArray = [NSMutableArray new];
    for (DayEntry *entry in self.fetchedDayEntries) {
        if ([entry.project isEqual:project]) {
            [tempArray addObject:entry];
        }
    }
    AXSummaryCalculationResult *calculationResult;
    calculationResult = [self.axcalculator
                         calculationResultForFetchedEntries:tempArray
                         forDayTypesCalculationResult:dayTypesCalculationResult
                         andProject:project];
    return calculationResult;
}

- (void)getDayEntries {
	switch ([self.calendarSegmentedControl selectedSegmentIndex]) {
		case SegmentTypeWeek :
			self.fetchedDayEntries = [[NSMutableArray alloc] initWithArray:[[AXDataStore sharedInstance] currentWeekEntriesForDate:self.selectedDateViewModel.currentlySelectedDate]];
			break;
		case SegmentTypeMonth :
			self.fetchedDayEntries = [[NSMutableArray alloc] initWithArray:[[AXDataStore sharedInstance] getListDayEntryForMonth:self.selectedDateViewModel.currentlySelectedDate]];
			break;
		case SegmentTypeYear :
			self.fetchedDayEntries = [[NSMutableArray alloc] initWithArray:[[AXDataStore sharedInstance] getListDayEntryForYear:self.selectedDateViewModel.currentlySelectedDate]];
			break;
		default :
			break;
	}
}

- (SKSTableView *)getNonActiveTableView {
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

#pragma mark ax calendar protocol methods

- (void)navigateForward:(BOOL)forward {
    CGFloat applicationFrameWidth = [UIScreen mainScreen].bounds.size.width;
    
	NSDateComponents *components = [self.calendar components:CALENDARUNITCOMPONENTS fromDate:self.selectedDateViewModel.currentlySelectedDate];
	int tempInt =  0;

	if (forward) {
		tempInt = 1;
	} else {
		tempInt = -1;
	}
	switch ([self.calendarSegmentedControl selectedSegmentIndex]) {
		case SegmentTypeWeek :
			[components setDay:components.day + (tempInt * 7)];
			break;
		case SegmentTypeMonth :
            [components setDay:1];
			[components setMonth:components.month + tempInt];
			break;
		case SegmentTypeYear :
			[components setYear:components.year + tempInt];
			break;
		default :
			break;
	}

	CGRect finalPositionForNewTable =  self.activeTableViewCenter.frame;
	SKSTableView *newTable = [self getNonActiveTableView];

	if (forward) {
		CGRect finalPositionForNewRightTable =  self.activeTableViewCenter.frame;
		finalPositionForNewRightTable.origin.x = finalPositionForNewRightTable.origin.x + finalPositionForNewRightTable.size.width;

		CGRect finalPositonForOldTable =  self.activeTableViewCenter.frame;
		finalPositonForOldTable.origin.x = finalPositonForOldTable.origin.x - finalPositonForOldTable.size.width;

		newTable.frame = finalPositionForNewRightTable;
		[self getConstraint:newTable].constant = applicationFrameWidth;

		self.activeTableViewCenter = newTable;
        newTable.SKSTableViewDelegate = self;

		[self setupWithDate:[self.calendar dateFromComponents:components]];

		[UIView animateWithDuration:ANIMATIONDURATION
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
			 self.activeTableViewCenter.frame = finalPositionForNewTable;
			 [self getConstraint:self.activeTableViewCenter].constant = 0;

			 [[self getNonActiveTableView] setFrame:finalPositonForOldTable];
			 [self getConstraint:[self getNonActiveTableView]].constant = -applicationFrameWidth;
		 } completion:^(BOOL finished) {
			 SKSTableView *nonactive = [self getNonActiveTableView];
			 nonactive.SKSTableViewDelegate = nil;
			 [self.activeTableViewCenter scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
		 }];
	} else {
		CGRect finalPositionForNewLeftTable =  self.activeTableViewCenter.frame;
		finalPositionForNewLeftTable.origin.x = finalPositionForNewLeftTable.origin.x - finalPositionForNewLeftTable.size.width;

		CGRect finalPositonForOldTable =  self.activeTableViewCenter.frame;
		finalPositonForOldTable.origin.x = finalPositonForOldTable.origin.x + finalPositonForOldTable.size.width;

		newTable.frame = finalPositionForNewLeftTable;
		[self getConstraint:newTable].constant = -applicationFrameWidth;

		self.activeTableViewCenter = newTable;
        newTable.SKSTableViewDelegate = self;

		[self setupWithDate:[self.calendar dateFromComponents:components]];

		[UIView animateWithDuration:ANIMATIONDURATION
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
			 self.activeTableViewCenter.frame = finalPositionForNewTable;
			 [self getConstraint:self.activeTableViewCenter].constant = 0;

			 [[self getNonActiveTableView] setFrame:finalPositonForOldTable];
			 [self getConstraint:[self getNonActiveTableView]].constant = applicationFrameWidth;
		 } completion:^(BOOL finished) {
			 SKSTableView *nonactive = [self getNonActiveTableView];
             nonactive.SKSTableViewDelegate = nil;
			 [self.activeTableViewCenter scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
		 }];
	}
}

- (void)goToToday {
	NSDate *nowDate = [NSDate date];

	[self setupWithDate:nowDate];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    self.fetchedResultsController = [[AXDataStore sharedInstance] getAllProjectsWithFilterAndPartialFilterActivated];
    self.fetchedResultsController.delegate = self;
    
    return __fetchedResultsController;
}

#pragma mark - notification methods

- (void)contextDidSave:(NSNotification *)notification {
    [self setupWithDate:self.selectedDateViewModel.currentlySelectedDate];
}

@end
