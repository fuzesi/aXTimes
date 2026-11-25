//
//  AXGeneralSettingsTableViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 03/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXGeneralSettingsTableViewController.h"

#import "AXProjectCheckinSettingsViewController.h"
#import "AXSwitchTableViewCell.h"

#import "AXTextViewTableViewCell.h"

#import "NSString+AXNSStringCategory.h"
#import "AXStandardTableViewCell.h"

typedef NS_ENUM (NSUInteger, GeneralSettingsTextFieldType) {
    GeneralSettingsTextFieldTypeHoursPerDay = 0,
    GeneralSettingsTextFieldTypeHourlyWage
};

typedef NS_ENUM (NSUInteger, GeneralSettingsSectionIndex) {
    GeneralSettingsSectionIndexCalculationrelated = 0,
    GeneralSettingsSectionIndexDefaultvalues,
    GeneralSettingsSectionIndexDisplaysettings,
    GeneralSettingsSectionIndexMiscellaneous
};

static NSString *SegmentedControlCellIdentifier = @"SegmentedControlCell";

@interface AXGeneralSettingsTableViewController()

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UITextField *activeKeyboardObject;
@property (nonatomic, strong) NSDecimalNumber *oldHourlyWage;
@property (nonatomic, strong) SettingsManager *settingsManager;

@end

