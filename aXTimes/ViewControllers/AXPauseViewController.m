//
//  AXPauseTableViewController.m
//  aXTimes
//
//  Created by fuesec on 5/19/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXPauseViewController.h"
#import "AXUtility.h"
#import "NSDate+AXNSDateCategory.h"
#import "AXDatePickerTableViewCell.h"
#import "NSCalendar+AXNSCalendarCategory.h"
#import "NSDate+AXNSDateCategory.h"

@interface AXPauseViewController ()

@property (nonatomic, strong) AXUtility *utitlity;
@property (strong, nonatomic) NSIndexPath *datePickerIndexPath;

@end

@implementation AXPauseViewController


#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

    if (self.newPause) {
        self.title = NSLS_ADDPAUSE;
        
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = leftButton;
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        rightButton.enabled = NO;
        self.navigationItem.rightBarButtonItem = rightButton;
    } else {
        self.title = NSLS_EDIT_PAUSE;
    }

	if (self.currentPause == nil) {
        Pause *newPause = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Pause class])
                                                        inManagedObjectContext:self.currentDayEntry.managedObjectContext];
        self.currentPause = newPause;
    }

	self.utitlity = [AXUtility new];
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([AXDatePickerTableViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NSStringFromClass([AXDatePickerTableViewCell class])];
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
    if (!self.newPause) {
        return 2;
    }
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 1; // deletion row
    }
    
    NSInteger numberOfRows = 2;
    if ([self datePickerIsShown]) {
        numberOfRows++;
    }
    return numberOfRows;
}

