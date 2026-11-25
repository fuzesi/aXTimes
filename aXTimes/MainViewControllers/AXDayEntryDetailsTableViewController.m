//
//  AXDayEntryDetailsTableViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 22/06/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXDayEntryDetailsTableViewController.h"
#import "AXDayEntryEditViewController.h"
#import "AXDayEntrySummaryTableViewCell.h"
#import "AXCpyViewController.h"
#import "NSString+AXNSStringCategory.h"
#import "NSNumber+AXNSNumberCategory.h"
#import "NSDateFormatter+AXDateFormatters.h"
#import "AXStandardTableViewCell.h"
#import "NSDate+AXNSDateCategory.h"

static NSString *colorCellString = @"ColorRightSideTableViewCell";

@interface AXDayEntryDetailsTableViewController ()
@property (nonatomic, strong) NSTimer *clockTimer;
@property (nonatomic, strong) SettingsManager *settingsController;
@end

@implementation AXDayEntryDetailsTableViewController

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.settingsController = [SettingsManager new];
    
    UINib *entrySummaryCellNib;
    NSString *entrySummaryCellIdentifier;
    
    entrySummaryCellIdentifier = NSStringFromClass([AXDayEntrySummaryTableViewCell class]);
    entrySummaryCellNib = [UINib nibWithNibName:entrySummaryCellIdentifier
                                         bundle:nil];
    [self.tableView registerNib:entrySummaryCellNib
         forCellReuseIdentifier:entrySummaryCellIdentifier];
    entrySummaryCellIdentifier = NSStringFromClass([AXStandardTableViewCell class]);
    entrySummaryCellNib = [UINib nibWithNibName:entrySummaryCellIdentifier
                                         bundle:nil];
    [self.tableView registerNib:entrySummaryCellNib
         forCellReuseIdentifier:entrySummaryCellIdentifier];
    UINib *colorCellNib = [UINib
                           nibWithNibName:colorCellString
                           bundle:nil];
    [self.tableView registerNib:colorCellNib
         forCellReuseIdentifier:colorCellString];
    
    // https://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-variable-row-heights
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setup];
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.clockTimer != nil) {
        [self.clockTimer invalidate];
        self.clockTimer = nil;
    }
    self.navigationController.toolbarHidden = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 4;
        case 1:
            return 2;
        case 2:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    //http://stackoverflow.com/questions/12737860/assertion-failure-in-dequeuereusablecellwithidentifierforindexpath
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.detailTextLabel.textColor = GLOBALFONTCOLOR;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    switch (indexPath.section) {
        case 0: {
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLS_WORKINGTIME;
                cell.detailTextLabel.text = [self.dayEntry
                                             timeRangeDisplayValueForTargetDate:self.dayEntry.checkInTime];
            } else if (indexPath.row == 1) {
                AXStandardTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXStandardTableViewCell class]) forIndexPath:indexPath];
                commentCell.customTextLabel.text = NSLS_COMMENT;
                commentCell.customDetailTextLabel.text = self.dayEntry.comment;
                return commentCell;
            } else if (indexPath.row == 2) {
                ColorRightSideTableViewCell *colorCell = nil;
                colorCell = [tableView dequeueReusableCellWithIdentifier:colorCellString forIndexPath:indexPath];
                colorCell.customTextLabel.text = NSLS_PROJECT;
                colorCell.colorView.backgroundColor = [self.dayEntry.project color];
                colorCell.selectionStyle = UITableViewCellSelectionStyleNone;

                if (self.dayEntry.project &&
                    ![self.dayEntry.project isBasic]) {
                    colorCell.customDetailTextLabel.text = [self.dayEntry.project displayName];
                } else {
                    colorCell.customDetailTextLabel.text = NSLS_NO_PROJECT;
                }
                return colorCell;
            } else {
                AXStandardTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXStandardTableViewCell class]) forIndexPath:indexPath];
                // nur beim basic project ist der stundensatz am dayentry veränderbar
                // wenn ein anderes richtiges projekt zugewiesen ist, dann wird der
                // stundensatz vom projekt verwendet
                if ([self.dayEntry.project isBasic]) {
                    commentCell.customTextLabel.text = NSLS_HOURLYWAGE;
                } else {
                    commentCell.customTextLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                                                        NSLS_HOURLYWAGE,
                                                        [self.dayEntry.project displayNameForHourlyWage]];
                }

                commentCell.customDetailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
                                                          [self.dayEntry hourlyWageAsDecimalString],
                                                          [[SettingsManager new] currencyIso]];
                return commentCell;
            }
            break;
        }
        case 1: {
            if (indexPath.row == 0) {
                AXStandardTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXStandardTableViewCell class]) forIndexPath:indexPath];
                commentCell.customTextLabel.text = NSLS_PAUSETIME;
                commentCell.customDetailTextLabel.text = [self.dayEntry pauseTimesDisplayValue];
                return commentCell;
            } else {
                cell.textLabel.text = NSLS_HOURLYWAGE;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
                                             [self.dayEntry hourlyWageAsDecimalString],
                                             [[SettingsManager new] currencyIso]];
            }
            break;
        }
        case 2: {
            if (indexPath.row == 0) {
                AXDayEntrySummaryTableViewCell *dayEntrySummaryCell;

                dayEntrySummaryCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXDayEntrySummaryTableViewCell class]) forIndexPath:indexPath];
                [self configureDayEntrySummaryCell:dayEntrySummaryCell
                                       atIndexPath:indexPath];
                return dayEntrySummaryCell;
                
            }
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - private methods

