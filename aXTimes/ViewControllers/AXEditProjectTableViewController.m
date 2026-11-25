//
//  AXEditProjectTableViewController.m
//  aXTimes
//
//  Created by fuesec on 10/7/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXEditProjectTableViewController.h"
#import "NSString+AXNSStringCategory.h"

#import "AXTextFieldTableViewCell.h"
#import "AXDatePickerTableViewCell.h"

#import "RESideMenu.h"
#import "AXClientSelectionTableViewController.h"
#import "NSDecimalNumber+AXNSDecimalNumberCategory.h"
#import "NSNumberFormatter+AXNSNumberFormatterCategory.h"
#import "NSDate+AXNSDateCategory.h"
#import "NSDate+AXNSDateCategory.h"
#import "UIColor+AXUIColorCategory.h"

typedef NS_ENUM (NSUInteger, EditProjectFieldType) {
    EditProjectFieldTypeProjectName = 0,
    EditProjectFieldTypeProjectCode,
    EditProjectFieldTypeHourlyRate,
    EditProjectFieldTypeBudget
};

static NSString *colorCellString = @"ColorRightSideTableViewCell";
static NSString *standardCellString = @"AXStandardTableViewCell";
static NSString *DeletionCellIdentifier = @"DeletionCell";
static NSString *SegmentedControlCellIdentifier = @"SegmentedControlCell";

@interface AXEditProjectTableViewController ()

@property (strong, nonatomic) UITextField *activeKeyboardObject;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (strong, nonatomic) NSManagedObjectContext *childContext;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSIndexPath *datePickerIndexPath;

@property BOOL descriptionDelegate;
@property BOOL defaultCommentDelegate;
@property (nonatomic, strong) SettingsManager *settingsManager;

@end