- (UITableViewCell *)createPickerCell:(NSIndexPath *)indexPath {
    AXDatePickerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXDatePickerTableViewCell class])];
    
    UIDatePicker *datePicker = cell.datePicker;
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    datePicker.maximumDate = nil;
    datePicker.minimumDate = nil;
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;

    
    DebugLog(@"indexPath row: %ld", (long)indexPath.row);
    
    
    Boolean checkMaxDate = true;

    switch (indexPath.row) {
        case 1 : {
            NSInteger lastObjectIndex = [self.currentDayEntry.pauses count] - 1;
            
            Pause *pause = nil;
            
            NSDate *date = self.currentDayEntry.checkInTime;
            
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.day = [[NSCalendar currentCalendar] ordinalityOfUnit:(NSCalendarUnitDay) inUnit:(NSCalendarUnitEra) forDate:date];
            NSDate *dayBegin = [[NSCalendar currentCalendar] dateFromComponents:components];
            
            if (self.currentPause != nil &&
                self.currentPause.startTime != nil) {
                // edit pause
                int currentIndex = 0;
                for (int i = 0; i <= lastObjectIndex; i++) {
                    Pause *pause =  [self.currentDayEntry sortedPauses][i];
                    if ([self.currentPause.startTime compare:pause.startTime] == NSOrderedSame) {
                        currentIndex = i;
                    }
                }
                if (currentIndex - 1 >= 0) {
                    // get pause before if possible
                    pause =  [self.currentDayEntry sortedPauses][currentIndex - 1];
                }
            } else {
                // add pause
                if (lastObjectIndex >= 0) {
                    // get pause before if possible
                    pause =  [self.currentDayEntry sortedPauses][lastObjectIndex];
                }
            }
            
            if (pause != nil) {
                datePicker.minimumDate = pause.endTime;
                [datePicker setDate:pause.endTime];
            } else {
                datePicker.minimumDate = self.currentDayEntry.checkInTime;
                //datePicker.minimumDate = nil;
                
                

                //datePicker.minimumDate = dayBegin;
                
                [datePicker setDate:self.currentDayEntry.checkInTime];
            }
            
            if (self.currentPause.endTime != nil) {
                datePicker.maximumDate = [self.currentPause.endTime addMinutes:-1];
            } else {
                Pause *pause = nil;

                if (self.currentPause != nil &&
                    self.currentPause.startTime != nil) {
                    int currentIndex = 0;
                    for (int i = 0; i <= lastObjectIndex; i++) {
                        Pause *pause =  [self.currentDayEntry sortedPauses][i];
                        if ([self.currentPause.startTime compare:pause.startTime ] == NSOrderedSame) {
                            currentIndex = i;
                        }
                    }
                    
                    if (currentIndex + 1 <= lastObjectIndex) {
                        pause = [self.currentDayEntry sortedPauses][currentIndex + 1];
                    }
                }
                
                if (pause != nil) {
                    datePicker.maximumDate = pause.startTime;
                } else if (self.currentDayEntry.checkOutTime != nil) {
                    datePicker.maximumDate = [self.currentDayEntry.checkOutTime addMinutes:-1];
                } else {
                    // dont allow dates before now date if the day is today
                    DayEntry *nextEntry = [[AXDataStore sharedInstance] nextDayEntryWithCheckinGreater:datePicker.date];
                    if (nextEntry) {
                        //datePicker.maximumDate = nextEntry.checkInTime;

                        components.day += 1;
                        components.second -= 1;
                        NSDate *dayEnd = [[NSCalendar currentCalendar] dateFromComponents:components];
                        checkMaxDate = false;
                        datePicker.maximumDate = dayEnd;
                    } else {
                        datePicker.maximumDate = [[[NSDate date] truncateSeconds] addMinutes:-1];
                    }
                }
            }
            
            // if there is already a value set it
            if (self.currentPause.startTime != nil) {
                [datePicker setDate:self.currentPause.startTime];
            }
            
            break;
        }
        case 2 : {
            // start should always be set before
            if (self.currentPause.startTime != nil) {
                NSDate *minDate = [self.currentPause.startTime addMinutes:1];
                datePicker.minimumDate = minDate;
                [datePicker setDate:minDate];
            }
            
            NSInteger lastObjectIndex = [self.currentDayEntry.pauses count] - 1;
                
            Pause *pause = nil;
            if (self.currentPause != nil) {
                // edit pause
                int currentIndex = 0;
                for (int i = 0; i <= lastObjectIndex; i++) {
                    Pause *pause =  [self.currentDayEntry sortedPauses][i];
                    if ([self.currentPause.startTime compare:pause.startTime] == NSOrderedSame) {
                        currentIndex = i;
                    }
                }
                if (currentIndex + 1 <= lastObjectIndex) {
                    // get pause after if possible
                    pause = [self.currentDayEntry sortedPauses][currentIndex + 1];
                }
            }

            if (pause != nil) {
                datePicker.maximumDate = pause.startTime;
            } else if (self.currentDayEntry.checkOutTime != nil) {
                datePicker.maximumDate = self.currentDayEntry.checkOutTime;
            } else {
                datePicker.maximumDate = [NSDate date];
            }
            
            // if there is already a value set it
            if (self.currentPause.endTime != nil) {
                [datePicker setDate:self.currentPause.endTime];
            }
            
            break;
        }
        default :
            break;
    }
    NSDate *nowDate = [NSDate date];
    if (checkMaxDate && [datePicker.maximumDate compare:nowDate] == NSOrderedDescending) {
        datePicker.maximumDate = nowDate;
        datePicker.date = nowDate;
    }

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell;
    if ([self datePickerIsShown] &&
        (self.datePickerIndexPath.row == indexPath.row) &&
        (self.datePickerIndexPath.section == indexPath.section)){
        
        cell = [self createPickerCell:indexPath];
        return cell;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
    }
	cell.userInteractionEnabled = YES;
	cell.detailTextLabel.text = @" ";
	cell.detailTextLabel.textColor = GLOBALFONTCOLOR;

    if (indexPath.section == 0) {
        NSUInteger endRow = 1;
        if (self.datePickerIndexPath.row == 1) {
            endRow = 2;
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLS_START_PAUSE;
            cell.detailTextLabel.text = [self.currentPause startTimeDisplayValueForTargetDate:self.currentDayEntry.checkInTime];
        } else if (indexPath.row == endRow) {
            cell.textLabel.text = NSLS_END_PAUSE;
            if (self.currentPause.startTime != nil) {
                if (self.currentPause.endTime != nil) {
                    cell.detailTextLabel.text = [self.currentPause endTimeDisplayValueForTargetDate:self.currentDayEntry.checkInTime];
                }
            } else {
                cell.userInteractionEnabled = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        
        if ([self datePickerIsShown] &&
            (self.datePickerIndexPath.row - 1 == indexPath.row) &&
            (self.datePickerIndexPath.section == indexPath.section)) {
            cell.detailTextLabel.textColor = SELECTIONCOLOR;
        }
        
        if (cell.userInteractionEnabled == NO) {
            cell.textLabel.textColor = NOTHIGHLIGHTED;
        } else {
            cell.textLabel.textColor = GLOBALFONTCOLOR;
        }
    } else {
        cell.textLabel.text = NSLS_DELETE_PAUSE;
        cell.textLabel.textColor = C_SYSTEM_RED;
    }

	return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 &&
        indexPath.row == 0) {
        [self deletePause];
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self datePickerIsShown] &&
        (self.datePickerIndexPath.row != indexPath.row)) {

        NSIndexPath *newPickerIndexPath;
        if (self.datePickerIndexPath.row == 2 &&
            indexPath.row == 0) {
            newPickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
        } else if (self.datePickerIndexPath.row == 1 &&
                   indexPath.row == 2) {
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

            AXDatePickerTableViewCell *aXDatePickerTableViewCell = (AXDatePickerTableViewCell *)[tableView cellForRowAtIndexPath:self.datePickerIndexPath];
            UIDatePicker *datePicker = aXDatePickerTableViewCell.datePicker;
            [self updateDueToDateChange:datePicker];
        }
    } else if (![self datePickerIsShown] &&
        indexPath.row <= 1) {
        NSIndexPath *newPickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1
                                                             inSection:0];
        [tableView beginUpdates];
        [self showNewPickerAtIndex:newPickerIndexPath];
        [tableView endUpdates];

        AXDatePickerTableViewCell *aXDatePickerTableViewCell = (AXDatePickerTableViewCell *)[tableView cellForRowAtIndexPath:self.datePickerIndexPath];
        UIDatePicker *datePicker = aXDatePickerTableViewCell.datePicker;
        [self updateDueToDateChange:datePicker];
    }
}

