//
//  AXLeftMenuViewController.m
//  RESideMenuStoryboards
//
//  Created by fuesec on 5/8/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXLeftMenuViewController.h"
#import "UIViewController+RESideMenu.h"
#import "UITableView+Helper.h"

#import "SKSTableViewCellMulti.h"
#import "SKSTableViewCell.h"
#import <PureLayout/PureLayout.h>

@interface AXLeftMenuViewController ()

@property (strong, readwrite, nonatomic) SKSTableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation AXLeftMenuViewController
@synthesize fetchedResultsController = __fetchedResultsController;

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLS_FILTER;
    
    self.tableView = ({
        SKSTableView *tableView = [[SKSTableView alloc] initWithFrame:CGRectMake(0,
                                                                                 0,
                                                                                 self.view.frame.size.width,
                                                                                 self.view.frame.size.height)
                                                                style:UITableViewStylePlain];
        // do not set the regular delegates otherwise the tableview will not work
        tableView.multiSelectPossible = YES;
        tableView.SKSTableViewDelegate = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView;
    });
    [self.view addSubview:self.tableView];
    [self.tableView autoPinEdgesToSuperviewEdges];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([SKSTableViewCellMulti class])
                                    bundle:nil];
    [self.tableView registerNib:cellNib
         forCellReuseIdentifier:NSStringFromClass([SKSTableViewCellMulti class])];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(contextDidSave:)
     name:NSManagedObjectContextDidSaveNotification
     object:[[AXDataStore sharedInstance] managedObjectContext]];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4; // All + Active + Inactive + None
    } else {
        if ([self.fetchedResultsController sections] == nil) {
            return 0;
        }
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        return [sectionInfo numberOfObjects];
    }

}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtSection:(NSInteger)section atRow:(NSInteger)row {
    if (section == 0) {
        return 0;
    } else {
        Project *tempProject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        
        return [tempProject.subProjects count];
    }
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubSubRowsAtSection:(NSInteger)section atRow:(NSInteger)row atSubRow:(NSInteger)subRow {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(SKSIndexPath *)indexPath {
//    DebugLog(@"section(%ld) row(%ld) subRow(%ld) subSubRow(%ld)",
//             (long)indexPath.section,
//             (long)indexPath.row,
    //             (long)indexPath.subRow,
    //             (long)indexPath.subSubRow);
    
    static NSString *CellIdentifier = @"SKSTableViewCellMulti";
    static NSString *SimpleCellIdentifier = @"SKSTableViewCell";
    SKSTableViewCellMulti *cell;
    SKSTableViewCell *simpleCell;
    
    if (indexPath.section == 0) {
        simpleCell = [tableView dequeueReusableCellWithIdentifier:SimpleCellIdentifier];
        if (!simpleCell) {
            simpleCell = [[SKSTableViewCell alloc]
                          initWithStyle:UITableViewCellStyleDefault
                          reuseIdentifier:SimpleCellIdentifier];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                               forIndexPath:indexPath.indexPath];
    }
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                simpleCell.textLabel.text = NSLS_ALL_Projects;
                break;
            case 1:
                simpleCell.textLabel.text = NSLS_ACTIVE;
                break;
            case 2:
                simpleCell.textLabel.text = NSLS_INACTIVE;
                break;
            case 3:
                simpleCell.textLabel.text = NSLS_FILTER_NONE;
                break;
            default:
                break;
        }
        simpleCell.expandable = NO;
        return simpleCell;
    } else {
        [self configureParentCell:cell atIndexPath:indexPath.indexPath];
    }
    
    return cell;
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(SKSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setBackgroundColor:GLOBALBACKGROUNDCOLOR2];

    Project *tempProject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    NSArray<Project *> *subProjects = [tempProject sortedSubProjects];
    Project *subProject = subProjects[indexPath.subRow - 1];
    cell.textLabel.text = subProject.name;
    
    if ([subProject.filterActive boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark - table view delegate methods

- (void)tableView:(SKSTableView *)tableView didSelectRowAtRealIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [self selectAll];
                break;
            case 1:
                [self selectActive];
                break;
            case 2:
                [self selectInactive];
                break;
            case 3:
                [self selectNone];
                break;
            default:
                break;
        }
    }
    
    if (indexPath.section == 1 &&
        [[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[SKSTableViewCellMulti class]]) {

        SKSTableViewCellMulti *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        SKSIndexPath *subrowIndexPath = [tableView correspondingIndexPathForRowAtIndexPath:indexPath];
        Project *tempProject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:subrowIndexPath.row inSection:0]];

        BOOL hasCheckmark = cell.accessoryType != UITableViewCellAccessoryCheckmark;
        [tempProject configureFilter:hasCheckmark];

        cell.accessoryType = hasCheckmark ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        if ([cell isExpanded]) {
            NSArray<NSIndexPath *> *indexPaths = [tableView subRowIndexPathsForParentIndexPath:indexPath];
            for (NSIndexPath *indexPath in indexPaths) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (hasCheckmark) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
    }
}

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtRealIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 &&
        [[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        SKSIndexPath *subrowIndexPath = [self.tableView correspondingIndexPathForRowAtIndexPath:indexPath];
        Project *parentProject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:subrowIndexPath.row inSection:0]];
        NSArray<Project *> *projects = [parentProject sortedSubProjects];
        Project *subProject = projects[subrowIndexPath.subRow - 1];
        
        BOOL checkmark = cell.accessoryType != UITableViewCellAccessoryCheckmark;
        
        [subProject configureFilter:checkmark];
        if (checkmark) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        UITableViewCell *parentCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - subrowIndexPath.subRow
                                                                                          inSection:indexPath.section]];
        if (checkmark || (!checkmark &&
             ![parentProject isFilterActiveForAtLeastOneSubProject])) {

            if (checkmark) {
                parentCell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                parentCell.accessoryType = UITableViewCellAccessoryNone;
            }
        }

        if (![parentProject isFilterActiveForAllSubProjects]) {
            [parentCell setTintColor:[UIColor lightGrayColor]];
        } else {
            [parentCell setTintColor:SELECTIONCOLOR];
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"Section: %d, Row:%d, Subrow:%d", indexPath.section, indexPath.row, indexPath.subRow);

}

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"Section: %d, Row:%d, Subrow:%d", indexPath.section, indexPath.row, indexPath.subRow);
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLS_OPTIONS;
    } else {
        return NSLS_PROJECTS;
    }
}

