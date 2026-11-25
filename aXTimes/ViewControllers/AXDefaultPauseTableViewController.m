//
//  AXDefaultPauseTableViewController.m
//  aXTimes
//
//  Created by fuesec on 01/02/15.
//  Copyright (c) 2015 aXimilate. All rights reserved.
//

#import "AXDefaultPauseTableViewController.h"

#import "AXDefaultPauseExceptionsTableViewController.h"
#import "NSCalendar+AXNSCalendarCategory.h"
#import "NSDate+AXNSDateCategory.h"

@interface AXDefaultPauseTableViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;

@property (strong, nonatomic) IBOutlet UIDatePicker *startPicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *endPicker;
@property (strong, nonatomic) IBOutlet UITableViewCell *startCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *endCell;
@property (strong, nonatomic) IBOutlet UISwitch *defaultPauseSwitch;
@property (strong, nonatomic) IBOutlet UITableViewCell *exceptionsTableViewCell;
@property (strong, nonatomic) IBOutlet UILabel *defaultPauseLabel;

@property (strong, nonatomic) NSDate *defaultStart;
@property (strong, nonatomic) NSDate *defaultEnd;
@property BOOL defaultEnabled;

@end

@implementation AXDefaultPauseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // start: setup titles
    self.navigationItem.title = NSLS_DEFAULTPAUSE_SETTINGS;
    
    if (self.leftDetailLabelStringForSwitchCell) {
        self.defaultPauseLabel.text = self.leftDetailLabelStringForSwitchCell;
    } else {
        self.defaultPauseLabel.text = NSLS_DEFAULTPAUSE_SETTINGS;
    }
    
    self.startCell.textLabel.text = NSLS_START_PAUSE;
    self.endCell.textLabel.text = NSLS_END_PAUSE;
    // end: setup titles

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLS_RESET style:UIBarButtonItemStylePlain target:self action:@selector(reset)];
    self.navigationItem.rightBarButtonItem = rightButton;

    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateFormat = @"HH:mm";
    
    // start: default values;
    NSCalendar *calendar = [NSCalendar defaultCalendar_Static:YES];
    NSDateComponents *components = [NSDateComponents new];
    [components setHour:12];
    [components setMinute:0];
    [components setSecond:0];
    self.defaultStart = [calendar dateFromComponents:components];
    [components setHour:13];
    [components setMinute:0];
    [components setSecond:0];
    self.defaultEnd = [calendar dateFromComponents:components];
    self.defaultEnabled = NO;
    // end: default values;

    [self.defaultPauseSwitch setOn:self.defaultPauseEnabledState];
    
    NSDate *startDate = self.defaultPauseStartDate;
    NSDate *endDate = self.defaultPauseEndDate;

    if (!startDate || !endDate) {
        //failsafe -> reset to default
        self.defaultPauseStartDate = self.defaultStart;
        self.defaultPauseEndDate = self.defaultEnd;
        startDate = self.defaultPauseStartDate;
        endDate = self.defaultPauseEndDate;
        [self.delegate setDefaultPauseStart:startDate];
        [self.delegate setDefaultPauseEnd:endDate];
    }
    
    [self.startPicker setDate:startDate];
    [self.endPicker setDate:endDate];
    self.startCell.detailTextLabel.text = [self.dateFormatter stringFromDate:startDate];
    self.endCell.detailTextLabel.text = [self.dateFormatter stringFromDate:endDate];
    
    [self.defaultPauseSwitch setOnTintColor:C_SYSTEM_GREEN];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
    [self setupTextUI];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setup];
    [super viewWillAppear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self setupTextUI];
}