- (BOOL)datePickerIsShown {
    return self.datePickerIndexPath != nil;
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

- (void)hideExistingPicker {
    if ([self datePickerIsShown]) {
        [self.tableView deleteRowsAtIndexPaths:@[self.datePickerIndexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }
}

- (void)showNewPickerAtIndex:(NSIndexPath *)indexPath {
    self.datePickerIndexPath = indexPath;
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
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

- (void)updateDueToDateChange:(UIDatePicker *)datePicker {
    if ([self datePickerIsShown] &&
        datePicker) {
        [self updatePauseWith:datePicker];
        
        [self.tableView beginUpdates];
        [self reloadRowsSurroundingDatePicker];
        [self.tableView endUpdates];
        
        [self updateUI];
    }
}

- (void)reloadRowsSurroundingDatePicker {
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1
                                                                inSection:self.datePickerIndexPath.section]]
                          withRowAnimation:UITableViewRowAnimationNone];
    if (self.datePickerIndexPath.row == 1) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row + 1
                                                                    inSection:self.datePickerIndexPath.section]]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)updatePauseWith:(UIDatePicker *)datePicker {
    switch (self.datePickerIndexPath.row) {
        case 1 :
            [self.currentPause configureWithStart:datePicker.date
                                      andTimeZone:[[NSTimeZone systemTimeZone] name]];
            break;
        case 2 :
            [self.currentPause configureWithEnd:datePicker.date
                                    andTimeZone:[[NSTimeZone systemTimeZone] name]];
            break;
        default :
            break;
    }
}

#pragma mark - private methods

- (void)updateUI {
    [self tryToEnableDoneButton];
}

- (void)done {
    if (self.newPause) {
        [self.currentDayEntry addPausesObject:self.currentPause];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel {
    [[self.currentPause managedObjectContext] deleteObject:self.currentPause];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deletePause {
    if (!self.newPause) {
        [self.currentDayEntry removePausesObject:self.currentPause];
        self.currentPause.dayentry = nil;
        [[self.currentPause managedObjectContext] deleteObject:self.currentPause];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)tryToEnableDoneButton {
    self.navigationItem.rightBarButtonItem.enabled = [self allowedToSave];
}

- (BOOL)allowedToSave {
    if (((self.currentPause.startTime == nil || self.currentPause.endTime == nil) &&
         ![self.currentPause isCurrentlyRunning])) {
        if (self.currentPause.startTime == nil) {
            return NO;
        }
        if (self.currentPause.endTime == nil) {
            return NO;
        }
    }
    return YES;
}

@end
