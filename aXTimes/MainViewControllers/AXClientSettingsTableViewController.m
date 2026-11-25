//
//  AXClientSettingsTableViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 04/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXClientSettingsTableViewController.h"

#import "AXEditCustomerTableViewController.h"

static NSString *ColorCellString = @"ColorLeftSideTableViewCell";

@interface AXClientSettingsTableViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation AXClientSettingsTableViewController
@synthesize fetchedResultsController = __fetchedResultsController;

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLS_CLIENTS;
    
    UIBarButtonItem *addButton;
    
    addButton= [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                target:self
                action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    UINib *colorCellNib;
    
    colorCellNib = [UINib nibWithNibName:ColorCellString
                                  bundle:nil];
    [self.tableView registerNib:colorCellNib
         forCellReuseIdentifier:ColorCellString];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.fetchedResultsController sections] == nil) {
        [tableView setupHintViewWithText:NSLS_ADD_CLIENTS_HINT];
        return 0;
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    if ([sectionInfo numberOfObjects] == 0) {
        [tableView setupHintViewWithText:NSLS_ADD_CLIENTS_HINT];
    } else {
        [tableView resetHintView];
    }
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ColorLeftSideTableViewCell *colorCell;
    colorCell = [tableView
                 dequeueReusableCellWithIdentifier:ColorCellString
                 forIndexPath:indexPath];
    
    [self configureCell:colorCell
            atIndexPath:indexPath];
    
    return colorCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.editing) {
        Customer *selectedObject = [[self fetchedResultsController] objectAtIndexPath:(NSIndexPath *)indexPath];
        
        DisplayClientTableViewController *displayClientTableViewController;
        
        displayClientTableViewController = [DisplayClientTableViewController new];
        displayClientTableViewController.customer = selectedObject;
        
        [self.navigationController
         pushViewController:displayClientTableViewController
         animated:YES];
    }
}

#pragma mark - private methods

- (void)insertNewObject {
    UINavigationController *navigationController;
    AXEditCustomerTableViewController *aXEditCustomerTableViewController;
        
    aXEditCustomerTableViewController = [AXEditCustomerTableViewController new];
    aXEditCustomerTableViewController.customer = nil;
    aXEditCustomerTableViewController.newCustomer = YES;
    
    navigationController = [[UINavigationController alloc]
                            initWithRootViewController:aXEditCustomerTableViewController];
    navigationController.extendedLayoutIncludesOpaqueBars = YES;
    
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

- (void)configureCell:(ColorLeftSideTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Customer *customer = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.customDetailTextLabel.text = @"";
    cell.customTextLabel.text = customer.displayName;
    cell.colorView.backgroundColor = [customer color];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    self.fetchedResultsController = [[AXDataStore sharedInstance] getAllActiveCustomers];
    self.fetchedResultsController.delegate = self;
    
    return __fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//	switch (type) {
//		case NSFetchedResultsChangeInsert :
//			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//			break;
//
//		case NSFetchedResultsChangeDelete :
//			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//			break;
//	}
//}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert :
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete :
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate :
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove :
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
