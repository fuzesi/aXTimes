//
//  AXDayEntryEditViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 02/06/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXDayEntryEditViewController.h"
#import "AXPauseTableViewCell.h"
#import "AXStandardTableViewCell.h"
#import "AXDatePickerTableViewCell.h"
#import "NSDate+AXNSDateCategory.h"
#import "NSDateFormatter+AXDateFormatters.h"
#import "UIImage+AXUIImageCategory.h"
#import "AXAttendanceRecorder.h"
#import "AXHourlyWageViewController.h"
#import "AXUtility.h"
#import "NSString+AXNSStringCategory.h"
#import "RESideMenu.h"
#import "NSCalendar+AXNSCalendarCategory.h"
#import "NSDate+AXNSDateCategory.h"
#import "AXPauseViewController.h"

static NSString *DeletionCellIdentifier = @"DeletionCell";

@interface AXDayEntryEditViewController ()
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *datePickerIndexPath;
@property (strong, nonatomic) SettingsManager *settingsController;
@property (strong, nonatomic) NSManagedObjectContext *childContext;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;
@property (strong, nonatomic) NSString *tempComment;
@property BOOL tryToSetDefaultPause;

@end

@implementation AXDayEntryEditViewController

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.newDayEntry) {
        self.title = NSLS_ADDENTRY;
    } else {
        self.title = NSLS_EDIT_ENTRY;
    }
    
    self.tempComment = nil;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStyleGrouped];
    
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([AXDatePickerTableViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NSStringFromClass([AXDatePickerTableViewCell class])];
    
    UINib *commentCellNib = [UINib nibWithNibName:NSStringFromClass([AXStandardTableViewCell class]) bundle:nil];
    [self.tableView registerNib:commentCellNib forCellReuseIdentifier:NSStringFromClass([AXStandardTableViewCell class])];
    
    UINib *pauseCellNib = [UINib nibWithNibName:NSStringFromClass([AXPauseTableViewCell class]) bundle:nil];
    [self.tableView registerNib:pauseCellNib forCellReuseIdentifier:NSStringFromClass([AXPauseTableViewCell class])];
    
    UINib *deletionCellNib = [UINib nibWithNibName:DeletionCellIdentifier bundle:nil];
    [self.tableView registerNib:deletionCellNib forCellReuseIdentifier:DeletionCellIdentifier];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    rightButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    self.settingsController = [SettingsManager new];

    self.childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    if (!self.newDayEntry) {
        NSManagedObject *returnObject = [[AXDataStore sharedInstance]
                                         fetchObjectWithManagedObjectIDWithChildContext:self.dayEntry.objectID
                                         andContext:self.childContext];
        DayEntry *objectWithChildContext = (DayEntry *)returnObject;
        self.dayEntry = objectWithChildContext;
    } else {
        [[AXDataStore sharedInstance] turnIntoChildContext:self.childContext];
        DayEntry *newDayEntry = [NSEntityDescription
                                 insertNewObjectForEntityForName:NSStringFromClass([DayEntry class])
                                 inManagedObjectContext:self.childContext];
        
        Project *settingsProject = [[AXDataStore sharedInstance] defaultCheckInProjectWithCheckInDate:self.date];
        
        if (settingsProject) {
            NSManagedObject *returnObject = [[AXDataStore sharedInstance]
                                             fetchObjectWithManagedObjectIDWithChildContext:settingsProject.objectID
                                             andContext:self.childContext];
            if ([returnObject isKindOfClass:[Project class]]) {
                Project *project = (Project *)returnObject;
                newDayEntry.project = project;
            }
        }
        
        NSString *defaultComment = newDayEntry.project.actualDefaultComment;
        if (!defaultComment) {
            defaultComment = @"";
        }
        
        newDayEntry.comment = defaultComment;
        newDayEntry.hourlyWage = [[SettingsManager new] hourlyWage];
        
        self.dayEntry = newDayEntry;
    }
    
    [self.dayEntry normalize];
    
    if (!self.newDayEntry) {
        self.date = self.dayEntry.checkInTime;
    }
    
    if (self.newDayEntry) {
        self.tryToSetDefaultPause = YES;
    } else if (self.dayEntry.checkInTime != nil &&
               self.dayEntry.checkOutTime == nil) {
        self.tryToSetDefaultPause = YES;
    }
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [self tryToEnableDoneButton];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.newDayEntry) {
        return 3;
    } else {
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0: {        // project + check-in + check-out
            numberOfRows = 3;
            if ([self datePickerIsShown]) {
                numberOfRows++;
            }
        }
            break;
        case 1: // number of pauses + addpause
            numberOfRows = [[self.dayEntry pauses] count] + 1;
            break;
        case 2: // comment + hourly wage
            numberOfRows = 2;
            break;
        case 3: // in case we are in editing mode of an existing dayentry we need a deletion row
            numberOfRows = 1;
            break;
        default:
            break;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *normalCell = @"Cell";
    NSInteger numberOfRowsPauseSection = [tableView numberOfRowsInSection:1];

    UITableViewCell *cell = nil;
    DeletionCell *deletionCell = nil;

    if ([self datePickerIsShown] &&
        (self.datePickerIndexPath.row == indexPath.row) &&
        (self.datePickerIndexPath.section == indexPath.section)){
        
        return [self createPickerCell:indexPath];
    }
    
    NSUInteger checkOut = 2;
    if ([self datePickerIsShown] &&
        self.datePickerIndexPath.row == 2) {
        checkOut = 3;
    }
    
    if (indexPath.section == 0 &&
        indexPath.row == checkOut) {
        deletionCell = [tableView
                        dequeueReusableCellWithIdentifier:DeletionCellIdentifier
                        forIndexPath:indexPath];
        deletionCell.userInteractionEnabled = YES;
        deletionCell.customTextLabel.enabled = deletionCell.userInteractionEnabled;
        deletionCell.customDetailTextLabel.enabled = deletionCell.userInteractionEnabled;
        deletionCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        deletionCell.customDetailTextLabel.textColor = GLOBALFONTCOLOR;
        deletionCell.deletionButton.hidden = YES;
    } else if (indexPath.section == 0 ||
        (indexPath.section == 1 && !(indexPath.row != numberOfRowsPauseSection - 1)) ||
        (indexPath.section == 2 && (indexPath.row == 0 || indexPath.row == 1)) ||
        (indexPath.section == 3 && indexPath.row == 0)) {
        cell = [tableView dequeueReusableCellWithIdentifier:normalCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:normalCell];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = YES;
        cell.textLabel.enabled = YES;
        cell.detailTextLabel.enabled = YES;
        cell.detailTextLabel.text = @" ";
        cell.textLabel.textColor = GLOBALFONTCOLOR;
        cell.detailTextLabel.textColor = GLOBALFONTCOLOR;
        cell.detailTextLabel.numberOfLines = 1;
    }
    
    
    // project cell
    if (indexPath.section == 0 &&
        indexPath.row == 0) {
        cell.textLabel.text = NSLS_PROJECT;
        if (self.dayEntry.project) {
            cell.detailTextLabel.text = [self.dayEntry.project displayName];
        } else {
            cell.detailTextLabel.text = NSLS_NO_PROJECT;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0 &&
        indexPath.row != 0) {
        if (indexPath.row == 1) {
            cell.textLabel.text = NSLS_CHECKIN;
            if ([self.dayEntry checkInTime] != nil) {
                cell.detailTextLabel.text = [self.dayEntry
                                             checkInTimeDisplayValueForTargetDate:self.date];
            }
        } else if (indexPath.row == checkOut) {
            deletionCell.customTextLabel.text = NSLS_CHECKOUT;

            if ([self.dayEntry checkOutTime] != nil) {
                deletionCell.customDetailTextLabel.text = [self.dayEntry
                                             checkOutTimeDisplayValueForTargetDate:self.date];
                
                if (![self.dayEntry.checkOutTimeZone
                      isEqualToString:self.dayEntry.checkInTimeZone]) {
                    deletionCell.accessoryView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"globus_fine.png"] imageWithBurnTint:TIMEZONECOLOR]];
                }
            } else {
                deletionCell.customDetailTextLabel.text = @"";
                deletionCell.accessoryView = nil;
            }
            
            BOOL disabled = NO;
            if (self.dayEntry.checkInTime == nil) {
                disabled = YES;
            }
            
            Pause *pause = [self.dayEntry lastSortedPause];
            if (pause != nil && pause.startTime != nil && pause.endTime == nil) {
                disabled = YES;
            }
            
            if (disabled == YES) {
                deletionCell.userInteractionEnabled = NO;
                deletionCell.customTextLabel.enabled = deletionCell.userInteractionEnabled;
                deletionCell.customDetailTextLabel.enabled = deletionCell.userInteractionEnabled;
                deletionCell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                DayEntry *latestEntryForNow;
                latestEntryForNow = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:[NSDate date]];
                if ([self.dayEntry.objectID isEqual:latestEntryForNow.objectID] &&
                    self.dayEntry.checkOutTime != nil) {
                    deletionCell.deletionButton.hidden = NO;
                    [deletionCell.deletionButton addTarget:self
                                                    action:@selector(deleteCheckOut:)
                                          forControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
        
        if ([self datePickerIsShown] &&
            (self.datePickerIndexPath.row - 1 == indexPath.row) &&
            (self.datePickerIndexPath.section == indexPath.section)) {
            cell.detailTextLabel.textColor = SELECTIONCOLOR;
            deletionCell.customDetailTextLabel.textColor = SELECTIONCOLOR;
        }
        
        if (deletionCell) {
            return deletionCell;
        }
    }
    
    //pause cell
    if (indexPath.section == 1) {
        if (indexPath.row != numberOfRowsPauseSection - 1) {
            AXPauseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXPauseTableViewCell class]) forIndexPath:indexPath];
            cell.timeRangeLabel.text = @"";
            cell.totalTimeLabel.text = @"";
            cell.customTextLabel.text = NSLS_PAUSE;
            
            Pause *pause = [self.dayEntry sortedPauses][indexPath.row];
            NSString *totalPauseTimeString = @"";
            if (pause.endTime != nil) {
                totalPauseTimeString = [pause hoursPausedDisplayValue];
            }
            cell.timeRangeLabel.text = [pause timeRangeDisplayValueForTargetDate:self.date];
            cell.totalTimeLabel.text = totalPauseTimeString;
            return cell;
        } else {
            // add pause cell
            cell.textLabel.text = NSLS_ADDPAUSE;
            if (![self allowedToCreateNewPause]) {
                // 1. No checkin time
                // 2. Open pause
                // 3. Last Pause it too close to checkout
                cell.userInteractionEnabled = NO;
                cell.textLabel.enabled = NO;
            } else {
                cell.userInteractionEnabled = YES;
                cell.textLabel.enabled = YES;
            }
        }
    }
    
    // comment cell
    if (indexPath.section == 2) {
        AXStandardTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXStandardTableViewCell class]) forIndexPath:indexPath];
        if (indexPath.row == 0) {
            commentCell.selectionStyle = UITableViewCellSelectionStyleDefault;
            commentCell.customTextLabel.text = NSLS_COMMENT;
            commentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            if (!self.tempComment) {
                commentCell.customDetailTextLabel.text = self.dayEntry.comment;
            } else {
                commentCell.customDetailTextLabel.text = self.tempComment;
            }

        } else {     // hourly wage cell
            // nur beim basic project ist der stundensatz am dayentry veränderbar
            // wenn ein anderes richtiges projekt zugewiesen ist, dann wird der
            // stundensatz vom projekt verwendet
            if ([self.dayEntry.project isBasic]) {
                commentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                commentCell.selectionStyle = UITableViewCellSelectionStyleDefault;
                commentCell.userInteractionEnabled = YES;
                commentCell.customTextLabel.text = NSLS_HOURLYWAGE;
            } else {
                commentCell.accessoryType = UITableViewCellAccessoryNone;
                commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
                commentCell.userInteractionEnabled = NO;
                commentCell.customTextLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                                       NSLS_HOURLYWAGE,
                                       [self.dayEntry.project displayNameForHourlyWage]];
            }

            // http://stackoverflow.com/a/18552074
            commentCell.customTextLabel.enabled = commentCell.isUserInteractionEnabled;
            commentCell.customDetailTextLabel.enabled = commentCell.isUserInteractionEnabled;

            commentCell.customDetailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
                                         [self.dayEntry hourlyWageAsDecimalString],
                                         [[SettingsManager new] currencyIso]];
        }


        return commentCell;
    }

    if (indexPath.section == 3 &&
        indexPath.row == 0) { //delete dayEntry
        cell.textLabel.text = NSLS_DELETEENTRY;
        cell.textLabel.textColor = C_SYSTEM_RED;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 &&
        indexPath.row == 0) {
        AXProjectCheckinSettingsViewController *aXProjectCheckinSettingsViewController;
        aXProjectCheckinSettingsViewController = [AXProjectCheckinSettingsViewController new];
        aXProjectCheckinSettingsViewController.projectSelectionDelegate = self;
        aXProjectCheckinSettingsViewController.controllerTitle = NSLS_SETTINGS_DEFAULTPROJECT;
        aXProjectCheckinSettingsViewController.childContext = self.childContext;
        [self.navigationController pushViewController:aXProjectCheckinSettingsViewController
                                             animated:YES];
        return;
    }
    
    if (indexPath.section == 0) {
        if ([self datePickerIsShown] &&
            (self.datePickerIndexPath.row != indexPath.row)) {
            NSIndexPath *newPickerIndexPath;
            if (self.datePickerIndexPath.row == 3 &&
                indexPath.row == 1) {
                newPickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
            } else if (self.datePickerIndexPath.row == 2 &&
                       indexPath.row == 3) {
                newPickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            }
            
            if (!newPickerIndexPath) {
                [tableView beginUpdates];
                [self reloadRowsSurroundingDatePicker];
                [self hideExistingPicker];
                [tableView endUpdates];
                return;
            } else {
                [tableView beginUpdates];
                [self reloadRowsSurroundingDatePicker];
                [self hideExistingPicker];
                [self showNewPickerAtIndex:newPickerIndexPath];
                [tableView endUpdates];
                
                AXDatePickerTableViewCell *aXDatePickerTableViewCell = (AXDatePickerTableViewCell *)[self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
                UIDatePicker *datePicker = aXDatePickerTableViewCell.datePicker;
                [self updateDueToDateChange:datePicker];
            }
            return;
        }
        
        self.lastSelectedIndexPath = indexPath;
        
        if (indexPath.row == 1 ||
            indexPath.row == 2) {
            NSIndexPath *newPickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1
                                                                 inSection:indexPath.section];
            [tableView beginUpdates];
            [self showNewPickerAtIndex:newPickerIndexPath];
            [tableView endUpdates];
            
            AXDatePickerTableViewCell *aXDatePickerTableViewCell = (AXDatePickerTableViewCell *)[tableView cellForRowAtIndexPath:self.datePickerIndexPath];
            UIDatePicker *datePicker = aXDatePickerTableViewCell.datePicker;
            [self updateDueToDateChange:datePicker];
            return;
        }
    }
    
    if (indexPath.section == 2 &&
        indexPath.row == 1) {
        AXHourlyWageViewController *aXHourlyWageViewController = [AXHourlyWageViewController new];
        [aXHourlyWageViewController setCurrentDayEntry:self.dayEntry];
        [self.navigationController pushViewController:aXHourlyWageViewController
                                             animated:YES];
    } else if (indexPath.section == 2 &&
               indexPath.row == 0) {
        [self comment];
    } else if (indexPath.section == 1) {
        NSInteger numberOfRowsInSection = [tableView numberOfRowsInSection:indexPath.section];
        AXPauseViewController *aXPauseViewController = [AXPauseViewController new];
        aXPauseViewController.currentDayEntry = self.dayEntry;

        if (indexPath.row != (numberOfRowsInSection - 1)) { // existing pause
            aXPauseViewController.newPause = NO;
            
            Pause *pause = [self.dayEntry sortedPauses][indexPath.row];
            
            aXPauseViewController.currentPause = pause;
            [self.navigationController pushViewController:aXPauseViewController
                                                 animated:YES];
        } else { // add new pause
            aXPauseViewController.newPause = YES;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:aXPauseViewController];
            [self presentViewController:navigationController
                               animated:YES
                             completion:nil];
        }
    } else if (indexPath.section == 3 &&
               indexPath.row == 0) {
        [self askDelete];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = UITableViewAutomaticDimension;
    if ([self datePickerIsShown] &&
        (self.datePickerIndexPath.row == indexPath.row) &&
        (self.datePickerIndexPath.section == indexPath.section)){
        rowHeight = 162;
    }
    return rowHeight;
}

