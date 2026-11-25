//
//  AXProjectCheckinSettingsViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 30/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXProjectCheckinSettingsViewController.h"

#import "SKSTableViewCell.h"
#import "UITableView+Helper.h"

#import "PureLayout.h"

static NSString *ColorCellString = @"ColorSimpleProjectListTableViewCell";

@interface AXProjectCheckinSettingsViewController ()
@property (strong, readwrite, nonatomic) SKSTableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property BOOL madeChanges;
@property (strong, nonatomic) Project *selectedProject;
@property (nonatomic, strong) SettingsManager *settingsManager;
@end

@implementation AXProjectCheckinSettingsViewController
@synthesize fetchedResultsController = __fetchedResultsController;

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingsManager = [SettingsManager new];

    self.title = self.controllerTitle;
    
    self.tableView = ({
        SKSTableView *tableView = [[SKSTableView alloc] initWithFrame:CGRectZero
                                                                style:UITableViewStyleGrouped];
        // do not set the regular delegates otherwise the tableview will not work
        tableView.SKSTableViewDelegate = self;
        tableView;
    });
    [self.view addSubview:self.tableView];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    
    if (self.isShowCancelAndDone) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:self.doneButtonTitle
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(done)];
        self.navigationItem.rightBarButtonItem = rightButton;
        
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                    target:self
                                                                                    action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = leftButton;
        self.madeChanges = NO;
    }
    
    UINib *colorCellNib;
    
    colorCellNib = [UINib nibWithNibName:ColorCellString
                                  bundle:nil];
    [self.tableView registerNib:colorCellNib
         forCellReuseIdentifier:ColorCellString];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
    [self.settingsManager defaultProjectCheck];
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if ((self.projectSelectionDelegate || self.checkInOnProjectDelegate) ||
            self.isOldDataImport) {
            return 1;
        } else {
            return 2;
        }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    ColorSimpleProjectListTableViewCell *colorCell;
    SKSTableViewCell *cell;
    
    if (indexPath.section == 1) {
        colorCell = [tableView
                     dequeueReusableCellWithIdentifier:ColorCellString
                     forIndexPath:indexPath];
        [colorCell setSecondaryColor:GLOBALBACKGROUNDCOLOR2];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[SKSTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:CellIdentifier];
        }
        [cell setSecondaryColor:GLOBALBACKGROUNDCOLOR2];
    }
    
    if (indexPath.section == 0) {
        cell.expandable = NO;
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLS_SETTINGS_DEFAULTPROJECT_NOPROJECT;
            if (self.projectSelectionDelegate) {
                if ([self.projectSelectionDelegate relevantProject] == nil ||
                    [[self.projectSelectionDelegate relevantProject].objectID isEqual:[[AXDataStore sharedInstance] getBasicProject].objectID]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else if (self.checkInOnProjectDelegate || self.isOldDataImport) {
                if (!self.madeChanges) {
                    if ([self.settingsManager isCheckinSettingNoProject]) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                } else {
                    if (self.selectedProject == nil ||
                        [self.selectedProject.objectID isEqual:[[AXDataStore sharedInstance] getBasicProject].objectID]) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                }
            } else {
                if ([self.settingsManager isCheckinSettingNoProject]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        } else {
            cell.textLabel.text = NSLS_SETTINGS_DEFAULTPROJECT_LASTPROJECT;
            if ([self.settingsManager isCheckinSettingLastProject]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else {
        Project *tempProject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        
        colorCell.customTextLabel.text = tempProject.name;
        colorCell.colorView.backgroundColor = [tempProject color];
        
        if ([tempProject.subProjects count] > 0) {
            colorCell.expandable = YES;
            colorCell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            colorCell.expandable = NO;
            if (self.projectSelectionDelegate) {
                if ([tempProject isEqual:[self.projectSelectionDelegate relevantProject]]) {
                    colorCell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    colorCell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else if (self.checkInOnProjectDelegate || self.isOldDataImport) {
                if (!self.madeChanges) {
                    if ([self.settingsManager isCheckinSettingLastProject]) {
                        if ([tempProject isEqual:[[AXDataStore sharedInstance] lastProjectCheckedInOn]]) {
                            colorCell.accessoryType = UITableViewCellAccessoryCheckmark;
                        } else {
                            colorCell.accessoryType = UITableViewCellAccessoryNone;
                        }
                    } else {
                        if ([tempProject.defaultProject boolValue]) {
                            colorCell.accessoryType = UITableViewCellAccessoryCheckmark;
                        } else {
                            colorCell.accessoryType = UITableViewCellAccessoryNone;
                        }
                    }
                } else {
                    if ([tempProject isEqual:self.selectedProject]) {
                        colorCell.accessoryType = UITableViewCellAccessoryCheckmark;
                    } else {
                        colorCell.accessoryType = UITableViewCellAccessoryNone;
                    }
                }
            } else {
                if ([tempProject.defaultProject boolValue]) {
                    colorCell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    colorCell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
        return colorCell;
    }
    
//    [cell removeIndicatorView];
    //TODO check if really necessary
    
    return cell;
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        Project *tempProject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        
        NSArray<Project *> *subProjects = [tempProject.subProjects allObjects];
        if ([subProjects count] > 0) {            
            if (self.projectSelectionDelegate) {
                for (Project *item in subProjects) {
                    if ([item isEqual:[self.projectSelectionDelegate relevantProject]]) {
                        return YES;
                    }
                }
            } else if (self.checkInOnProjectDelegate || self.isOldDataImport) {
                if (!self.madeChanges) {
                    for (Project *item in subProjects) {
                        if ([item.defaultProject boolValue]) {
                            return YES;
                        }
                    }
                } else {
                    for (Project *item in subProjects) {
                        if ([item isEqual:self.selectedProject]) {
                            return YES;
                        }
                    }
                }
            } else {
                for (Project *item in subProjects) {
                    if ([item.defaultProject boolValue]) {
                        return YES;
                    }
                }
            }
        }
    }
    
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(SKSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    [cell setBackgroundColor:GLOBALBACKGROUNDCOLOR2];

    Project *tempProject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    NSArray<Project *> *subProjects = [tempProject sortedSubProjects];
    Project *subProject = subProjects[indexPath.subRow - 1];
    [self configureCell:cell withProject:subProject];
    
    return cell;
}

#pragma mark - table view delegate methods

- (void)tableView:(SKSTableView *)tableView didSelectRowAtRealIndexPath:(NSIndexPath *)indexPath{
    if ([[tableView cellForRowAtIndexPath:indexPath] conformsToProtocol:@protocol(SKSTableViewCellProtocol)]) {
        UITableViewCell<SKSTableViewCellProtocol> *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (![cell isExpandable]) {
            if([tableView toggleCheckmark:indexPath]) {
                self.madeChanges = YES;
                if (self.isOldDataImport) {
                    self.selectedProject = [self getSelectedProject];
                } else {
                    self.selectedProject = [self saveSettings];
                }
            }
        }
    }
}

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtRealIndexPath:(NSIndexPath *)indexPath{
    if([tableView toggleCheckmark:indexPath]) {
        self.madeChanges = YES;
        if (self.isOldDataImport) {
            self.selectedProject = [self getSelectedProject];
        } else {
            self.selectedProject = [self saveSettings];
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
//    [tableView toggleCheckmark:[NSIndexPath indexPathForRow:indexPath.row + indexPath.subRow inSection:indexPath.section]];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    // wenn die letzten zwei bedingungen wahr sind bedeutet das,
    // dass dieser kontroller für die settings hergenommen wird
    // und wir den Erklärungstext sehen wollen
    if (self.firstSectionFooterTitle &&
        section == [tableView numberOfSections] - 1) {
        return self.firstSectionFooterTitle;
    }

    return @"";
}

#pragma mark - private methods

- (void)configureCell:(UITableViewCell *)cell withProject:(Project *)project {
    cell.textLabel.text = project.name;
    if (self.projectSelectionDelegate) {
        if ([project isEqual:[self.projectSelectionDelegate relevantProject]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (self.checkInOnProjectDelegate || self.isOldDataImport) {
        if (!self.madeChanges) {
            if ([self.settingsManager isCheckinSettingLastProject]) {
                if ([project isEqual:[[AXDataStore sharedInstance] lastProjectCheckedInOn]]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else {
                if ([project.defaultProject boolValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        } else {
            if ([project isEqual:self.selectedProject]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else {
        if ([project.defaultProject boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Project *tempProject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.detailTextLabel.textColor = GLOBALFONTCOLOR;
    cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    cell.detailTextLabel.text = @"";
    [cell.textLabel setText:tempProject.name];
}

- (Project *)saveSettings {
    Project *selectedProject = nil;
    NSIndexPath *realIndexPath;
    BOOL done = NO;
    
    for (int section = 0; section < [self.tableView numberOfSections]; section++) {
        if (done) {
            break;
        }
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            realIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:realIndexPath];
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                done = YES;
                break;
            }
        }
    }
    
    if (realIndexPath.section == 0) {
        if (realIndexPath.row == 0) {
            if (self.projectSelectionDelegate ||
                self.checkInOnProjectDelegate) {
                Project *basicProject = [[AXDataStore sharedInstance] getBasicProjectWithContext:self.childContext];
                [self.projectSelectionDelegate projectSelectionChanged:basicProject];
                selectedProject = basicProject;
            } else {
                [self.settingsManager setIsCheckinSettingNoProject:YES];
                [self.settingsManager setIsCheckinSettingLastProject:NO];
                Project *project = [[AXDataStore sharedInstance] getBasicProjectWithContext:self.childContext];
                project.defaultProject = @YES;
                for (Project *item in self.fetchedResultsController.fetchedObjects) {
                    item.defaultProject = @NO;
                    NSArray<Project *> *subProjects = [item.subProjects allObjects];
                    if ([subProjects count] > 0) {
                        for (Project *item in subProjects) {
                            item.defaultProject = @NO;
                        }
                    }
                }
            }
        } else {
            // last project wird für
            // self.projectSelectionDelegate || self.checkInOnProjectDelegate
            // nicht angezeigt
            [self.settingsManager setIsCheckinSettingNoProject:NO];
            [self.settingsManager setIsCheckinSettingLastProject:YES];
            Project *project = [[AXDataStore sharedInstance] getBasicProjectWithContext:self.childContext];
            project.defaultProject = @NO;
            for (Project *item in self.fetchedResultsController.fetchedObjects) {
                item.defaultProject = @NO;
                NSArray<Project *> *subProjects = [item.subProjects allObjects];
                if ([subProjects count] > 0) {
                    for (Project *item in subProjects) {
                        item.defaultProject = @NO;
                    }
                }
            }
        }
    } else {
        SKSIndexPath *subrowIndexPath = [self.tableView correspondingIndexPathForRowAtIndexPath:realIndexPath];
        Project *tempProject = [self.fetchedResultsController
                                objectAtIndexPath:[NSIndexPath
                                                   indexPathForRow:subrowIndexPath.row
                                                   inSection:0]];
        
        NSArray<Project *> *projects = [tempProject sortedSubProjects];
        
        Project *projectInQuestion;
        
        if ([projects count] > 0) {
            projectInQuestion = projects[subrowIndexPath.subRow - 1];
        } else {
            projectInQuestion = tempProject;
        }
        
        if (self.projectSelectionDelegate ||
            self.checkInOnProjectDelegate) {
            [self.projectSelectionDelegate projectSelectionChanged:projectInQuestion];
            selectedProject = projectInQuestion;
        } else {
            Project *basicProject = [[AXDataStore sharedInstance] getBasicProjectWithContext:self.childContext];
            basicProject.defaultProject = @NO;
            [self.settingsManager setIsCheckinSettingNoProject:NO];
            [self.settingsManager setIsCheckinSettingLastProject:NO];
            for (Project *item in self.fetchedResultsController.fetchedObjects) {
                if ([item isEqual:projectInQuestion]) {
                    item.defaultProject = @YES;
                } else {
                    item.defaultProject = @NO;
                }
                NSArray<Project *> *subProjects = [item.subProjects allObjects];
                if ([subProjects count] > 0) {
                    for (Project *item in subProjects) {
                        if ([item isEqual:projectInQuestion]) {
                            item.defaultProject = @YES;
                        } else {
                            item.defaultProject = @NO;
                        }
                    }
                }
            }
        }
    }
    
    return selectedProject;
}

- (Project *)getSelectedProject {
    Project *selectedProject = nil;
    NSIndexPath *realIndexPath;
    BOOL done = NO;

    for (int section = 0; section < [self.tableView numberOfSections]; section++) {
        if (done) {
            break;
        }
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            realIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:realIndexPath];
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                done = YES;
                break;
            }
        }
    }

    if (realIndexPath.section == 0) {
        if (realIndexPath.row == 0) {
            Project *basicProject = [[AXDataStore sharedInstance] getBasicProjectWithContext:self.childContext];
            selectedProject = basicProject;
        }
    } else {
        SKSIndexPath *subrowIndexPath = [self.tableView correspondingIndexPathForRowAtIndexPath:realIndexPath];
        Project *tempProject = [self.fetchedResultsController
                                objectAtIndexPath:[NSIndexPath
                                                   indexPathForRow:subrowIndexPath.row
                                                   inSection:0]];

        NSArray<Project *> *projects = [tempProject sortedSubProjects];

        Project *projectInQuestion;

        if ([projects count] > 0) {
            projectInQuestion = projects[subrowIndexPath.subRow - 1];
        } else {
            projectInQuestion = tempProject;
        }
        selectedProject = projectInQuestion;
    }

    return selectedProject;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    if (self.projectSelectionDelegate) {
        self.fetchedResultsController = [[AXDataStore sharedInstance]
                                         runningProjects:self.childContext
                                         withinStart:[self.projectSelectionDelegate projectStart]
                                         andEnd:[self.projectSelectionDelegate projectEnd]];
    } else if (self.isOldDataImport) {
        self.fetchedResultsController = [[AXDataStore sharedInstance]
                                         getAllActiveProjectsWithContext:self.childContext];
    } else {
        self.fetchedResultsController = [[AXDataStore sharedInstance]
                                         runningProjects:self.childContext
                                         withinStart:nil
                                         andEnd:nil];
    }
    
    self.fetchedResultsController.delegate = self;

    return __fetchedResultsController;
}

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView beginUpdates];
//}
//
////- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
////		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
////	switch (type) {
////		case NSFetchedResultsChangeInsert :
////			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
////			break;
////
////		case NSFetchedResultsChangeDelete :
////			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
////			break;
////	}
////}
//
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

#pragma mark - bar button methods

- (void)done {
    if (self.checkInOnProjectDelegate) {
        [self.checkInOnProjectDelegate triggerCheckInOnProject:[self saveSettings]];
    }
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 if (self.selectedProjectBlock) {
                                     self.selectedProjectBlock([self getSelectedProject]);
                                 }
                             }];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