- (void)setup {
    if (self.dayEntry &&
        self.dayEntry.checkInTime) {
        self.title = [[NSDateFormatter formatter_d_MMM_yyyy_Static:YES]
                      stringFromDate:self.dayEntry.checkInTime];
    } else {
        self.title = NSLS_DETAILS;
    }
    
    [self.tableView reloadData];
    DayEntry *latestEntryForNow;
    latestEntryForNow = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:[NSDate date]];
    
    [self setupBarButtonItems];
    
    if (self.dayEntry != nil &&
        self.dayEntry == latestEntryForNow &&
        self.dayEntry.checkInTime != nil &&
        self.dayEntry.checkOutTime == nil &&
        self.clockTimer == nil) {
        [self updateClockLabels];
        self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(updateClock)
                                                         userInfo:nil
                                                          repeats:YES];
    }
}

- (void)setupBarButtonItems {
    UIBarButtonItem *editButton;
    editButton = [[UIBarButtonItem alloc]
                  initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                  target:self
                  action:@selector(edit)];
    
    self.navigationItem.rightBarButtonItem = editButton;
    
    NSMutableArray *toolBarArray;
    UIBarButtonItem *copyButton;
    UIBarButtonItem *flexibleSpace;
    UIBarButtonItem *previousButton;
    UIBarButtonItem *nextButton;
    toolBarArray = [NSMutableArray new];
    copyButton = [[UIBarButtonItem alloc]
                  initWithImage:[UIImage imageNamed:@"copy"]
                  style:UIBarButtonItemStylePlain
                  target:self
                  action:@selector(copyEntry)];
    copyButton.tintColor = SELECTIONCOLOR;
    [toolBarArray addObject:copyButton];
    flexibleSpace = [[UIBarButtonItem alloc]
                     initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                     target:nil
                     action:nil];
    previousButton = [[UIBarButtonItem alloc]
                      initWithImage:[UIImage imageNamed:@"collapse_arrow"]
                      style:UIBarButtonItemStylePlain
                      target:self
                      action:@selector(previous)];
    previousButton.tintColor = SELECTIONCOLOR;
    nextButton = [[UIBarButtonItem alloc]
                  initWithImage:[UIImage imageNamed:@"expand_arrow"]
                  style:UIBarButtonItemStylePlain
                  target:self
                  action:@selector(next)];
    nextButton.tintColor = SELECTIONCOLOR;
    
    [toolBarArray addObjectsFromArray:@[flexibleSpace, previousButton, nextButton]];

    [self setToolbarItems:toolBarArray
                 animated:NO];
    
    if ([[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:self.dayEntry.checkInTime
                                                 honouringProjectFilter:YES] == nil) {
        previousButton.enabled = NO;
    }
    
    if ([[AXDataStore sharedInstance] nextDayEntryWithCheckinGreater:self.dayEntry.checkInTime
                                              honouringProjectFilter:YES] == nil) {
        nextButton.enabled = NO;
    }
}

- (void)configureDayEntrySummaryCell:(AXDayEntrySummaryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    if ([self.dayEntry checkOutTime] != nil) {
        cell.grossTimeLabel.text = [self.dayEntry hoursDisplayValue];
        cell.netTimeLabel.text = [self.dayEntry netHoursDisplayValue];
        cell.salaryLabel.text = [self.dayEntry incomeWithCurrencyDisplayValue];
    } else if (self.clockTimer == nil) {
        cell.grossTimeLabel.text = NULLSTRING;
        cell.netTimeLabel.text = NULLSTRING;
        cell.salaryLabel.text = NULLSTRING;
    }
}

- (void)updateClock {
    if (self.dayEntry != nil &&
        self.dayEntry.checkInTime != nil &&
        self.dayEntry.checkOutTime == nil) {
        [self updateClockLabels];
    }
}

- (void)updateClockLabels {
    AXDayEntrySummaryTableViewCell *dayEntrySummaryCell;
    dayEntrySummaryCell = (AXDayEntrySummaryTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    
    NSDate *now = [NSDate date];
    
    NSDecimalNumber *sixty = [NSDecimalNumber sixty];
    NSDecimalNumber *minutesUntilNow = [[self.dayEntry secondsWorkedUntilTargetDate:now]
                                        decimalNumberByDividingBy:sixty];
    
    NSNumber *hoursUntilNow = [minutesUntilNow
                               decimalNumberByDividingBy:sixty];
    NSDecimalNumber *netMinutesUntilNow = [self.dayEntry netMinutesFromGrossMinutes:minutesUntilNow];
    NSNumber *netHoursUntilNow = [netMinutesUntilNow
                                  decimalNumberByDividingBy:sixty];
    NSDecimalNumber *salary = [self.dayEntry
                               incomeWithMinutesWorked:minutesUntilNow];
    NSString *currencyString = [[SettingsManager new] currencyIso];
    NSString *currencyUntilNow = [[salary stringValueNumberFormatted]
                                  appendStringWithWhiteSpace:currencyString];

    
    dayEntrySummaryCell.grossTimeLabel.text = [hoursUntilNow displayTime];
    dayEntrySummaryCell.netTimeLabel.text = [netHoursUntilNow displayTime];
    dayEntrySummaryCell.salaryLabel.text = currencyUntilNow;
}

#pragma mark - UIBarButtonItem action methods

- (void)edit {
    AXDayEntryEditViewController *aXDayEntryEditViewController = [AXDayEntryEditViewController new];
    aXDayEntryEditViewController.dayEntry = self.dayEntry;
    aXDayEntryEditViewController.newDayEntry = NO;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:aXDayEntryEditViewController];
    navigationController.extendedLayoutIncludesOpaqueBars = YES;
    
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

- (void)copyEntry {
    if (self.dayEntry != nil &&
        self.dayEntry.checkOutTime == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS_WARNINGPOPUP
                                                        message:NSLS_CANTCOPY_INCOMPLETE
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLS_OKPOPUP, nil];
        [alert show];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];

    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"CopyNavigationController"];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    AXCpyViewController *viewController = (AXCpyViewController *)navigationController.viewControllers[0];
    [viewController setCurrentDayEntry:self.dayEntry];
    
    UIViewController *presenter;
    presenter = [UIApplication topViewControllerWithBase:[[[UIApplication sharedApplication] keyWindow] rootViewController]];
    [presenter presentViewController:navigationController
                            animated:YES
                          completion:^{
                              [viewController.datePicker setDate:[self.dayEntry.checkInTime addDays:+1]];
    }];
}