#pragma mark - private methods

- (void)configureParentCell:(SKSTableViewCellMulti *)cell atIndexPath:(NSIndexPath *)indexPath {
    Project *tempProject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    [cell setSecondaryColor:GLOBALBACKGROUNDCOLOR2];
    
    if (tempProject.isFilterActive) {
        [cell setTintColor:SELECTIONCOLOR];
    } else {
        [cell setTintColor:[UIColor lightGrayColor]];
    }
    cell.customTextLabel.text = [tempProject displayName];
    cell.colorView.backgroundColor = [tempProject color];
    if ([tempProject.subProjects count] > 0) {
        cell.expandable = YES;
    } else {
        cell.expandable = NO;
    }
    
    if ([tempProject.filterActive boolValue] ||
        [tempProject isFilterActiveForAtLeastOneSubProject]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)selectAll {
    NSArray<Project *> *projects = self.fetchedResultsController.fetchedObjects;
    for (Project *project in projects) {
        [project configureFilter:YES];
    }
}

- (void)selectActive {
    NSArray<Project *> *projects = self.fetchedResultsController.fetchedObjects;
    for (Project *project in projects) {
        if (project.isRunning) {
            [project configureFilter:YES];
        } else {
            [project configureFilter:NO];
        }
    }
}

- (void)selectInactive {
    NSArray<Project *> *projects = self.fetchedResultsController.fetchedObjects;
    for (Project *project in projects) {
        if (project.isRunning) {
            [project configureFilter:NO];
        } else {
            [project configureFilter:YES];
        }
    }
}

- (void)selectNone {
    NSArray<Project *> *projects = self.fetchedResultsController.fetchedObjects;
    for (Project *project in projects) {
        [project configureFilter:NO];
    }
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    self.fetchedResultsController = [[AXDataStore sharedInstance] getAllProjects];
    self.fetchedResultsController.delegate = self;
    
    return __fetchedResultsController;
}

#pragma mark - notification methods

- (void)contextDidSave:(NSNotification *)notification {
    NSSet *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    
    DebugLog(@"insertObjects: %@", [insertedObjects description]);
    DebugLog(@"deletedObjects: %@", [deletedObjects description]);
    DebugLog(@"updatedObjects: %@", [updatedObjects description]);
    
    BOOL refresh = NO;
    BOOL fullRefreshRequired = NO;
    
    for (NSManagedObject *object in insertedObjects) {
        if ([object isKindOfClass:[Project class]]) {
            refresh = YES;
            fullRefreshRequired = YES;
        }
    }
    
    if (!refresh) {
        for (NSManagedObject *object in deletedObjects) {
            if ([object isKindOfClass:[Project class]]) {
                refresh = YES;
                fullRefreshRequired = YES;
            }
        }
    }
    
    if (!refresh) {
        for (NSManagedObject *object in updatedObjects) {
            if ([object isKindOfClass:[Project class]]) {
                refresh = YES;
            }
        }
    }
    
    if (refresh) {
        if (fullRefreshRequired) {
            self.fetchedResultsController = nil;
            [self.tableView refreshData];
        } else {
            [self.tableView reloadData];
        }
    }
}

@end
