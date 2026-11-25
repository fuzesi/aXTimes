//
//  AXEditSubProjectTableViewController.m
//  aXTimes
//
//  Created by fuesec on 07/10/15.
//  Copyright © 2015 aXimilate. All rights reserved.
//

#import "AXEditSubProjectTableViewController.h"

#import "NSString+AXNSStringCategory.h"
#import "NSNumberFormatter+AXNSNumberFormatterCategory.h"
#import "NSDecimalNumber+AXNSDecimalNumberCategory.h"
#import "RESideMenu.h"
#import "AXTextFieldTableViewCell.h"

typedef NS_ENUM (NSUInteger, EditSubprojectFieldType) {
    EditSubprojectFieldTypeProjectName = 0,
    EditSubprojectFieldTypeProjectCode,
    EditSubprojectFieldTypeBudget
};


static NSString *textTableViewCellString = @"AXTextFieldTableViewCell";
static NSString *numberCellString = @"AXNumbersTextFieldTableViewCell";


@interface AXEditSubProjectTableViewController ()
@property (strong, nonatomic) UITextField *activeKeyboardObject;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) NSManagedObjectContext *childContext;
@end

@implementation AXEditSubProjectTableViewController

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.controllerTitle;
    
    //register cell nibs
    UINib *textTableViewCellNib = [UINib nibWithNibName:NSStringFromClass([AXTextFieldTableViewCell class]) bundle:nil];
    [self.tableView registerNib:textTableViewCellNib forCellReuseIdentifier:textTableViewCellString];
    
    UINib *numberTextFieldTabelViewCellNib = [UINib
                                              nibWithNibName:numberCellString
                                              bundle:nil];
    [self.tableView registerNib:numberTextFieldTabelViewCellNib
         forCellReuseIdentifier:numberCellString];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    rightButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    self.childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    if (!self.newSubProject) {
        NSManagedObject *returnObject = [[AXDataStore sharedInstance] fetchObjectWithManagedObjectIDWithChildContext:[self.subProject objectID] andContext:self.childContext];
        Project *projectWithChildContext = (Project *)returnObject;
        self.subProject = projectWithChildContext;
    } else {
       NSManagedObject *returnObject = [[AXDataStore sharedInstance] fetchObjectWithManagedObjectIDWithChildContext:[self.parentProject objectID] andContext:self.childContext];
        Project *projectWithChildContext = (Project *)returnObject;
        self.parentProject = projectWithChildContext;

        Project *newSubProject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Project class]) inManagedObjectContext:self.childContext];

        newSubProject.active = @YES;
        newSubProject.basicProject = @NO;
        
        newSubProject.colourAsHex = [UIColor whiteColor].hex;
        newSubProject.defaultProject = @NO;

        newSubProject.code = @"";
        newSubProject.name = @"";
        newSubProject.projectDescription = @"";
        newSubProject.budget = [NSDecimalNumber zero];

        newSubProject.filterActive = @YES;
        newSubProject.partialFilterActive = @NO;

        newSubProject.useSubProjectsBudget = @NO;

        self.subProject = newSubProject;
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
    NSUInteger numberOfSections = 1;
    if (!self.newSubProject) {
        numberOfSections++;
    }
    if ([self.subProject.parent.useSubProjectsBudget boolValue]) {
        numberOfSections++;
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 1;
    switch (section) {
        case 0: // title, code, description
            numberOfRows = 3;
            break;
        case 1:
        case 2:
        default:
            numberOfRows = 1;
            break;
    }
    return numberOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;
    AXTextFieldTableViewCell *textTableViewCell = nil;
    AXNumbersTextFieldTableViewCell *numberCell = nil;
    
    if (indexPath.section == 0 &&
        (indexPath.row == 0 || indexPath.row == 1)) {
        
        textTableViewCell = [tableView dequeueReusableCellWithIdentifier:textTableViewCellString forIndexPath:indexPath];
        //not always set to a value
        textTableViewCell.textField.text = @"";
        textTableViewCell.textField.placeholder = @"";
        textTableViewCell.textField.delegate = self;
        [textTableViewCell.textField addTarget:self
                                             action:@selector(textFieldEditingChanged:)
                                   forControlEvents:UIControlEventEditingChanged];
    } if (indexPath.section == 1 &&
          indexPath.row == 0 &&
          [self.subProject.parent.useSubProjectsBudget boolValue]) {
        numberCell = [tableView dequeueReusableCellWithIdentifier:numberCellString forIndexPath:indexPath];
        numberCell.textField.text = @"";
        numberCell.textField.placeholder = @"";
        numberCell.textField.delegate = self;
        numberCell.delegate = self;
        [numberCell.textField addTarget:self
                                 action:@selector(textFieldEditingChanged:)
                       forControlEvents:UIControlEventEditingChanged];
    } else {
        //http://stackoverflow.com/questions/12737860/assertion-failure-in-dequeuereusablecellwithidentifierforindexpath
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        
        cell.detailTextLabel.text = @" ";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.textColor = GLOBALFONTCOLOR;
        cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
    }
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0 : {
                textTableViewCell.customTextLabel.text = NSLS_NAME;
                textTableViewCell.textField.text = self.subProject.name;
                textTableViewCell.textField.placeholder = NSLS_REQUIRED;
                // for some reason if delegate is not set here but more generally after the dequeue it will lead to crashes
                textTableViewCell.textField.tag = EditSubprojectFieldTypeProjectName;
                return textTableViewCell;
            }
            case 1 : {
                textTableViewCell.customTextLabel.text = NSLS_PROJECT_CODE;
                textTableViewCell.textField.text = self.subProject.code;
                textTableViewCell.textField.tag = EditSubprojectFieldTypeProjectCode;
                return textTableViewCell;
            }
            case 2 : {
                cell.textLabel.text = NSLS_DESCRIPTION;
                cell.detailTextLabel.text = self.subProject.projectDescription;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
            default:
                break;
        }
    }
    
    if (indexPath.section == 1 &&
        indexPath.row == 0 &&
        [self.subProject.parent.useSubProjectsBudget boolValue]) {
        numberCell.customTextLabel.text = NSLS_PROJECT_BUDGET_IN_DAYS;
        numberCell.textField.text = [self.subProject.budget stringValueNumberFormatted];
        numberCell.textField.tag = EditSubprojectFieldTypeBudget;
        return numberCell;
    } else {
        cell.textLabel.text = NSLS_DELETE_SUBPROJECT;
        cell.textLabel.textColor = C_SYSTEM_RED;
        return cell;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0 : {
            switch (indexPath.row) {
                case 2 : {
                    AXDefaultCommentViewController *defaultCommentViewController = [AXDefaultCommentViewController new];
                    defaultCommentViewController.delegate = self;
                    defaultCommentViewController.controllerTitle = NSLS_DESCRIPTION;
                    defaultCommentViewController.initialString = self.subProject.projectDescription;
                    [self.navigationController pushViewController:defaultCommentViewController animated:YES];
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

    NSError *error = nil;
    if (self.newSubProject) {
        // if subproject is the first after creation
        // -> assign all dayentries from parentProject to subProject
        BOOL hasNoSubprojects = [[[self.parentProject subProjects] allObjects] count] == 0;
        if (hasNoSubprojects) {
            NSArray<DayEntry *> *entries = [self.parentProject.dayEntries allObjects];
            for (DayEntry *entry in entries) {
                entry.project = self.subProject;
            }
        }
        self.subProject.parent = self.parentProject;
        if ([self.subProject.parent.defaultProject boolValue]) {
            // update default project
            self.subProject.parent.defaultProject = @NO;
            self.subProject.defaultProject = @YES;
        }
    }
    if (![[self.subProject managedObjectContext] save:&error]) {

    }
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)delete {
    BOOL setNewDefault = NO;
    if ([self.subProject.defaultProject boolValue]) {
        setNewDefault = YES;
    }
    [self.subProject.managedObjectContext deleteObject:self.subProject];
    NSError *error = nil;
    if (![[self.subProject managedObjectContext] save:&error]) {

    } else {
        UINavigationController *navigationController;
        if (setNewDefault) {
            [[SettingsManager new] setIsCheckinSettingNoProject:YES];
            [[SettingsManager new] setIsCheckinSettingLastProject:NO];
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
                 message:NSLS_DELETESUBPROJECT_Q
                 preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *delete = [UIAlertAction
                                 actionWithTitle:NSLS_DELETE_SUBPROJECT
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
    if ([self.subProject.dayEntries count] > 0) {
        return NO;
    }
    return YES;
}

- (void)cancel {
    [self dismissKeyboard];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)tryToEnableDoneButton {
    self.navigationItem.rightBarButtonItem.enabled = [self allowedToSave];
}

- (BOOL)allowedToSave {
    if (![self.subProject.name isEqualToString:@""]) {
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
        case EditSubprojectFieldTypeProjectName:
            self.subProject.name = [textField.text trim];
            break;
        case EditSubprojectFieldTypeProjectCode:
            self.subProject.code = [textField.text trim];
            break;
        case EditSubprojectFieldTypeBudget: {
            NSNumberFormatter *numberFormatter = [NSNumberFormatter defaultNumberFormatter_Static:YES];
            
            NSString *stringToParse = @"";
            if ([[textField.text trim] isEqualToString:@""]) {
                stringToParse = @"0";
            } else {
                stringToParse = textField.text;
            }
            NSNumber *tempNumber = [numberFormatter numberFromString:stringToParse];
            
            NSDecimalNumber *numberSetByUser = [tempNumber decimalNumber];
            self.subProject.budget = numberSetByUser;
        }
            break;
        default:
            break;
    }
    
    [self tryToEnableDoneButton];
}

#pragma mark - AXDefaultCommentViewControllerDelegate

- (void)setStringFromTextView:(NSString *)text {
    self.subProject.projectDescription = text;
}

#pragma mark - AXNumbersTextFieldTableViewCellProtocol

- (void)donePressed {
    [self dismissKeyboard];
}

@end