@implementation AXGeneralSettingsTableViewController

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.settingsManager = [SettingsManager new];
    self.title = NSLS_GENERAL_SETTINGS;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([AXNumbersTextFieldTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([AXNumbersTextFieldTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([AXStandardTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([AXStandardTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([AXSwitchTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([AXSwitchTableViewCell class])];
    [self.tableView
     registerNib:[UINib nibWithNibName:SegmentedControlCellIdentifier bundle:nil]
     forCellReuseIdentifier:SegmentedControlCellIdentifier];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == GeneralSettingsSectionIndexCalculationrelated) {
        return 3; // working week + hours per day + hourly rate
    } else if (section == GeneralSettingsSectionIndexDefaultvalues) {
        return 3;
        //comment + default break (on/off) (+ start break + end break) + default-check-in
    } else if (section == GeneralSettingsSectionIndexDisplaysettings) {
        return 2; // time format + currency
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *UITableViewCellStyleDefaultIdentifier = @"UITableViewCellStyleDefault";
    static NSString *UITableViewCellStyleValue1Identifier = @"UITableViewCellStyleValue1";

    if (indexPath.section == GeneralSettingsSectionIndexCalculationrelated && (
        indexPath.row == 1 ||
        indexPath.row == 2)) {
        AXNumbersTextFieldTableViewCell *cell = [tableView
                                                 dequeueReusableCellWithIdentifier:NSStringFromClass([AXNumbersTextFieldTableViewCell class])
                                                 forIndexPath:indexPath];
        if (indexPath.row == 1) {
            cell.customTextLabel.text = NSLS_HOURS_PER_DAY;
            cell.textField.text = [self.settingsManager hoursPerDayDisplayValue];
            cell.textField.tag = GeneralSettingsTextFieldTypeHoursPerDay;
        } else {
            cell.customTextLabel.text = NSLS_HOURLYWAGE;
            cell.textField.text = [self.settingsManager hourlyWageDisplayValue];
            cell.textField.tag = GeneralSettingsTextFieldTypeHourlyWage;
        }
        
        cell.delegate = self;
        cell.textField.delegate = self;
        [cell.textField addTarget:self
                           action:@selector(textFieldEditingChanged:)
                 forControlEvents:UIControlEventEditingChanged];
        
        return cell;
    } else if ((indexPath.section == GeneralSettingsSectionIndexCalculationrelated && indexPath.row == 0) ||
               (indexPath.section == GeneralSettingsSectionIndexDefaultvalues && indexPath.row == 2)) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCellStyleDefaultIdentifier];

        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:UITableViewCellStyleDefaultIdentifier];
        }
        cell.detailTextLabel.textColor = GLOBALFONTCOLOR;
        cell.detailTextLabel.text = @"";
        if (indexPath.section == GeneralSettingsSectionIndexCalculationrelated &&
            indexPath.row == 0) {
            cell.textLabel.text = NSLS_WORKINGWEEK;
        } else {
            cell.textLabel.text = NSLS_PROJECT;
            if ([self.settingsManager isCheckinSettingNoProject]) {
                cell.detailTextLabel.text = NSLS_SETTINGS_DEFAULTPROJECT_NOPROJECT;
            } else if ([self.settingsManager isCheckinSettingLastProject]) {
                cell.detailTextLabel.text = NSLS_SETTINGS_DEFAULTPROJECT_LASTPROJECT;
            } else {
                cell.detailTextLabel.text = [[[AXDataStore sharedInstance] defaultProject] displayName];
            }
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else if (indexPath.section == GeneralSettingsSectionIndexMiscellaneous &&
               indexPath.row == 0) {
        AXSwitchTableViewCell *cell = [tableView
                                       dequeueReusableCellWithIdentifier:NSStringFromClass([AXSwitchTableViewCell class])
                                       forIndexPath:indexPath];
        cell.customTextLabel.text = NSLS_SHAKE_TO_UNDO;
        cell.switchControl.on = [self.settingsManager isShakeToUndo];
        [cell.switchControl addTarget:self
                               action:@selector(shakeToUndoSwitchChanged:)
                     forControlEvents:UIControlEventValueChanged];
        return cell;
    } else if (indexPath.section == GeneralSettingsSectionIndexDisplaysettings &&
               indexPath.row == 0) {
        SegmentedControlCell *cell = [tableView
                                      dequeueReusableCellWithIdentifier:SegmentedControlCellIdentifier
                                      forIndexPath:indexPath];
        cell.customTextLabel.text = NSLocalizedString(@"Time Format", nil);
        cell.segmentedControl.selectedSegmentIndex = [self.settingsManager timeFormatting];
        [cell.segmentedControl
         setTitle:[NSString stringWithFormat:NSLocalizedString(@"8%@50h", nil), [[NSNumberFormatter new] decimalSeparator]]
         forSegmentAtIndex:TimeFormattingDefault];
        [cell.segmentedControl
         setTitle:NSLocalizedString(@"8h 30m", nil)
         forSegmentAtIndex:TimeFormattingHhmm];
        [cell.segmentedControl
         addTarget:self
         action:@selector(segementedControlValueChanged:)
         forControlEvents:UIControlEventValueChanged];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCellStyleValue1Identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:UITableViewCellStyleValue1Identifier];
            cell.detailTextLabel.textColor = GLOBALFONTCOLOR;
        }
        
        cell.detailTextLabel.numberOfLines = 1;

        if (indexPath.section == GeneralSettingsSectionIndexDisplaysettings &&
            indexPath.row == 1) {
            cell.textLabel.text = NSLS_CURRENCY;
            cell.detailTextLabel.text = [self.settingsManager currencyIso];
        } else if (indexPath.section == GeneralSettingsSectionIndexDefaultvalues &&
              indexPath.row == 0) {
            AXStandardTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXStandardTableViewCell class]) forIndexPath:indexPath];
            commentCell.selectionStyle = UITableViewCellSelectionStyleDefault;
            commentCell.customTextLabel.text = NSLS_COMMENT;
            commentCell.customDetailTextLabel.text = [self.settingsManager defaultComment];
            commentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return commentCell;
        } else {
            cell.textLabel.text = NSLS_PAUSE;
            
            if ([self.settingsManager isDefaultPause]) {
                cell.detailTextLabel.text = NSLS_ON;
            } else {
                cell.detailTextLabel.text = NSLS_OFF;
            }
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == GeneralSettingsSectionIndexCalculationrelated &&
        indexPath.row == 0) {
        AXWorkingWeekTableViewController *aXWorkingWeekTableViewController = [AXWorkingWeekTableViewController new];
        aXWorkingWeekTableViewController.delegate = self;
        aXWorkingWeekTableViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:aXWorkingWeekTableViewController
                                             animated:YES];
    }
    
    if (indexPath.section == GeneralSettingsSectionIndexDisplaysettings &&
        indexPath.row == 1) {
        CurrencyTableViewController *currencyTableViewController = [CurrencyTableViewController new];
        [self.navigationController pushViewController:currencyTableViewController
                                             animated:YES];
    }
    
    if (indexPath.section == GeneralSettingsSectionIndexDefaultvalues &&
        indexPath.row == 0) {
        AXDefaultCommentViewController *aXDefaultCommentViewController = [AXDefaultCommentViewController new];
        aXDefaultCommentViewController.delegate = self;
        aXDefaultCommentViewController.controllerTitle = NSLS_STANDARDCOMMENT;
        aXDefaultCommentViewController.initialString = [self.settingsManager defaultComment];
        [self.navigationController pushViewController:aXDefaultCommentViewController
                                             animated:YES];
    }
    
    if (indexPath.section == GeneralSettingsSectionIndexDefaultvalues &&
        indexPath.row == 1) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];

        AXDefaultPauseTableViewController *defaultPauseTableViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AXDefaultPauseTableViewController class])];
        defaultPauseTableViewController.delegate = self;
        
        defaultPauseTableViewController.defaultPauseEnabledState = [self.settingsManager isDefaultPause];
        
        defaultPauseTableViewController.defaultPauseStartDate = [self.settingsManager defaultPauseStart];
        defaultPauseTableViewController.defaultPauseEndDate = [self.settingsManager defaultPauseEnd];
        
        [self.navigationController pushViewController:defaultPauseTableViewController animated:YES];
    }
    
    if (indexPath.section == GeneralSettingsSectionIndexDefaultvalues &&
        indexPath.row == 2) {
        AXProjectCheckinSettingsViewController *aXProjectCheckinSettingsViewController = [AXProjectCheckinSettingsViewController new];
        aXProjectCheckinSettingsViewController.controllerTitle = NSLS_PROJECTS;
        aXProjectCheckinSettingsViewController.firstSectionFooterTitle = NSLS_SETTINGS_DEFAULTPROJECT_FOOTER;
        [self.navigationController pushViewController:aXProjectCheckinSettingsViewController
                                             animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case GeneralSettingsSectionIndexCalculationrelated:
            return NSLS_SETTINGS_GENERAL_SECTION_ONE_HEADER;
            break;
        case GeneralSettingsSectionIndexDefaultvalues:
            return NSLS_SETTINGS_GENERAL_SECTION_TWO_HEADER;
            break;
        case GeneralSettingsSectionIndexDisplaysettings:
            return NSLS_SETTINGS_GENERAL_SECTION_THREE_HEADER;
            break;
        case GeneralSettingsSectionIndexMiscellaneous:
            return NSLS_SETTINGS_GENERAL_SECTION_FOUR_HEADER;
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case GeneralSettingsSectionIndexCalculationrelated:
            return NSLS_SETTINGS_GENERAL_SECTION_ONE_FOOTER;
            break;
        case GeneralSettingsSectionIndexDefaultvalues:
            return NSLS_SETTINGS_GENERAL_SECTION_TWO_FOOTER;
            break;
        case GeneralSettingsSectionIndexDisplaysettings:
            return NSLS_SETTINGS_GENERAL_SECTION_THREE_FOOTER;
            break;
        case GeneralSettingsSectionIndexMiscellaneous:
            return NSLS_SETTINGS_GENERAL_SECTION_FOUR_FOOTER;
            break;
        default:
            return @"";
            break;
    }
}