#pragma mark - datepicker methods

- (void)dateChanged:(id)sender {
    UIDatePicker *datePicker;
    
    if ([sender isKindOfClass:[UIDatePicker class]]) {
        datePicker = (UIDatePicker *)sender;
    }
    
    if ([self datePickerIsShown] &&
        datePicker) {
        [self updateDueToDateChange:datePicker];
    }
}

- (void)showNewPickerAtIndex:(NSIndexPath *)indexPath {
    self.datePickerIndexPath = indexPath;
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
}

- (void)hideExistingPicker {
    if ([self datePickerIsShown]) {
        [self.tableView deleteRowsAtIndexPaths:@[self.datePickerIndexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }
}

- (void)updateDueToDateChange:(UIDatePicker *)datePicker {
    if ([self datePickerIsShown] &&
        datePicker) {
        [self updateDayEntryWith:datePicker];
        
        [self.tableView beginUpdates];
        [self reloadPauseSection]; // wegen dem add pause button
        [self reloadRowsSurroundingDatePicker];
        [self.tableView endUpdates];
        
        [self updateUI];
    }
}

- (void)reloadPauseSection {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                  withRowAnimation:UITableViewRowAnimationNone];
}


- (void)reloadRowsSurroundingDatePicker {
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1
                                                                inSection:self.datePickerIndexPath.section]]
                          withRowAnimation:UITableViewRowAnimationNone];
    if (self.datePickerIndexPath.row == 2) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row + 1
                                                                    inSection:self.datePickerIndexPath.section]]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
}



