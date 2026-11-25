//
//  AXExportSettingsTableViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 04/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXExportSettingsTableViewController.h"

#import "AXDecimalSeparatorTableViewController.h"

#import "AXTextFieldTableViewCell.h"
#import "AXSwitchTableViewCell.h"

typedef NS_ENUM (NSUInteger, ExportSettingsTextFieldType) {
    ExportSettingsTextFieldTypeEmail = 0
};

@interface AXExportSettingsTableViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UITextField *activeKeyboardObject;
@property (nonatomic, strong) SettingsManager *settingsManager;

@end

@implementation AXExportSettingsTableViewController

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
    self.title = NSLS_EXPORT_SETTINGS;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([AXTextFieldTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([AXTextFieldTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([AXSwitchTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([AXSwitchTableViewCell class])];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *UITableViewCellStyleValue1Identifier = @"UITableViewCellStyleValue1";
    
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        AXTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXTextFieldTableViewCell class]) forIndexPath:indexPath];
        cell.customTextLabel.text = NSLS_EMAIL;
        cell.textField.text = [self.settingsManager exportEmail];
        cell.textField.tag = ExportSettingsTextFieldTypeEmail;
        cell.textField.delegate = self;
        [cell.textField addTarget:self
                           action:@selector(textFieldEditingChanged:)
                 forControlEvents:UIControlEventEditingChanged];
        
        return cell;
    }
    
    if (indexPath.row == 1)  {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCellStyleValue1Identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:UITableViewCellStyleValue1Identifier];
            cell.detailTextLabel.textColor = GLOBALFONTCOLOR;
        }
        cell.textLabel.text = NSLS_LANGUAGE_SETTINGS;
        cell.detailTextLabel.text = [self.settingsManager exportLanguageLocaleDisplayValue];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
    if (indexPath.row == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCellStyleValue1Identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:UITableViewCellStyleValue1Identifier];
            cell.detailTextLabel.textColor = GLOBALFONTCOLOR;
        }
        cell.textLabel.text = NSLS_DECIMALSEPARATOR_SETTINGS;
        cell.detailTextLabel.text = [self.settingsManager exportDecimalSeparatorDisplayValue];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
    if (indexPath.row == 3) {
        AXSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXSwitchTableViewCell class]) forIndexPath:indexPath];
        cell.customTextLabel.text = NSLS_INCL_WAGE;
        
        [cell.switchControl addTarget:self
                               action:@selector(exportWageSwitchChanged:)
                     forControlEvents:UIControlEventValueChanged];
        cell.switchControl.on = [self.settingsManager isExportWage];
        return cell;
    }
    
    if (indexPath.row == 4) {
        AXSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXSwitchTableViewCell class]) forIndexPath:indexPath];
        cell.customTextLabel.text = NSLS_INCL_TIMEZONE;
        
        [cell.switchControl addTarget:self
                               action:@selector(inclTimezoneSwitchChanged:)
                     forControlEvents:UIControlEventValueChanged];
        cell.switchControl.on = [self.settingsManager isExportTimeZone];
        return cell;
    }

    return cell;
}

#pragma mark - table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        LanguageTableViewController *languageTableViewController = [LanguageTableViewController new];
        [self.navigationController pushViewController:languageTableViewController animated:YES];
    }
    if (indexPath.row == 2) {
        AXDecimalSeparatorTableViewController *aXDecimalSeparatorTableViewController = [AXDecimalSeparatorTableViewController new];
        [self.navigationController pushViewController:aXDecimalSeparatorTableViewController animated:YES];
    }
}

#pragma mark - textfield delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self saveTextFieldInput:textField];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.activeKeyboardObject = textField;
    if (self.tapGestureRecognizer == nil) {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(dismissKeyboard)];
        [self.view addGestureRecognizer:self.tapGestureRecognizer];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - private methods

- (void)textFieldEditingChanged:(id)sender {
    if ([sender isKindOfClass:[UITextField class]]) {
        [self saveTextFieldInput:sender];
    }
}

- (void)saveTextFieldInput:(UITextField *)textField {
    if (textField.tag == ExportSettingsTextFieldTypeEmail) {
        [self.settingsManager setExportEmail:textField.text];
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

- (void)exportWageSwitchChanged:(UISwitch *)switchControl {
    BOOL valueToSet = switchControl.on;
    
    [self.settingsManager setIsExportWage:valueToSet];
}

- (void)inclTimezoneSwitchChanged:(UISwitch *)switchControl {
    BOOL valueToSet = switchControl.on;
    
    [self.settingsManager setIsExportTimeZone:valueToSet];
}

@end