#pragma mark - AXDefaultPauseTableViewControllerDelegate

- (void)setDefaultPauseEnabled:(BOOL)enabled {
    [self.settingsManager setIsDefaultPause:enabled];
}

- (void)setDefaultPauseStart:(NSDate *)start {
    [self.settingsManager setDefaultPauseStart:start];
}

- (void)setDefaultPauseEnd:(NSDate *)end {
    [self.settingsManager setDefaultPauseEnd:end];
}

#pragma mark - textfield delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self saveTextFieldInput:textField];
    
    [self checkHourlyWage];
    
    //http://stackoverflow.com/questions/5732438/how-to-get-uitableviewcells-index-from-its-edited-uitextfield/18980944#18980944
    
    // Get the cell in which the textfield is embedded
    id superView = textField;
    while (![superView isKindOfClass:[UITableViewCell class]]) {
        superView = [superView superview];
    }
    
    // Get that cell's index path
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)superView];
    
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.activeKeyboardObject = textField;
    
    self.oldHourlyWage = [self.settingsManager hourlyWage];

    if (self.tapGestureRecognizer == nil) {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(dismissKeyboard)];
        [self.view addGestureRecognizer:self.tapGestureRecognizer];
    }
    return YES;
}

#pragma mark - private methods

- (void)shakeToUndoSwitchChanged:(UISwitch *)switchControl {
    [self.settingsManager setIsShakeToUndo:switchControl.on];
}

- (void)checkHourlyWage {
    NSDecimalNumber *newValue = [self.settingsManager hourlyWage];
    if ([self.oldHourlyWage compare:newValue] != NSOrderedSame) {
        NSDate *nowDate = [NSDate date];
        DayEntry *dayEntry = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:nowDate];
        
        if (dayEntry && dayEntry.checkOutTime == nil) {
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:NSLS_QUESTION_ALERTVIEW_TITLE
                                        message:NSLocalizedString(@"Do you wish to take over the changes for the currently active entry?", "'Take over changes' alert view content. Translate 'Do you wish to take over the changes for the currently active entry?'")
                                        preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *yesAction = [UIAlertAction
                                        actionWithTitle:NSLS_YES_ALERTVIEW_ANSWER
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                                            dayEntry.hourlyWage = [self.settingsManager hourlyWage];
                                        }];
            UIAlertAction *noAction = [UIAlertAction
                                       actionWithTitle:NSLS_NO_ALERTVIEW_ANSWER
                                       style:UIAlertActionStyleCancel
                                       handler:nil];
            
            [alert addAction:yesAction];
            [alert addAction:noAction];
            
            [self presentViewController:alert
                               animated:YES
                             completion:nil];
        }
    }
}

- (void)textFieldEditingChanged:(id)sender {
    if ([sender isKindOfClass:[UITextField class]]) {
        [self saveTextFieldInput:sender];
    }
}

