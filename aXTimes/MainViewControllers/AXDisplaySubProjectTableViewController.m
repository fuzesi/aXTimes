//
//  AXDisplaySubProjectTableViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 12/08/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXDisplaySubProjectTableViewController.h"
#import "AXEditSubProjectTableViewController.h"
#import "AXStandardTableViewCell.h"
#import "NSDecimalNumber+AXNSDecimalNumberCategory.h"
#import "NSString+AXNSStringCategory.h"

@implementation AXDisplaySubProjectTableViewController

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLS_SUBPROJECT_DETAILS;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    UINib *standardNib = [UINib nibWithNibName:NSStringFromClass([AXStandardTableViewCell class]) bundle:nil];
    [self.tableView registerNib:standardNib forCellReuseIdentifier:NSStringFromClass([AXStandardTableViewCell class])];
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
    switch (section) {
        case 0:
            if ([self.subProject.parent.useSubProjectsBudget boolValue]) {
                return 5;
            }
            return 3;
        default:
            return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    static NSString *standardIdentifier = @"AXStandardTableViewCell";

    //http://stackoverflow.com/questions/12737860/assertion-failure-in-dequeuereusablecellwithidentifierforindexpath
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.detailTextLabel.textColor = GLOBALFONTCOLOR;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLS_NAME;
                    cell.detailTextLabel.text = self.subProject.name;
                    break;
                case 1:
                    cell.textLabel.text = NSLS_PROJECT_CODE;
                    cell.detailTextLabel.text = self.subProject.code;
                    break;
                case 2: {
                    AXStandardTableViewCell *standardCell = [tableView dequeueReusableCellWithIdentifier:standardIdentifier
                                                                                            forIndexPath:indexPath];
                    standardCell.customTextLabel.text = NSLS_DESCRIPTION;
                    standardCell.customDetailTextLabel.text = self.subProject.projectDescription;
                    return standardCell;
                }
                    break;
                case 3:
                    cell.textLabel.text = NSLS_PROJECT_BUDGET;
                    cell.detailTextLabel.text = [[self.subProject.budget stringValueNumberFormatted]
                                                 appendStringWithWhiteSpace:NSLS_DAYS];
                    break;
                case 4:
                    cell.textLabel.text = NSLS_REMAININGBUDGET;
                    cell.detailTextLabel.text = [self.subProject remainingBudgetDaysTotalDisplayValue];
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return nil;
        default:
            return nil;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            break;
        default:
            break;
    }
}

#pragma mark - private methods

- (void)edit {
    AXEditSubProjectTableViewController *editProjectTableViewController = [AXEditSubProjectTableViewController new];
    
    editProjectTableViewController.parentProject = self.subProject.parent;
    editProjectTableViewController.subProject = self.subProject;
    editProjectTableViewController.controllerTitle = NSLS_EDIT_SUBPROJECT;
    editProjectTableViewController.newSubProject = NO;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editProjectTableViewController];
    navigationController.extendedLayoutIncludesOpaqueBars = YES;
    
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

@end
