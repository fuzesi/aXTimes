//
//  AXClientSelectionTableViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 21/06/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXClientSelectionTableViewController.h"
#import "UITableView+Helper.h"
#import "AXEditCustomerTableViewController.h"

@interface AXClientSelectionTableViewController ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation AXClientSelectionTableViewController
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
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(maincontextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[[AXDataStore sharedInstance] managedObjectContext]];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        if ([self.fetchedResultsController sections] == nil) {
            return 0;
        }
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        return [sectionInfo numberOfObjects];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = NSLS_NO_CLIENT;
        if (self.project.customer == nil) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    } else {
        [self configureCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView toggleCheckmark:indexPath];
    if (indexPath.section == 0 &&
        indexPath.row == 0) {
        [self.project setCustomer:nil];
    } else {
        Customer *tempObject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        [self.project setCustomer:tempObject];
    }
}

#pragma mark - private methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Customer *tempObject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    cell.detailTextLabel.textColor = GLOBALFONTCOLOR;
    cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([self.project.customer isEqual:tempObject]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    [cell.textLabel setText:tempObject.displayName];
}

- (void)insertNewObject {
    UINavigationController *navigationController;
    AXEditCustomerTableViewController *aXEditCustomerTableViewController;
    
    aXEditCustomerTableViewController = [AXEditCustomerTableViewController new];
    aXEditCustomerTableViewController.customer = nil;
    aXEditCustomerTableViewController.newCustomer = YES;
    
    navigationController = [[UINavigationController alloc]
                            initWithRootViewController:aXEditCustomerTableViewController];
    navigationController.extendedLayoutIncludesOpaqueBars = YES;
    [navigationController.navigationBar setTranslucent:YES];
    
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    self.fetchedResultsController = [[AXDataStore sharedInstance] getAllActiveCustomersWithContext:self.project.managedObjectContext];
    self.fetchedResultsController.delegate = self;
        
    return __fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert :
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:newIndexPath.row inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete :
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate :
            [self configureCell:[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:1]] atIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:1]];
            break;
        case NSFetchedResultsChangeMove :
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:newIndexPath.row inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)maincontextDidSave:(NSNotification *)notification {
    // fix for delays
    // http://stackoverflow.com/questions/28957936/nsfetchedresultscontroller-consistent-delay-in-updating-uitableview-cell-insert
    [self.project.managedObjectContext performBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.project.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        });
    }];
}

@end