@implementation AXEditProjectTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingsManager = [SettingsManager new];

    self.title = self.controllerTitle;
    
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateFormat = @"dd.MM.yyyy";
    
    [self registerNibs];

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    rightButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = rightButton;

    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    self.childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    if (!self.newProject) {
        NSManagedObject *returnObject = [[AXDataStore sharedInstance] fetchObjectWithManagedObjectIDWithChildContext:[self.project objectID] andContext:self.childContext];
        Project *projectWithChildContext = (Project *)returnObject;
        self.project = projectWithChildContext;
    } else {
        [[AXDataStore sharedInstance] turnIntoChildContext:self.childContext];
        Project *newProject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Project class]) inManagedObjectContext:self.childContext];
        Project *basicProject = [[AXDataStore sharedInstance] getBasicProject];
        newProject.active = @YES;
        newProject.useSubProjectsBudget = @NO;
        newProject.budget = [NSDecimalNumber zero];
        newProject.code = @"";
        newProject.colourAsHex = [self.settingsManager colorForProject].hex;
        newProject.defaultComment = basicProject.defaultComment;
        
        newProject.defaultProject = @NO;
        newProject.basicProject = @NO;

        newProject.fromDate = [[NSDate date] truncateHours];
        newProject.toDate = [newProject.fromDate addMonths:2];

        newProject.hourlyWage = basicProject.hourlyWage;
        newProject.name = @"";
        newProject.projectDescription = @"";
        
        newProject.position = [NSNumber numberWithInteger:[[AXDataStore sharedInstance] projectPosition]];
        newProject.roundingBehaviour = basicProject.roundingBehaviour;
        newProject.timeUnit = basicProject.timeUnit;
        
        newProject.filterActive = @YES;
        newProject.partialFilterActive = @YES;
        
        self.project = newProject;
    }
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [self tryToEnableDoneButton];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
    self.descriptionDelegate = NO;
    self.defaultCommentDelegate = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.newProject) {
        return 3;
    } else {
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0: // title, code, color, description, client, default comment
            numberOfRows = 6;
            break;
        case 1: {// start, end
            numberOfRows = 2;
            if ([self datePickerIsShown]) {
                numberOfRows++;
            }
            break;
            
        }
        case 2: // hourly rate, budget based on, budget, time unit, rounding
            numberOfRows = 5;
            break;
        case 3: // in case we are in editing mode of an existing project we need a deletion row
            numberOfRows = 1;
            break;
        default:
            break;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;
    AXTextFieldTableViewCell *textTableViewCell = nil;
    AXNumbersTextFieldTableViewCell *numberCell = nil;
    ColorRightSideTableViewCell *colorCell = nil;
    AXStandardTableViewCell *standardCell;
    DeletionCell *deletionCell;
    SegmentedControlCell *segmentedControllCell;

    // date picker case
    if ([self datePickerIsShown] &&
        self.datePickerIndexPath.section == indexPath.section &&
        self.datePickerIndexPath.row == indexPath.row){
        
        cell = [self createPickerCell:indexPath];
        return cell;
    }
    
    NSUInteger checkOut = 1;
    
    if ([self datePickerIsShown]) {
        if (self.datePickerIndexPath.row == 1) {
            checkOut = 2;
        } else if (self.datePickerIndexPath.row == 2) {
            checkOut = 1;
        }
    }
    
    if ((indexPath.section == 0 &&
         (indexPath.row == 0 ||
          indexPath.row == 1)) ) {

             textTableViewCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXTextFieldTableViewCell class]) forIndexPath:indexPath];
             //not always set to a value
             textTableViewCell.textField.text = @"";
             textTableViewCell.textField.placeholder = @"";
             textTableViewCell.textField.delegate = self;
             [textTableViewCell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
         } else if (indexPath.section == 2 &&
                    (indexPath.row == 0 ||
                     indexPath.row == 2))  {
                        numberCell = [tableView
                                      dequeueReusableCellWithIdentifier:NSStringFromClass([AXNumbersTextFieldTableViewCell class])
                                      forIndexPath:indexPath];
                        numberCell.userInteractionEnabled = YES;
                        numberCell.textField.text = @"";
                        numberCell.textField.placeholder = @"";
                        numberCell.textField.delegate = self;
                        numberCell.delegate = self;
                        [numberCell.textField addTarget:self
                                                 action:@selector(textFieldEditingChanged:)
                                       forControlEvents:UIControlEventEditingChanged];
                    } else if (indexPath.section == 0 && indexPath.row == 2) {
                        colorCell = [tableView
                                     dequeueReusableCellWithIdentifier:colorCellString
                                     forIndexPath:indexPath];
                        colorCell.customTextLabel.text = @"";

                    } else if (indexPath.section == 0 &&
                               (indexPath.row == 3 ||
                                indexPath.row == 5)) {
                                   standardCell = [tableView
                                                   dequeueReusableCellWithIdentifier:standardCellString
                                                   forIndexPath:indexPath];
                                   standardCell.selectionStyle = UITableViewCellSelectionStyleDefault;
                               } else if (indexPath.section == 1 &&
                                          indexPath.row == checkOut) {
                                   deletionCell = [tableView
                                                   dequeueReusableCellWithIdentifier:DeletionCellIdentifier
                                                   forIndexPath:indexPath];
                                   deletionCell.selectionStyle = UITableViewCellSelectionStyleDefault;
                                   deletionCell.customDetailTextLabel.textColor = GLOBALFONTCOLOR;
                               }  else if (indexPath.section == 2 &&
                                           indexPath.row == 1) {
                                   segmentedControllCell = [tableView
                                                            dequeueReusableCellWithIdentifier:SegmentedControlCellIdentifier
                                                            forIndexPath:indexPath];
                                   segmentedControllCell.selectionStyle = UITableViewCellSelectionStyleNone;
                               } else {
                                   cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                                   if (cell == nil) {
                                       cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                                     reuseIdentifier:CellIdentifier];
                                   }
                                   cell.detailTextLabel.text = @" ";
                                   cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                                   cell.accessoryType = UITableViewCellAccessoryNone;
                                   cell.detailTextLabel.textColor = GLOBALFONTCOLOR;
                                   cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
                               }
    
    if ([self datePickerIsShown] &&
        (self.datePickerIndexPath.row - 1 == indexPath.row) &&
        (self.datePickerIndexPath.section == indexPath.section)) {
        cell.detailTextLabel.textColor = SELECTIONCOLOR;
        deletionCell.customDetailTextLabel.textColor = SELECTIONCOLOR;
    }

    switch (indexPath.section) {
        case 0 : {
            switch (indexPath.row) {
                case 0 : {
                    textTableViewCell.customTextLabel.text = NSLS_NAME;
                    textTableViewCell.textField.text = self.project.name;
                    textTableViewCell.textField.placeholder = NSLS_REQUIRED;
                    // for some reason if delegate is not set here but more generally after the dequeue it will lead to crashes
                    textTableViewCell.textField.tag = EditProjectFieldTypeProjectName;
                    return textTableViewCell;
                }
                case 1 : {
                    textTableViewCell.customTextLabel.text = NSLS_PROJECT_CODE;
                    textTableViewCell.textField.text = self.project.code;
                    textTableViewCell.textField.tag = EditProjectFieldTypeProjectCode;
                    return textTableViewCell;
                }
                case 2 : {
                    colorCell.customTextLabel.text = NSLS_COLOUR;
                    colorCell.colorView.backgroundColor = [self.project color];
                    colorCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return colorCell;
                }
                case 3 : {
                    standardCell.customTextLabel.text = NSLS_DESCRIPTION;
                    standardCell.customDetailTextLabel.text = self.project.projectDescription;
                    standardCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return standardCell;
                }
                case 4 : {
                    cell.textLabel.text = NSLS_CLIENT;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    if (self.project.customer == nil) {
                        cell.detailTextLabel.text = NSLS_NO_CLIENT;
                    } else {
                        cell.detailTextLabel.text = self.project.customer.displayName;
                    }
                    return cell;
                }
                case 5 : {
                    standardCell.customTextLabel.text = NSLS_STANDARDCOMMENT;
                    standardCell.customDetailTextLabel.text = self.project.defaultComment;
                    standardCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return standardCell;
                }
                default:
                    break;
            }
            break;
        }
        case 1 : {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLS_START_PAUSE;
                cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.project.fromDate];
                return cell;
            } else if (indexPath.row == checkOut) {
                deletionCell.customTextLabel.text = NSLS_END_PAUSE;
                if (self.project.toDate) {
                    deletionCell.customDetailTextLabel.text = [self.dateFormatter stringFromDate:self.project.toDate];
                    deletionCell.deletionButton.hidden = NO;
                } else {
                    deletionCell.customDetailTextLabel.text = @"";
                    deletionCell.deletionButton.hidden = YES;
                }
                [deletionCell.deletionButton addTarget:self
                                                action:@selector(deleteProjectEnd:)
                                      forControlEvents:UIControlEventTouchUpInside];
                return deletionCell;
            }

            break;
        }
        case 2 : {
            switch (indexPath.row) {
                case 0 : {
                    numberCell.customTextLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                                                       NSLS_HOURLYWAGE,
                                                       [self.settingsManager currencyIso]];
                    numberCell.textField.text = [self.project.hourlyWage stringValueNumberFormatted];
                    numberCell.textField.tag = EditProjectFieldTypeHourlyRate;
                    return numberCell;
                }
                case 1 : {
                    segmentedControllCell.customTextLabel.text = NSLS_BUDGET_BASED_ON;
                    segmentedControllCell.segmentedControl.selectedSegmentIndex = [self.project.useSubProjectsBudget boolValue] ? BudgetCalculationBasisSubprojects : BudgetCalculationBasisDefault;
                    [segmentedControllCell.segmentedControl
                     setTitle:NSLS_PROJECT
                     forSegmentAtIndex:BudgetCalculationBasisDefault];
                    [segmentedControllCell.segmentedControl
                     setTitle:NSLS_SUBPROJECTS
                     forSegmentAtIndex:BudgetCalculationBasisSubprojects];
                    [segmentedControllCell.segmentedControl
                     addTarget:self
                     action:@selector(segementedControlValueChanged:)
                     forControlEvents:UIControlEventValueChanged];
                    return segmentedControllCell;
                }
                case 2 : {
                    numberCell.textField.tag = EditProjectFieldTypeBudget;

                    if ([self.project.useSubProjectsBudget boolValue]) {
                        numberCell.customTextLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                                                           NSLS_PROJECT_BUDGET_IN_DAYS,
                                                           NSLS_SUBPROJECTS];
                        numberCell.textField.text = [[self.project sumOfSubProjectBudgets] stringValueNumberFormatted];
                        numberCell.userInteractionEnabled = NO;
                    } else {
                        numberCell.customTextLabel.text = NSLS_PROJECT_BUDGET_IN_DAYS;
                        numberCell.textField.text = [self.project.budget stringValueNumberFormatted];
                        numberCell.userInteractionEnabled = YES;
                    }

                    return numberCell;
                }
                case 3 : {
                    cell.textLabel.text = NSLS_TIME_UNIT;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
                                                 [self.project.timeUnit stringValue],
                                                 NSLS_MINUTE_SHORT];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                case 4 : {
                    cell.textLabel.text = NSLS_ROUNDING;
                    cell.detailTextLabel.text = ROUNDINGBEHAVIOURNAMES[[self.project.roundingBehaviour unsignedIntegerValue]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                default:
                    break;
            }
            break;
        }
        case 3 : {
            switch (indexPath.row) {
                case 0 : {
                    cell.textLabel.text = NSLS_DELETE_PROJECT;
                    cell.textLabel.textColor = C_SYSTEM_RED;
                    return cell;
                }

                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if ([self datePickerIsShown] &&
            (self.datePickerIndexPath.row != indexPath.row) &&
            indexPath.row != 3) {
            NSIndexPath *newPickerIndexPath;
            if (self.datePickerIndexPath.row == 2 &&
                indexPath.row == 0) {
                newPickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:self.datePickerIndexPath.section];
            } else if (self.datePickerIndexPath.row == 1 &&
                       indexPath.row == 2) {
                newPickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.datePickerIndexPath.section];
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
        
        if (indexPath.row == 0 ||
            indexPath.row == 1) {
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
    
    switch (indexPath.section) {
        case 0 : {
            switch (indexPath.row) {
                case 2 : {
                    id <ColorPickerViewModelProtocol> viewModel;
                    id<CurrentColorProviderProtocol> provider;
                    ColorPickerViewController *controller;

                    provider = (id<CurrentColorProviderProtocol>) self.project;
                    viewModel = [[ColorPickerViewModel alloc]
                                 initWithColors:[self.settingsManager colorPool]
                                 currentColorProvider:provider];
                    controller = [ColorPickerViewController new];
                    controller.viewModel = viewModel;
                    [self.navigationController pushViewController:controller
                                                         animated:YES];
                    break;
                }
                case 3 : {
                    AXDefaultCommentViewController *defaultCommentViewController = [AXDefaultCommentViewController new];
                    defaultCommentViewController.delegate = self;
                    defaultCommentViewController.controllerTitle = NSLS_DESCRIPTION;
                    defaultCommentViewController.initialString = self.project.projectDescription;
                    self.descriptionDelegate = YES;
                    [self.navigationController pushViewController:defaultCommentViewController
                                                         animated:YES];
                    break;
                }
                case 4 : {
                    AXClientSelectionTableViewController *aXClientSelectionTableViewController = [AXClientSelectionTableViewController new];
                    aXClientSelectionTableViewController.project = self.project;
                    [self.navigationController pushViewController:aXClientSelectionTableViewController
                                                         animated:YES];
                    break;
                }
                case 5 : {
                    AXDefaultCommentViewController *defaultCommentViewController = [AXDefaultCommentViewController new];
                    defaultCommentViewController.delegate = self;
                    defaultCommentViewController.controllerTitle = NSLS_STANDARDCOMMENT;
                    defaultCommentViewController.initialString = self.project.defaultComment;
                    self.defaultCommentDelegate = YES;
                    [self.navigationController pushViewController:defaultCommentViewController
                                                         animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1 : {
            break;
        }
        case 2 : {
            switch (indexPath.row) {
                case 3 :
                case 4 : {
                    if (indexPath.row == 3) {
                        AXTimeUnitSettingsTableViewController *aXTimeUnitSettingsTableViewController = [AXTimeUnitSettingsTableViewController new];
                        aXTimeUnitSettingsTableViewController.delegate = self;
                        aXTimeUnitSettingsTableViewController.initialValue = [self.project.timeUnit unsignedIntegerValue];
                        [self.navigationController pushViewController:aXTimeUnitSettingsTableViewController
                                                             animated:YES];
                    } else if (indexPath.row == 4) {
                        AXRoundingSettingsTableViewController *aXRoundingSettingsTableViewController = [AXRoundingSettingsTableViewController new];
                        aXRoundingSettingsTableViewController.delegate = self;
                        aXRoundingSettingsTableViewController.initialValue = [self.project.roundingBehaviour unsignedIntegerValue];
                        [self.navigationController pushViewController:aXRoundingSettingsTableViewController
                                                             animated:YES];
                    }
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 3 : {
            switch (indexPath.row) {
                case 0 : {
                    [self askDelete];
                    break;
                }
                    
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = UITableViewAutomaticDimension;
    if ([self datePickerIsShown] &&
        self.datePickerIndexPath.section == indexPath.section &&
        self.datePickerIndexPath.row == indexPath.row){
        rowHeight = 162;
    }
    return rowHeight;
}

#pragma mark - textfield and textview delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self saveTextFieldInput:textField];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeKeyboardObject = textField;

    if (!self.tapGestureRecognizer) {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        [self.view addGestureRecognizer:self.tapGestureRecognizer];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - private methods

- (void)dismissKeyboard {
    if (self.activeKeyboardObject) {
        [self.activeKeyboardObject resignFirstResponder];
        [self.view removeGestureRecognizer:self.tapGestureRecognizer];
        self.tapGestureRecognizer = nil;
    }
}

- (void)done {
    [self dismissKeyboard];

    BOOL setNewDefault = NO;
    if (self.newProject) {
        // -1 because the basic project should already exist
        if ([[AXDataStore sharedInstance] getCountForAllManagedObjectsForClass:[Project class]] - 1 == 0) {
            // set new default because it is the first project
            setNewDefault = YES;
            self.project.defaultProject = @YES;
        }
    }
    
    if (self.project.fromDate) {
        [self.project configureWithStart:self.project.fromDate
                             andTimeZone:[[NSTimeZone systemTimeZone] name]];
    }
    if (self.project.toDate) {
        [self.project configureWithEnd:self.project.toDate
                           andTimeZone:[[NSTimeZone systemTimeZone] name]];
    }
    
    NSError *error = nil;
    if (![[self.project managedObjectContext] save:&error]) {

    } else {
        if (setNewDefault) {
            // update settings if save was successful
            [self.settingsManager setIsCheckinSettingNoProject:NO];
            [self.settingsManager setIsCheckinSettingLastProject:NO];
            Project *project = [[AXDataStore sharedInstance] getBasicProject];
            project.defaultProject = @NO;
        }
        [self.settingsManager advanceProjectColorRotation];
    }
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)cancel {
    [self dismissKeyboard];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)delete {
    BOOL setNewDefault = NO;
    if ([self.project.defaultProject boolValue]) {
        // this project used to be default
        setNewDefault = YES;
    }
    [self.project.managedObjectContext deleteObject:self.project];
    NSError *error = nil;
    if (![[self.project managedObjectContext] save:&error]) {
        
    } else {
        UINavigationController *navigationController;
        if (setNewDefault) {
            // upon default project settings upon successfull save
            [self.settingsManager setIsCheckinSettingNoProject:YES];
            [self.settingsManager setIsCheckinSettingLastProject:NO];
            Project *project = [[AXDataStore sharedInstance] getBasicProject];
            project.defaultProject = @YES;
        }
        if ([self.presentingViewController isKindOfClass:[RESideMenu class]]) {
            RESideMenu *sideMenu = (RESideMenu *)self.presentingViewController;
            if ([sideMenu.contentViewController isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tabBarController = (UITabBarController *)sideMenu.contentViewController;
                if ([tabBarController.viewControllers[3] isKindOfClass:[UINavigationController class]]) {
                    navigationController = (UINavigationController *)tabBarController.viewControllers[3];
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
    UIAlertController *alert;
    if ([self allowedToDelete]) {
        alert = [UIAlertController
                 alertControllerWithTitle:NSLS_QUESTION_ALERTVIEW_TITLE
                 message:NSLS_DELETEPROJECT_Q
                 preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *delete = [UIAlertAction
                                 actionWithTitle:NSLS_DELETE_PROJECT
                                 style:UIAlertActionStyleDestructive
                                 handler:^(UIAlertAction *action) {
                                     [self delete];
                                 }];
        UIAlertAction *cancel = [UIAlertAction
                                 actionWithTitle:NSLS_CANCEL
                                 style:UIAlertActionStyleCancel
                                 handler:nil];
        
        [alert addAction:delete];
        [alert addAction:cancel];
    } else {
        alert = [UIAlertController
                 alertControllerWithTitle:NSLS_WARNINGPOPUP
                 message:NSLS_CANTDELETEPROJECT
                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:NSLS_OKPOPUP
                             style:UIAlertActionStyleDefault
                             handler:nil];
        
        [alert addAction:ok];
    }
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

- (BOOL)allowedToDelete {
    if ([self.project.dayEntries count] > 0) {
        return NO;
    } else if ([self.project.subProjects count] > 0) {
        for (Project *subProject in self.project.subProjects.allObjects) {
            if ([subProject.dayEntries count] > 0) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)tryToEnableDoneButton {
    self.navigationItem.rightBarButtonItem.enabled = [self allowedToSave];
}

- (BOOL)allowedToSave {
    if (![self.project.name isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

- (void)textFieldEditingChanged:(id)sender {
    if ([sender isKindOfClass:[UITextField class]]) {
        [self saveTextFieldInput:sender];
    }
}

- (void)saveTextFieldInput:(UITextField *)textField {
    switch (textField.tag) {
        case EditProjectFieldTypeProjectName:
            self.project.name = [textField.text trim];
            break;
        case EditProjectFieldTypeProjectCode:
            self.project.code = [textField.text trim];
            break;
            
        case EditProjectFieldTypeHourlyRate:
            
        case EditProjectFieldTypeBudget: {
            NSNumberFormatter *numberFormatter = [NSNumberFormatter defaultNumberFormatter_Static:YES];
            
            NSString *stringToParse = @"";
            if ([[textField.text trim] isEqualToString:@""]) {
                stringToParse = @"0";
            } else {
                stringToParse = textField.text;
            }
            NSNumber *tempNumber = [numberFormatter numberFromString:stringToParse];
            
            NSDecimalNumber *numberSetByUser = [tempNumber decimalNumber];
            
            if (numberSetByUser != nil) {
                switch (textField.tag) {
                    case EditProjectFieldTypeHourlyRate : {
                        self.project.hourlyWage = numberSetByUser;
                        break;
                    }
                    case EditProjectFieldTypeBudget : {
                        self.project.budget = numberSetByUser;
                        break;
                    }
                    default:
                        break;
                }
            }
        }
            break;
        default:
            break;
    }

    [self tryToEnableDoneButton];
}

- (void)registerNibs {
    UINib *textTableViewCellNib = [UINib
                                   nibWithNibName:NSStringFromClass([AXTextFieldTableViewCell class])
                                   bundle:nil];
    [self.tableView registerNib:textTableViewCellNib
         forCellReuseIdentifier:NSStringFromClass([AXTextFieldTableViewCell class])];
    UINib *datePickerTableViewCellNib = [UINib
                                         nibWithNibName:NSStringFromClass([AXDatePickerTableViewCell class])
                                         bundle:nil];
    [self.tableView registerNib:datePickerTableViewCellNib
         forCellReuseIdentifier:NSStringFromClass([AXDatePickerTableViewCell class])];
    UINib *numberTextFieldTabelViewCellNib = [UINib
                                              nibWithNibName:NSStringFromClass([AXNumbersTextFieldTableViewCell class])
                                              bundle:nil];
    [self.tableView registerNib:numberTextFieldTabelViewCellNib
         forCellReuseIdentifier:NSStringFromClass([AXNumbersTextFieldTableViewCell class])];
    UINib *colorCellNib = [UINib
                           nibWithNibName:colorCellString
                           bundle:nil];
    [self.tableView registerNib:colorCellNib
         forCellReuseIdentifier:colorCellString];
    UINib *standardCellNib = [UINib
                              nibWithNibName:standardCellString
                              bundle:nil];
    [self.tableView registerNib:standardCellNib
         forCellReuseIdentifier:standardCellString];
    UINib *deletionCellNib;
    deletionCellNib = [UINib nibWithNibName:DeletionCellIdentifier
                                     bundle:nil];
    [self.tableView registerNib:deletionCellNib
         forCellReuseIdentifier:DeletionCellIdentifier];
    [self.tableView
     registerNib:[UINib nibWithNibName:SegmentedControlCellIdentifier bundle:nil]
     forCellReuseIdentifier:SegmentedControlCellIdentifier];
}

- (void)deleteProjectEnd:(id)sender {
    [self.tableView beginUpdates];
    [self hideExistingPicker];
    
    self.project.toDate = nil;
    
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

- (void)segementedControlValueChanged:(id)sender {
    if ([sender isKindOfClass:[UISegmentedControl class]]){
        UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
        self.project.useSubProjectsBudget = segmentedControl.selectedSegmentIndex == BudgetCalculationBasisDefault ? @NO : @YES;
    }
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2
                                                                inSection:2]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
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
        [self updateProjectWith:datePicker];
        
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

- (void)updateProjectWith:(UIDatePicker *)datePicker {
    switch (self.datePickerIndexPath.row) {
        case 1:
            self.project.fromDate = [datePicker.date truncateHours];
            break;
        case 2:
            self.project.toDate = [datePicker.date truncateHours];
            break;
        default :
            break;
    }
}

- (BOOL)datePickerIsShown {
    return self.datePickerIndexPath != nil;
}

- (UITableViewCell *)createPickerCell:(NSIndexPath *)indexPath {

    AXDatePickerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXDatePickerTableViewCell class]) forIndexPath:indexPath];
    
    UIDatePicker *datePicker = cell.datePicker;
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    datePicker.maximumDate = nil;
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    switch (indexPath.row) {
        case 1 : {
            datePicker.date = self.project.fromDate;
            if (!self.project.toDate) {
                datePicker.maximumDate = [self.project.toDate addDays:-1];
            }
            break;
        }
        case 2 : {
            if (self.project.toDate) {
                datePicker.date = self.project.toDate;
            } else {
                datePicker.date = [self.project.fromDate addDays:30];
            }
            datePicker.minimumDate = [self.project.fromDate addDays:+1];
            break;
        }
        default :
            break;
    }
    
    return cell;
}

#pragma mark - AXTimeUnitSettingsTableViewControllerDelegate

- (void)setSelectedTimeUnit:(NSUInteger)timeUnitInMinutes {
    self.project.timeUnit = [NSNumber numberWithUnsignedInteger:timeUnitInMinutes];
}

#pragma mark - AXRoundingSettingsTableViewControllerDelegate

- (void)setSelectedRoundingBehaviour:(RoundingBehaviour)roundingBehaviour {
    self.project.roundingBehaviour = [NSNumber numberWithUnsignedInteger:roundingBehaviour];
}

#pragma mark - AXDefaultCommentViewControllerDelegate

- (void)setStringFromTextView:(NSString *)text {
    if (self.descriptionDelegate) {
        self.project.projectDescription = text;
    } else if (self.defaultCommentDelegate) {
        self.project.defaultComment = text;
    }
}

#pragma mark - AXNumbersTextFieldTableViewCellProtocol

- (void)donePressed {
    [self dismissKeyboard];
}

@end