- (void)setupTextUI {
    self.defaultPauseLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.startCell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.startCell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.endCell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.endCell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.exceptionsTableViewCell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.exceptionsTableViewCell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.defaultPauseEnabledState) {
        if (indexPath.section == 0 &&
            indexPath.row == 0) {
            return 44;
        } else {
            return 0;
        }
    }
    
    if (indexPath.section == 0 &&
        indexPath.row == 2) {
        NSIndexPath *currentlySelected = [self.tableView indexPathForSelectedRow];
        if (currentlySelected.row == 1) {
            if (self.lastSelectedIndexPath &&
                self.lastSelectedIndexPath == currentlySelected) {
                self.lastSelectedIndexPath = nil;
                return 0;
            } else {
                self.lastSelectedIndexPath = currentlySelected;
                
                self.startPicker.maximumDate = [self.defaultPauseEndDate addMinutes:-5];

                return 179;
            }
        } else {
            return 0;
        }
    }
    if (indexPath.section == 0 &&
        indexPath.row == 4) {
        NSIndexPath *currentlySelected = [self.tableView indexPathForSelectedRow];
        if (currentlySelected.row == 3) {
            if (self.lastSelectedIndexPath &&
                self.lastSelectedIndexPath == currentlySelected) {
                self.lastSelectedIndexPath = nil;
                return 0;
            } else {
                self.lastSelectedIndexPath = currentlySelected;
                
                self.endPicker.minimumDate = [self.defaultPauseStartDate addMinutes:5];

                return 179;
            }
        } else {
            return 0;
        }
    }
    
    if (indexPath.section == 1 &&
        indexPath.row == 0) {
        return 44;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row != 1 &&
            indexPath.row != 3) {
            self.lastSelectedIndexPath = nil;
        }
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            AXDefaultPauseExceptionsTableViewController *defaultPauseExceptionsTableViewController = [AXDefaultPauseExceptionsTableViewController new];
            [self.navigationController pushViewController:defaultPauseExceptionsTableViewController animated:YES];
        }
    }

}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return NSLS_SETTINGS_DEFAULTPAUSE_FOOTER;
    } else if (section == 1) {
        return NSLS_EXCEPTIONS_DESCRIPTION;
    } else {
        return @"";
    }
}

#pragma mark - outlet methods

- (IBAction)defaultPauseSwitchAction:(id)sender {
    self.defaultPauseEnabledState = self.defaultPauseSwitch.isOn;
    [self.delegate setDefaultPauseEnabled:self.defaultPauseSwitch.isOn];
    
    if (self.defaultPauseSwitch.isOn) { // also send date to delegate if it was just turned on
        [self.delegate setDefaultPauseStart:self.startPicker.date];
        [self.delegate setDefaultPauseEnd:self.endPicker.date];
    }
    
    // for updating the table view with animation
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self setup];
}

- (IBAction)startPickerAction:(id)sender {
    self.defaultPauseStartDate = self.startPicker.date;
    self.startCell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.startPicker.date];
    [self.delegate setDefaultPauseStart:self.startPicker.date];
}

- (IBAction)endPickerAction:(id)sender {
    self.defaultPauseEndDate = self.endPicker.date;
    self.endCell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.endPicker.date];
    [self.delegate setDefaultPauseEnd:self.endPicker.date];
}

#pragma mark - private methods
- (void)setup {
    self.exceptionsTableViewCell.textLabel.text = NSLS_EXCEPTIONS;
    NSArray *settingEntities = [[AXDataStore sharedInstance] getAllManagedObjectsForClass:[DefaultPauseSetting class]];
    if ([settingEntities count] > 0) {
        self.exceptionsTableViewCell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[settingEntities count]];
    } else {
        self.exceptionsTableViewCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", NSLS_NONE_PAUSES];
    }
}

- (void)reset {
    NSArray *settingEntities = [[AXDataStore sharedInstance] getAllManagedObjectsForClass:[DefaultPauseSetting class]];
    if (settingEntities) {
        for (DefaultPauseSetting *entity in settingEntities) {
            [[AXDataStore sharedInstance] deleteObject:entity];
        }
    }
    
    [self.defaultPauseSwitch setOn:self.defaultEnabled
                          animated:YES];
    self.defaultPauseEnabledState = self.defaultEnabled;
    [self.delegate setDefaultPauseEnabled:self.defaultEnabled];
    
    [self.startPicker setDate:self.defaultStart];
    self.startCell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.startPicker.date];
    [self.delegate setDefaultPauseStart:self.startPicker.date];
    
    [self.endPicker setDate:self.defaultEnd];
    self.endCell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.endPicker.date];
    [self.delegate setDefaultPauseEnd:self.endPicker.date];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end