- (void)updateDayEntryWith:(UIDatePicker *)datePicker {
    // (([date compare:beginDate] != NSOrderedAscending) && ([date compare:endDate] != NSOrderedDescending))
    switch (self.datePickerIndexPath.row) {
        case 2 :
            if(self.newDayEntry){
                BOOL validStart = true;
                NSArray<DayEntry *> *entries = [[AXDataStore sharedInstance] getDayEntriesForDate:self.date];
                NSDate *nextDate = nil;
                for(DayEntry *entry in entries){
                    if((([datePicker.date compare:entry.checkInTime] != NSOrderedAscending) && ([datePicker.date compare:entry.checkOutTime] != NSOrderedDescending))){
                        validStart = false;
                        nextDate = entry.checkOutTime;
                        break;
                    }
                }
                if(!validStart){
                    NSDate *tempDate = nil;
                    if (self.dayEntry.checkInTime != nil) {
                        // timezone formatted
                        datePicker.timeZone = [[NSTimeZone alloc] initWithName:self.dayEntry.checkInTimeZone];
                        tempDate = self.dayEntry.checkInTime;
                    } else {
                        tempDate = self.date;
                    }
                    tempDate = nextDate;

                    [datePicker setDate:tempDate];
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ungültiger Check-In"
                                                                                   message:@"Der Check-In kann nicht innerhalb eines bestehenden Eintrags erfolgen."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                    [self.dayEntry configureWithStart:datePicker.date
                                          andTimeZone:[[NSTimeZone systemTimeZone] name]];
                }else{
                    [self.dayEntry configureWithStart:datePicker.date
                                          andTimeZone:[[NSTimeZone systemTimeZone] name]];
                }
            }else{
                [self.dayEntry configureWithStart:datePicker.date
                                      andTimeZone:[[NSTimeZone systemTimeZone] name]];
            }
            
            
            break;
        case 3 :
            if(self.newDayEntry){
                [self.dayEntry configureWithEnd:datePicker.date
                                    andTimeZone:[[NSTimeZone systemTimeZone] name]];
            }else{
                [self.dayEntry configureWithEnd:datePicker.date
                                    andTimeZone:[[NSTimeZone systemTimeZone] name]];
            }
            
            break;
        default :
            break;
    }
}