- (void)saveTextFieldInput:(UITextField *)textField {
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:2];
    [numberFormatter setRoundingIncrement:[NSNumber numberWithDouble:0.01]];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    
    NSString *stringToParse = [textField.text trim];
    NSNumber *numberSetByUser = [NSDecimalNumber zero];

    if (![stringToParse isEqualToString:@""]) {
        NSNumber *tempNumber = [numberFormatter numberFromString:stringToParse];
        if (tempNumber != nil) {
            NSString *tempString = [numberFormatter stringFromNumber:tempNumber];
            numberSetByUser = [numberFormatter numberFromString:tempString];
        }
    }
    
    if (textField.tag == GeneralSettingsTextFieldTypeHoursPerDay) {
        [self.settingsManager setHoursPerDay:numberSetByUser];
    } else if (textField.tag == GeneralSettingsTextFieldTypeHourlyWage){
        [self.settingsManager setHourlyWage:numberSetByUser.decimalNumber];
    }
}

- (void)dismissKeyboard {
    if (self.activeKeyboardObject != nil) {
        [self.activeKeyboardObject resignFirstResponder];
        [self.view removeGestureRecognizer:self.tapGestureRecognizer];
        self.tapGestureRecognizer = nil;
        self.activeKeyboardObject = nil;
    }
}

- (void)segementedControlValueChanged:(id)sender {
    if ([sender isKindOfClass:[UISegmentedControl class]]){
        UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
        [self.settingsManager setTimeFormatting:segmentedControl.selectedSegmentIndex];
    }
}

#pragma mark - AXNumbersTextFieldTableViewCellProtocol

- (void)donePressed {
    [self dismissKeyboard];
}

#pragma mark - AXDefaultCommentViewControllerDelegate

- (void)setStringFromTextView:(NSString *)text {
    [self.settingsManager setDefaultComment:text];
}

#pragma mark - AXWorkingWeekTableViewControllerProtocol

- (void)trySaveWorkWeekSetting:(NSMutableArray *)settingsWorkingweek {
    if (![settingsWorkingweek isEqualToArray:[NSMutableArray arrayWithArray:[self.settingsManager workingWeek]]]) {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:NSLS_QUESTION_ALERTVIEW_TITLE
                                    message:NSLS_WORKWEEK_POPUP_MESSAGE
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *fromToday = [UIAlertAction
                                    actionWithTitle:NSLS_WORKWEEK_POPUP_MESSAGE_ANSWER_FROMTODAY
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action) {
                                        NSDate *yesterDayDate = [[NSDate date] dateByAddingTimeInterval:-60 * 60 * 24];
                                        WorkingWeekSetting *workingWeekSetting = [[AXDataStore sharedInstance] getLatestWorkingWeekSettingForDate:yesterDayDate];
                                        
                                        NSDateFormatter *dateFormatter = [NSDateFormatter new];
                                        [dateFormatter setLocale:[NSLocale currentLocale]];
                                        [dateFormatter setDateFormat:@"YYYY_MM_dd"];
                                        NSString *nowDateString = [dateFormatter stringFromDate:yesterDayDate];
                                        
                                        if ([workingWeekSetting.validUntilString isEqualToString:nowDateString]) {
                                            if ([workingWeekSetting isWorkingWeekEqualWithWorkingWeekArray:settingsWorkingweek]) {
                                                [[AXDataStore sharedInstance] deleteObject:workingWeekSetting];
                                            }
                                        } else {
                                            WorkingWeekSetting *settingObject = nil;
                                            settingObject = [[[AXDataStore sharedInstance] managedObjectContext] newWorkingWeekSettingEntityWithValidUntilDate:yesterDayDate];
                                            NSArray *oldArray = [self.settingsManager workingWeek];
                                            [settingObject configureWithValidUntilDate:yesterDayDate
                                                                           andTimeZone:[[NSTimeZone systemTimeZone] name]];
                                            [settingObject configureWithWorkingWeek:oldArray];
                                        }
                                        
                                        [self.settingsManager setWorkingWeek:settingsWorkingweek];
                                    }];
        UIAlertAction *entire = [UIAlertAction
                                 actionWithTitle:NSLS_WORKWEEK_POPUP_MESSAGE_ANSWER_ENTIRE
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * _Nonnull action) {
                                     NSArray *array = [[AXDataStore sharedInstance] getAllManagedObjectsForClass:[WorkingWeekSetting class]];
                                     for (WorkingWeekSetting *settingObject in array) {
                                         [[AXDataStore sharedInstance] deleteObject:settingObject];
                                     }
                                     [self.settingsManager setWorkingWeek:settingsWorkingweek];
                                 }];
        
        [alert addAction:fromToday];
        [alert addAction:entire];
        
        [self presentViewController:alert
                           animated:YES
                         completion:nil];
    }
}

@end
