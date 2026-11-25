//
//  AXPauseTableViewController.m
//  aXTimes
//
//  Created by fuesec on 5/19/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXMigrationController.h"
#import "AXUtility.h"
#import "NSDate+AXNSDateCategory.h"
#import "AXDatePickerTableViewCell.h"
//#import "NSCalendar+AXNSCalendarCategory.h"
#import "NSDate+AXNSDateCategory.h"

static NSString *datePickeCell = @"DatePickerCell";

@interface AXMigrationController ()

@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *end;

@property (nonatomic, strong) NSDate *lowerLimit;
@property (nonatomic, strong) NSDate *upperLimit;

@property (nonatomic, strong) NSArray<DayEntry *> *allCompleteEntries;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSIndexPath *datePickerIndexPath;

@end

@implementation AXMigrationController

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

    self.title = NSLS_DATA_IMPORT_TITLE;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                   target:self
                                   action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                                    initWithTitle:NSLS_DATA_IMPORT_CONTINUE
                                    style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(done)];
    self.navigationItem.rightBarButtonItem = rightButton;

    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateFormat = @"dd.MM.yyyy";

    self.allCompleteEntries = [[AXDataStore sharedInstance] allDayEntriesSorted];

    if (self.allCompleteEntries.count > 0) {
        self.lowerLimit = self.allCompleteEntries.firstObject.checkInTime;
        self.upperLimit = self.allCompleteEntries.lastObject.checkInTime;

        self.start = self.lowerLimit;
        self.end = self.upperLimit;
    }

    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([AXDatePickerTableViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:datePickeCell];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.allCompleteEntries.count == 0) {
        return 0;
    }
    NSInteger numberOfRows = 2;
    if ([self datePickerIsShown]) {
        numberOfRows++;
    }
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.allCompleteEntries.count > 0) {
        return NSLS_DATA_IMPORT_QUESTION;
    } else {
        return NSLS_DATA_IMPORT_INSTRUCTION_NO_ENTRIES;
    }
}

- (UITableViewCell *)createPickerCell:(NSIndexPath *)indexPath {
    AXDatePickerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:datePickeCell];
    
    UIDatePicker *datePicker = cell.datePicker;
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];

    datePicker.minimumDate = nil;
    datePicker.maximumDate = nil;
    datePicker.datePickerMode = UIDatePickerModeDate;

    switch (indexPath.row) {
        case 1 : {
            datePicker.minimumDate = self.lowerLimit;
            datePicker.date = self.start;
            datePicker.maximumDate = self.end;

            break;
        }
        case 2 : {
            datePicker.minimumDate = self.start;
            datePicker.date = self.end;
            datePicker.maximumDate = self.upperLimit;

            break;
        }
        default :
            break;
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
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.start];
        } else if (indexPath.row == endRow) {
            cell.textLabel.text = NSLS_END_PAUSE;
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.end];
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
    }

	return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
            self.start = datePicker.date;
            break;
        case 2 :
            self.end = datePicker.date;
            break;
        default :
            break;
    }
}

#pragma mark - private methods

- (void)done {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 NSDateComponents *dayComponent = [NSDateComponents new];
                                 dayComponent.day = 1;

                                 NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                                 NSDate *tempDate = [calendar dateByAddingComponents:dayComponent toDate:self.end options:0];
                                 NSDateComponents *realEndComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSTimeZoneCalendarUnit) fromDate:tempDate];
                                 realEndComponents.hour = 0;
                                 realEndComponents.minute = 0;
                                 realEndComponents.second = 0;
                                 NSDate *realEnd = [calendar dateFromComponents:realEndComponents];

                                 NSPredicate *predicate = [NSPredicate
                                                           predicateWithFormat:@"((checkInTime >= %@) AND (checkInTime < %@))",
                                                           self.start,
                                                           realEnd];

                                 NSArray<DayEntry *> *filtredEntries = [self.allCompleteEntries filteredArrayUsingPredicate:predicate];
                                 self.selectedEntriesBlock(filtredEntries);
                             }];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