- (void)reverseCheckout {
    // sanity check
    if (self.dayEntry.checkInTime != nil &&
        self.dayEntry.checkOutTime != nil) {
        [self.dayEntry setCheckOutTime:nil];
        [self.tableView reloadData];
    }
}

- (void)previous {
    self.dayEntry = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:self.dayEntry.checkInTime
                                                             honouringProjectFilter:YES];
    [self setup];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:NOTIFICATION_JUMP_TO_DATE
     object:self.dayEntry.checkInTime];
}

- (void)next {
    self.dayEntry = [[AXDataStore sharedInstance] nextDayEntryWithCheckinGreater:self.dayEntry.checkInTime
                                                          honouringProjectFilter:YES];
    [self setup];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:NOTIFICATION_JUMP_TO_DATE
     object:self.dayEntry.checkInTime];
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    UIPreviewAction *copyAction = [UIPreviewAction
                                   actionWithTitle:NSLS_COPYENTRY
                                   style:UIPreviewActionStyleDefault
                                   handler:^(UIPreviewAction * _Nonnull action,
                                             UIViewController * _Nonnull previewViewController) {
                                       if ([previewViewController isKindOfClass:[AXDayEntryDetailsTableViewController class]]) {
                                           AXDayEntryDetailsTableViewController *controller = (AXDayEntryDetailsTableViewController *)previewViewController;
                                           [controller copyEntry];
                                       }
                                   }];
    NSArray *actions = @[copyAction];
    // and return them
    return actions;
}

@end
