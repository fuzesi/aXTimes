//
//  AXEditCustomerTableViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 04/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXEditCustomerTableViewController.h"

#import "NSString+AXNSStringCategory.h"
#import "AXTextFieldTableViewCell.h"
#import "AXStandardTableViewCell.h"
#import "UIColor+AXUIColorCategory.h"
#import "RESideMenu.h"

static NSString *ColorCellString = @"ColorRightSideTableViewCell";
static NSString *StandardCellString = @"AXStandardTableViewCell";

@interface AXEditCustomerTableViewController ()

@property (strong, nonatomic) UIBarButtonItem *rightButton;

@property (strong, nonatomic) UITextField *activeKeyboardObject;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (strong, nonatomic) NSManagedObjectContext *childContext;
@property (nonatomic, strong) SettingsManager *settingsManager;

@end

@implementation AXEditCustomerTableViewController

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

    if (self.newCustomer) {
        self.title = NSLS_NEW_CLIENT;
    } else {
        self.title = NSLS_EDIT_CLIENT;
    }
    
    [self registerNibs];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    rightButton.enabled = NO;
    self.rightButton = rightButton;
    self.navigationItem.rightBarButtonItem = self.rightButton;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    self.childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    if (!self.newCustomer) {
        NSManagedObject *returnObject = [[AXDataStore sharedInstance] fetchObjectWithManagedObjectIDWithChildContext:[self.customer objectID] andContext:self.childContext];
        Customer *customerWithChildContext = (Customer *)returnObject;
        self.customer = customerWithChildContext;
    } else {
        [[AXDataStore sharedInstance] turnIntoChildContext:self.childContext];
        Customer *newCustomer = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Customer class]) inManagedObjectContext:self.childContext];

        newCustomer.active = @YES;
        newCustomer.code = @"";
        newCustomer.colourAsHex = [self.settingsManager colorForClient].hex;
        newCustomer.displayName = @"";
        newCustomer.notes = @"";
        newCustomer.email = @"";
        newCustomer.phone = @"";
        
        newCustomer.addressAddition = @"";
        newCustomer.addressCity = @"";
        newCustomer.addressCountry = @"";
        newCustomer.addressPostalCode = @"";
        newCustomer.addressState = @"";
        newCustomer.addressStreet = @"";
        newCustomer.addressStreetNumber = @"";

        self.customer = newCustomer;
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
    if (self.newCustomer) {
        return 3;
    } else {
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0: // title, code, color, description
            numberOfRows = 4;
            break;
        case 1: {// email, phone
            numberOfRows = 2;
            break;
            
        }
        case 2: // projects
            numberOfRows = 1;
            break;
        case 3: // in case we are in editing mode of an existing client we need a deletion row
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
    ColorRightSideTableViewCell *colorCell = nil;
    AXStandardTableViewCell *standardCell;
    
    if ((indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1)) ||
        (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1))) {
        
        textTableViewCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXTextFieldTableViewCell class]) forIndexPath:indexPath];
        //not always set to a value
        textTableViewCell.textField.text = @"";
        textTableViewCell.textField.placeholder = @"";
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        colorCell = [tableView
                     dequeueReusableCellWithIdentifier:ColorCellString
                     forIndexPath:indexPath];
        colorCell.customTextLabel.text = @"";
    } else if (indexPath.section == 0 && indexPath.row == 3) {
        standardCell = [tableView
                        dequeueReusableCellWithIdentifier:StandardCellString
                        forIndexPath:indexPath];
        standardCell.selectionStyle = UITableViewCellSelectionStyleDefault;
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
    
    switch (indexPath.section) {
        case 0 : {
            switch (indexPath.row) {
                case 0 : {
                    textTableViewCell.customTextLabel.text = NSLS_NAME;
                    textTableViewCell.textField.text = self.customer.displayName;
                    textTableViewCell.textField.placeholder = NSLS_REQUIRED;
                    // for some reason if delegate is not set here but more generally after the dequeue it will lead to crashes
                    textTableViewCell.textField.delegate = self;
                    [textTableViewCell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
                    return textTableViewCell;
                }
                case 1 : {
                    textTableViewCell.customTextLabel.text = NSLS_PROJECT_CODE;
                    textTableViewCell.textField.text = self.customer.code;
                    textTableViewCell.textField.delegate = self;
                    [textTableViewCell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
                    return textTableViewCell;
                }
                case 2 : {
                    colorCell.customTextLabel.text = NSLS_COLOUR;
                    colorCell.colorView.backgroundColor = [self.customer color];
                    colorCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return colorCell;
                }
                case 3 : {
                    standardCell.customTextLabel.text = NSLS_DESCRIPTION;
                    standardCell.customDetailTextLabel.text = self.customer.notes;
                    standardCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return standardCell;
                }
                default:
                    break;
            }
            break;
        }
        case 1 : {
            switch (indexPath.row) {
                case 0 : {
                    textTableViewCell.customTextLabel.text = NSLS_EMAIL;
                    textTableViewCell.textField.text = self.customer.email;
                    textTableViewCell.textField.delegate = self;
                    [textTableViewCell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
                    return textTableViewCell;
                }
                case 1 : {
                    textTableViewCell.customTextLabel.text = NSLS_PHONE;
                    textTableViewCell.textField.text = self.customer.phone;
                    textTableViewCell.textField.delegate = self;
                    [textTableViewCell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
                    return textTableViewCell;
                }
                default:
                    break;
            }
            break;
        }
        case 2 : {
            switch (indexPath.row) {
                case 0 : {
                    cell.textLabel.text = NSLS_PROJECTS;
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
                    cell.textLabel.text = NSLS_DELETE_CLIENT;
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
    switch (indexPath.section) {
        case 0 : {
            switch (indexPath.row) {
                case 2 : {
                    id<ColorPickerViewModelProtocol> viewModel;
                    id<CurrentColorProviderProtocol> provider;
                    ColorPickerViewController *controller;

                    provider = (id<CurrentColorProviderProtocol>) self.customer;
                    viewModel = [[ColorPickerViewModel alloc]
                                 initWithColors:[self.settingsManager colorPool]
                                 currentColorProvider:provider];
                    controller = [ColorPickerViewController new];
                    controller.viewModel = viewModel;
                    [self.navigationController pushViewController:controller animated:YES];
                    break;
                }
                case 3 : {
                    AXDefaultCommentViewController *defaultCommentViewController = [AXDefaultCommentViewController new];
                    defaultCommentViewController.delegate = self;
                    defaultCommentViewController.controllerTitle = NSLS_DESCRIPTION;
                    defaultCommentViewController.initialString = self.customer.notes;
                    [self.navigationController pushViewController:defaultCommentViewController animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1 :
            break;
        case 2 : {
            switch (indexPath.row) {
                case 0 : {
                    ClientProjectsTableViewController *controller = [ClientProjectsTableViewController new];
                    controller.client = self.customer;
                    [self.navigationController pushViewController:controller animated:YES];
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


#pragma mark - textfield and textview delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self saveTextFieldInput:textField];
    [self dismissKeyboard];
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
    if (![[self.customer managedObjectContext] save:&error]) {

    } else {
        [self.settingsManager advanceClientColorRotation];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)delete {
    [self.customer.managedObjectContext deleteObject:self.customer];
    NSError *error = nil;
    if (![[self.customer managedObjectContext] save:&error]) {
    
    } else { // try to pop if save was successful
        UINavigationController *navigationController;
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
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:NSLS_QUESTION_ALERTVIEW_TITLE
                                message:NSLS_DELETECLIENT_Q
                                preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *delete = [UIAlertAction
                             actionWithTitle:NSLS_DELETE_CLIENT
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
    
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

- (void)cancel {
    [self dismissKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tryToEnableDoneButton {
    self.rightButton.enabled = [self allowedToSave];
}

- (BOOL)allowedToSave {
    if (![self.customer.displayName isEqualToString:@""]) {
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
    //http://stackoverflow.com/questions/5732438/how-to-get-uitableviewcells-index-from-its-edited-uitextfield/18980944#18980944
    
    // Get the cell in which the textfield is embedded
    id superView = textField;
    while (![superView isKindOfClass:[UITableViewCell class]]) {
        superView = [superView superview];
    }
    
    // Get that cell's index path
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)superView];
    
    switch (indexPath.section) {
        case 0 : {
            switch (indexPath.row) {
                case 0 : {
                    self.customer.displayName = [textField.text trim];
                    break;
                }
                case 1 : {
                    self.customer.code = [textField.text trim];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1 : {
            switch (indexPath.row) {
                case 0 : {
                    self.customer.email = [textField.text trim];
                    break;
                }
                case 1 : {
                    self.customer.phone = [textField.text trim];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 2 : {
            break;
        }
        default:
            break;
    }
    [self tryToEnableDoneButton];
}

- (void)registerNibs {
    UINib *textTableViewCellNib = [UINib nibWithNibName:NSStringFromClass([AXTextFieldTableViewCell class]) bundle:nil];
    [self.tableView registerNib:textTableViewCellNib forCellReuseIdentifier:NSStringFromClass([AXTextFieldTableViewCell class])];
    UINib *colorCellNib = [UINib
                           nibWithNibName:ColorCellString
                           bundle:nil];
    [self.tableView registerNib:colorCellNib
         forCellReuseIdentifier:ColorCellString];
    UINib *standardCellNib = [UINib
                              nibWithNibName:StandardCellString
                              bundle:nil];
    [self.tableView registerNib:standardCellNib
         forCellReuseIdentifier:StandardCellString];
}

#pragma mark - AXDefaultCommentViewControllerDelegate

- (void)setStringFromTextView:(NSString *)text {
    self.customer.notes = text;
}

#pragma mark - AXProjectSelectionTableViewControllerDelegate

- (void)setSelectedProjects:(NSSet<Project *> *)projects {
    [self.customer removeProjects:self.customer.projects];
    [self.customer addProjects:projects];
}


@end
