//
//  AXDayEntriesListViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 01/06/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXDayEntriesListViewController.h"
#import "NSDate+AXNSDateCategory.h"
#import "NSDateFormatter+AXDateFormatters.h"
#import "PureLayout.h"

#import "AXDayEntryDetailsTableViewController.h"
#import "AXSummaryRegularTableViewCell.h"
#import "UIImage+AXUIImageCategory.h"

#import "AXUtility.h"


@interface AXDayEntriesListViewController ()
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation AXDayEntriesListViewController

#pragma mark - view lifecycle

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults]
     addObserver:self
     forKeyPath:@"settings_time_formatting"
     options:NSKeyValueObservingOptionNew
     context:NULL];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(maincontextDidSave:)
     name:NSManagedObjectContextDidSaveNotification
     object:[[AXDataStore sharedInstance] managedObjectContext]];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStyleGrouped];
    
    [self.view addSubview:self.tableView];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UINib *dayEntryNib = [UINib nibWithNibName:@"DayEntryTableViewCell" bundle:nil];
    [self.tableView registerNib:dayEntryNib forCellReuseIdentifier:@"DayEntryTableViewCell"];
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([AXSummaryRegularTableViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib
         forCellReuseIdentifier:@"SummaryRegularCell"];
    
    // fix for empty space at the top
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                              0.0f,
                                                                              self.tableView.bounds.size.width,
                                                                              CGFLOAT_MIN)];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqual:@"settings_time_formatting"]) {
        [self.tableView reloadData];
    }
}

- (void)maincontextDidSave:(NSNotification *)notification {
    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
//    NSLog(@"updatedObjects: %@", [updatedObjects description]);

    for (NSManagedObject *obj in updatedObjects) {
        if ([obj isKindOfClass:[Project class]]) {
            [self.tableView reloadData];
        }
    }
}

- (void)dealloc {
    [[NSUserDefaults standardUserDefaults]
     removeObserver:self
     forKeyPath:@"settings_time_formatting"];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSManagedObjectContextDidSaveNotification
     object:[[AXDataStore sharedInstance] managedObjectContext]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 1; //daytype
    if ([self.entries count] > 0) {
        numberOfSections += 1; // section for the entries
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        // entries
        return [self.entries count];
    } else {
        // day type
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
    }
    
    cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
    cell.textLabel.textColor = GLOBALFONTCOLOR;
    if (indexPath.section == 0) {
        AXSummaryRegularTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SummaryRegularCell" forIndexPath:indexPath];
        cell.customDetailTextLabel.text = @" ";
        if (self.dayType) {
            [cell.customImageView setImage:[self.dayType image]];
            cell.customTextLabel.text = [self.dayType title];
        } else if ([self working]){
            [cell.customImageView setImage:[DayType workImage]];
            cell.customTextLabel.text = NSLS_WORKDAY;
        } else {
            [cell.customImageView setImage:[DayType offImage]];
            cell.customTextLabel.text = NSLS_DAYOFF;
        }
        return cell;
    } else if (indexPath.section == 1) {
        
        DayEntryTableViewCell *dayEntryCell = [tableView dequeueReusableCellWithIdentifier:@"DayEntryTableViewCell" forIndexPath:indexPath];
        
        DayEntry *tempDayEntry = self.entries[indexPath.row];

        dayEntryCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        dayEntryCell.customTextLabel.text = [tempDayEntry
                                             timeRangeDisplayValueForTargetDate:self.date];
        dayEntryCell.colorView.backgroundColor = [tempDayEntry.project color];
        if ([tempDayEntry checkOutTime] != nil) {
            dayEntryCell.customDetailTextLabel.text = [tempDayEntry netHoursDisplayValue];
        } else {
            dayEntryCell.customDetailTextLabel.text = @"";
        }
        
        [dayEntryCell setCommentText:tempDayEntry.comment];
        dayEntryCell.projectTextLabel.text = [tempDayEntry.project displayName];
        return dayEntryCell;
    }

    return cell;
}

#pragma mark - tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        [self showDayTypeChooserAlert];
    } else if (indexPath.section == 1) {
        AXDayEntryDetailsTableViewController *aXDayEntryDetailsTableViewController;
        aXDayEntryDetailsTableViewController = [AXDayEntryDetailsTableViewController new];
        aXDayEntryDetailsTableViewController.dayEntry = self.entries[indexPath.row];
        
        [self.navigationController pushViewController:aXDayEntryDetailsTableViewController
                                             animated:YES];
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction
                                          rowActionWithStyle:UITableViewRowActionStyleDestructive
                                          title:NSLS_DELETE
                                          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                              [self deleteEntryAtIndexPath:indexPath];
                                          }];
    return @[deleteAction];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 1) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteEntryAtIndexPath:indexPath];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

#pragma mark - public methods

- (void)refresh {
    [self.tableView reloadData];
}

#pragma mark - private methods

- (void)deleteEntryAtIndexPath:(NSIndexPath *)indexPath {
    [[AXDataStore sharedInstance] deleteObject:self.entries[indexPath.row]];
    [self.entries removeObjectAtIndex:indexPath.row];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    if ([self.entries count] == 0) {
        [indexes addIndex:indexPath.section];
    }
    [self.tableView deleteSections:indexes
                  withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView endUpdates];
}

#pragma mark - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        if (indexPath.section == 1) {
            AXDayEntryDetailsTableViewController *aXDayEntryDetailsTableViewController;
            aXDayEntryDetailsTableViewController = [AXDayEntryDetailsTableViewController new];
            aXDayEntryDetailsTableViewController.dayEntry = self.entries[indexPath.row];
            previewingContext.sourceRect = cell.frame;
            return aXDayEntryDetailsTableViewController;
        }
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}

@end
