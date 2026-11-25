//
//  AXProjectSettingsTableViewController.m
//  aXTimes
//
//  Created by fuesec on 10/6/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXProjectSettingsTableViewController.h"

#import "AXEditProjectTableViewController.h"

static NSString *ColorCellString = @"ColorProjectListTableViewCell";

@interface AXProjectSettingsTableViewController ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation AXProjectSettingsTableViewController
@synthesize fetchedResultsController = __fetchedResultsController;

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLS_PROJECTS;
    
    UIBarButtonItem *addButton;
    addButton= [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                target:self
                action:@selector(insertNewObject)];
    
    UINib *colorCellNib;
    
    colorCellNib = [UINib nibWithNibName:ColorCellString
                                  bundle:nil];
    [self.tableView registerNib:colorCellNib
         forCellReuseIdentifier:ColorCellString];
    
    self.navigationItem.rightBarButtonItems = @[addButton];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        [self.tableView setupHintViewWithText:NSLS_ADD_PROJECTS_HINT];
    } else {
        [self.tableView resetHintView];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.fetchedResultsController sections] == nil) {
        return 1;
    }
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([self.fetchedResultsController sections] == nil) {
		return 0;
	}

    NSInteger numberOfProjects = 0;
    NSArray<Project *> *projects = [self.fetchedResultsController fetchedObjects];
    if (section == 0) { // active section
        for (Project *project in projects) {
            if (project.isRunning) {
                numberOfProjects++;
            }
        }
    } else if (section == 1) { // inactive section
        for (Project *project in projects) {
            if (!project.isRunning) {
                numberOfProjects++;
            }
        }
    }

	return numberOfProjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ColorProjectListTableViewCell *colorCell;
    colorCell = [tableView
                 dequeueReusableCellWithIdentifier:ColorCellString
                 forIndexPath:indexPath];
    
    [self configureCell:colorCell
            atIndexPath:indexPath];
    
    return colorCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
//	return YES;
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[[AXDataStore sharedInstance] deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
//		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return @"";
    }
    if (section == 0) {
        return NSLS_ACTIVE;
    } else if (section == 1) {
        return NSLS_INACTIVE;
    }
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return @"";
    }
    if (section == 0) {
        return NSLS_ACTIVE_FOOTER;
    } else if (section == 1) {
        return NSLS_INACTIVE_FOOTER;
    }
    return @"";
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSUInteger fromIndex = fromIndexPath.row;
	NSUInteger toIndex = toIndexPath.row;
	Project *tempProject = [self.fetchedResultsController objectAtIndexPath:fromIndexPath];

	tempProject.position = [NSNumber numberWithInteger:toIndexPath.row];

	NSUInteger start, end;
	int delta;

	if (fromIndex < toIndex) {
		// move was down, need to shift up
		delta = -1;
		start = fromIndex + 1;
		end = toIndex;
	} else if (fromIndex == toIndex) {
		return;
	} else {
		// fromIndex > toIndex
		// move was up, need to shift down
		delta = 1;
		start = toIndex;
		end = fromIndex - 1;
	}

	for (NSUInteger i = start; i <= end; i++) {
		Project *tempProject2 =  [self.fetchedResultsController.fetchedObjects objectAtIndex:i];
		tempProject2.position = [NSNumber numberWithInteger:toIndexPath.row];

		NSNumber *oldPriority = (NSNumber *)tempProject.position;
		int tmp = [oldPriority intValue] + delta;
		NSNumber *newPriority = [NSNumber numberWithInt:tmp];
		tempProject2.position = [NSNumber numberWithInt:[newPriority intValue]];
	}
}

/*
 * // Override to support conditional rearranging of the table view.
 * - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  // Return NO if you do not want the item to be re-orderable.
 *  return YES;
 * }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSArray<Project *> *projects = [self.fetchedResultsController fetchedObjects];
    NSMutableArray<Project *> *projectsNeeded = [NSMutableArray new];
    if ([indexPath section] == 0) { // active section
        for (Project *project in projects) {
            if (project.isRunning) {
                [projectsNeeded addObject:project];
            }
        }
    } else if ([indexPath section] == 1) { // inactive section
        for (Project *project in projects) {
            if (!project.isRunning) {
                [projectsNeeded addObject:project];
            }
        }
    }

    NSInteger index = [indexPath row];
    Project *tempProject = [projectsNeeded objectAtIndex:index];

    if (!self.editing) {
        Project *selectedProject = tempProject;

        AXDisplayProjectTableViewController *displayProjectTableViewController = [AXDisplayProjectTableViewController new];
        displayProjectTableViewController.project = selectedProject;
        [self.navigationController pushViewController:displayProjectTableViewController animated:YES];
    }
}

#pragma mark - private methods

- (void)purchaseProduct {
    [self.navigationController popViewControllerAnimated:true];
    ProductsViewController *productsViewController;
    productsViewController = [[ProductsViewController alloc] init];
    [self.navigationController pushViewController:productsViewController
                                         animated:YES];
}

- (void)insertNewObject {
    if (![[IAPProducts store] isProductPurchased:[IAPProducts projects]] && [[AXDataStore sharedInstance] getAllProjects].fetchedObjects.count > 2) {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:NSLS_PREMIUMFEATURES
                                    message:NSLS_PREMIUMFEATURES_INFO
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *purchase = [UIAlertAction
                                   actionWithTitle:NSLS_PURCHASE_PRODUCT
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       [self purchaseProduct];
                                   }];

        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:NSLS_OKPOPUP
                             style:UIAlertActionStyleCancel
                             handler:nil];

        [alert addAction:purchase];
        [alert addAction:ok];

        [self presentViewController:alert
                           animated:YES
                         completion:nil];
        return;
    }
    AXEditProjectTableViewController *editProjectTableViewController;
    UINavigationController *navigationController;

    editProjectTableViewController = [AXEditProjectTableViewController new];
    editProjectTableViewController.project = nil;
    editProjectTableViewController.controllerTitle = NSLS_NEW_PROJECT;
    editProjectTableViewController.newProject = YES;
    
    navigationController = [[UINavigationController alloc]
                            initWithRootViewController:editProjectTableViewController];
    navigationController.extendedLayoutIncludesOpaqueBars = YES;

    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

- (void)configureCell:(ColorProjectListTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSArray<Project *> *projects = [self.fetchedResultsController fetchedObjects];
    NSMutableArray<Project *> *projectsNeeded = [NSMutableArray new];
    if ([indexPath section] == 0) { // active section
        for (Project *project in projects) {
            if (project.isRunning) {
                [projectsNeeded addObject:project];
            }
        }
    } else if ([indexPath section] == 1) { // inactive section
        for (Project *project in projects) {
            if (!project.isRunning) {
                [projectsNeeded addObject:project];
            }
        }
    }

    NSInteger index = [indexPath row];
	Project *tempProject = [projectsNeeded objectAtIndex:index];

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell setProject:tempProject];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
	if (__fetchedResultsController != nil) {
		return __fetchedResultsController;
	}

	self.fetchedResultsController = [[AXDataStore sharedInstance] getAllProjectsWithoutBasic];
	self.fetchedResultsController.delegate = self;

	return __fetchedResultsController;
}

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView beginUpdates];
//}

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

//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath {
//    UITableView *tableView = self.tableView;
//
//    switch (type) {
//        case NSFetchedResultsChangeInsert :
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//
//        case NSFetchedResultsChangeDelete :
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//
//        case NSFetchedResultsChangeUpdate :
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//        case NSFetchedResultsChangeMove :
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //    [self.tableView endUpdates];
    [self.tableView reloadData];
}
@end