- (BOOL)datePickerIsShown {
    return self.datePickerIndexPath != nil;
}


/* #################################### */
- (AXDatePickerTableViewCell *)createPickerCell:(NSIndexPath *)indexPath {
    AXDatePickerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXDatePickerTableViewCell class])];
    
    UIDatePicker *datePicker = cell.datePicker;
    [datePicker addTarget:self
                   action:@selector(dateChanged:)
         forControlEvents:UIControlEventValueChanged];
    
    if (indexPath.row == 2 ||
        indexPath.row == 3) {
        datePicker.maximumDate = nil;
        datePicker.minimumDate = nil;
        // timezone reset
        datePicker.timeZone = [[NSTimeZone alloc] initWithName:[[NSTimeZone systemTimeZone] name]];
        
        switch (indexPath.row) {
            case 2 : {
                
                if(self.newDayEntry){
                    datePicker.datePickerMode = UIDatePickerModeTime;
                    NSDate *tempDate = nil;
                    if (self.dayEntry.checkInTime != nil) {
                        // timezone formatted
                        datePicker.timeZone = [[NSTimeZone alloc] initWithName:self.dayEntry.checkInTimeZone];
                        tempDate = self.dayEntry.checkInTime;
                    } else {
                        tempDate = self.date;
                    }
                    [datePicker setDate:tempDate];
                    
                    
                }else{
                    datePicker.datePickerMode = UIDatePickerModeTime;
                    
                    NSDate *tempDate = nil;
                    if (self.dayEntry.checkInTime != nil) {
                        // timezone formatted
                        datePicker.timeZone = [[NSTimeZone alloc] initWithName:self.dayEntry.checkInTimeZone];
                        tempDate = self.dayEntry.checkInTime;
                    } else {
                        tempDate = self.date;
                    }
                    [datePicker setDate:tempDate];
                    
                    NSDate *nextDate = [tempDate addDays:1];
                    nextDate = [nextDate truncateHours];
                    
                    Pause *pause =  [self.dayEntry firstSortedPause];
                    if (pause != nil) {
                        datePicker.maximumDate = pause.startTime;
                    } else if (self.dayEntry.checkOutTime != nil) {
                        datePicker.maximumDate = [self.dayEntry.checkOutTime addMinutes:-1];
                    } else {
                        DayEntry *nextEntry = [[AXDataStore sharedInstance] nextDayEntryWithCheckinEqualGreater:nextDate];
                        if (nextEntry) {
                            datePicker.maximumDate = nextEntry.checkInTime;
                        } else {
                            datePicker.maximumDate = [[[NSDate date] truncateSeconds] addMinutes:-1];
                        }
                    }
                    
                    DayEntry *dayEntry;
                    if (self.dayEntry.checkInTime) {
                        dayEntry = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:self.dayEntry.checkInTime];
                    } else {
                        dayEntry = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:nextDate];
                    }
                    
                    if (dayEntry != nil &&
                        dayEntry.checkOutTime != nil &&
                        [dayEntry.checkOutTime isSameDay:tempDate]) {
                        datePicker.minimumDate = dayEntry.checkOutTime;
                    } else if (dayEntry != nil &&
                               dayEntry.checkInTime != nil &&
                               [dayEntry.checkInTime isSameDay:tempDate]) {
                        datePicker.minimumDate = dayEntry.checkInTime; // sollte eigentlich nicht passieren
                    }
                }
                
                
                break;
            }
            case 3 : {
                datePicker.datePickerMode = UIDatePickerModeDateAndTime;
                Pause *pause = [self.dayEntry lastSortedPause];
                
                if (pause != nil) {
                    datePicker.minimumDate = pause.endTime;
                    [datePicker setDate:pause.endTime];
                } else {
                    NSDate *minDate = [self.dayEntry.checkInTime addMinutes:1];
                    datePicker.minimumDate = minDate;
                    [datePicker setDate:minDate];
                }
                
                // if there is already a value set it
                if (self.dayEntry.checkOutTime != nil) {
                    // timezone formatted
                    datePicker.timeZone = [[NSTimeZone alloc] initWithName:self.dayEntry.checkOutTimeZone];
                    [datePicker setDate:self.dayEntry.checkOutTime];
                }
                
                DayEntry *nextEntry = [[AXDataStore sharedInstance] nextDayEntryWithCheckinEqualGreater:datePicker.date];
                
                if (nextEntry != nil &&
                    ![nextEntry.objectID isEqual:self.dayEntry] &&
                    nextEntry.checkInTime != nil) {
                    datePicker.maximumDate = nextEntry.checkInTime;
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
    
    return cell;
}

#pragma mark - private methods

- (void)deleteCheckOut:(id)sender {
    [self.tableView beginUpdates];
    [self hideExistingPicker];
    
    self.dayEntry.checkOutTime = nil;
    self.dayEntry.checkOutTimeZone = nil;

    UIButton *button;
    
    if ([sender isKindOfClass:[UIButton class]]) {
        button = (UIButton *)sender;
        
        CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        if (indexPath) {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    
    [self.tableView endUpdates];
}

- (void)done {
    [AXUtility handleCommentChange:self.dayEntry
                           andText:self.tempComment];
    
    NSError *error = nil;
    if (self.dayEntry.project == nil) {
        // failsafe -> should actually be already set in viewDidLoad
        Project *project = [[AXDataStore sharedInstance] getBasicProject];
        NSManagedObject *returnObject = [[AXDataStore sharedInstance]
                                         fetchObjectWithManagedObjectIDWithChildContext:[project objectID]
                                         andContext:self.childContext];
        if ([returnObject isKindOfClass:[Project class]]) {
            Project *globalProject = (Project *)returnObject;
            self.dayEntry.project = globalProject;
        }
    }
    
    if (self.tryToSetDefaultPause) {
        [AXAttendanceRecorder applyDefaultPauseSettingsToEntry:self.dayEntry];
    }
    
    if (self.dayEntry.checkInTime) {
        [self.dayEntry configureWithStart:self.dayEntry.checkInTime
                              andTimeZone:[[NSTimeZone systemTimeZone] name]];
    }
    if (self.dayEntry.checkOutTime) {
        [self.dayEntry configureWithEnd:self.dayEntry.checkOutTime
                            andTimeZone:[[NSTimeZone systemTimeZone] name]];
    }

    if (![[self.dayEntry managedObjectContext] save:&error]) {
    }
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)deleteEntry {
    NSError *error = nil;
    [[self.dayEntry managedObjectContext] deleteObject:self.dayEntry];
    if (![[self.dayEntry managedObjectContext] save:&error]) {
        
    } else {
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
    }

    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)askDelete {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:NSLS_QUESTION_ALERTVIEW_TITLE
                                message:NSLS_DELETEENTRYQ
                                preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *delete = [UIAlertAction
                             actionWithTitle:NSLS_DELETEENTRY
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction *action) {
                                 [self deleteEntry];
                             }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:NSLS_CANCEL
                             style:UIAlertActionStyleCancel
                             handler:nil];
    
    [alert addAction:delete];
    [alert addAction:cancel];
    
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tryToEnableDoneButton {
    self.navigationItem.rightBarButtonItem.enabled = [self allowedToSave];
}

- (void)updateUI {
    [self tryToEnableDoneButton];
}

- (BOOL)allowedToSave {
    DayEntry *dayEntry = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:[NSDate date]];

    if (dayEntry) {
        if ([dayEntry.objectID isEqual:self.dayEntry.objectID] &&
            self.dayEntry.checkInTime != nil &&
            self.dayEntry.checkOutTime == nil) {
            return YES;
        } else if (self.dayEntry.checkInTime != nil &&
                   [dayEntry.checkOutTime compare:self.dayEntry.checkInTime] != NSOrderedDescending) {
            return YES;
        }
    } else {
        // there are no dayentries yet
        if (self.dayEntry.checkInTime != nil) {
            return YES;
        }
    }
    
    if (self.dayEntry.checkInTime &&
        self.dayEntry.checkOutTime) {
        return YES;
    }
    return NO;
}

- (BOOL)allowedToCreateNewPause {
    if (self.dayEntry.checkInTime == nil) {
        return NO;
    }
    
    Pause *pause = [self.dayEntry lastSortedPause];

    if (pause != nil &&
        pause.startTime != nil &&
        pause.endTime == nil) {
        return NO;
    }

    if (pause != nil &&
        [pause isComplete] &&
        self.dayEntry.checkOutTime != nil &&
        (([[pause.endTime truncateSeconds] compare:[self.dayEntry.checkOutTime truncateSeconds]] == NSOrderedSame) || ([self.dayEntry.checkOutTime timeIntervalSinceDate:pause.endTime] < 60))) {
        return NO;
    }
    
    NSDate *nowDate = [NSDate date];
    if (pause != nil &&
        [pause isComplete] &&
        self.dayEntry.checkOutTime == nil &&
        (([[pause.endTime truncateSeconds] compare:[nowDate truncateSeconds]] == NSOrderedSame) || ([nowDate timeIntervalSinceDate:pause.endTime] < 60))) {
        return NO;
    }
    
    return YES;
}

- (void)comment {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    AXNoteViewController *noteViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AXNoteViewController class])];
    if (!self.tempComment) {
        noteViewController.textToDisplay = self.dayEntry.comment;
    } else {
        noteViewController.textToDisplay = self.tempComment;
    }
    noteViewController.delegate = self;
    
    [self.navigationController pushViewController:noteViewController
                                    animated:YES];
}

#pragma mark - AXProjectCheckinSettingsViewControllerProtocol

- (void)projectSelectionChanged:(Project *)project {
    self.dayEntry.project = project;
}

- (Project *)relevantProject {
    return self.dayEntry.project;
}

- (NSDate *)projectStart {
    if (self.dayEntry.checkInTime) {
        return self.dayEntry.checkInTime;
    } else {
        NSDate *tempDate;
        tempDate = self.date;
        tempDate = [tempDate truncateHours];
        return tempDate;
    }
}

- (NSDate *)projectEnd {
    if (self.dayEntry.checkOutTime) {
        return self.dayEntry.checkOutTime;
    } else {
        NSDate *tempDate;
        tempDate = self.date;
        tempDate = [tempDate addDays:1];
        tempDate = [tempDate truncateHours];
        return tempDate;
    }
}

#pragma mark - AXNoteViewControllerProtocol

- (void)doneChangingComment:(NSString *)comment {
    self.tempComment = comment;   
}

@end
