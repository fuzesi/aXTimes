//
//  AXProjectsSummaryTableViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 31/10/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXProjectsSummaryViewController.h"
#import "PureLayout.h"
#import "NSNumber+AXNSNumberCategory.h"
#import "NSString+AXNSStringCategory.h"

static NSString *projectSummaryCellString = @"ProjectSummaryTableViewCell";
static NSString *projectSummarySubCellString = @"ProjectSummarySubTableViewCell";

@interface AXProjectsSummaryViewController ()

@property (strong, readwrite, nonatomic) SKSTableView *tableView;

@end

@implementation AXProjectsSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[SKSTableView alloc] initWithFrame:CGRectZero
                                                   style:UITableViewStyleGrouped];

    [self.view addSubview:self.tableView];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    self.tableView.SKSTableViewDelegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // fix for empty space at the top
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, CGFLOAT_MIN)];
    UINib *projectSummaryCellNib = [UINib nibWithNibName:projectSummaryCellString bundle:nil];
    [self.tableView registerNib:projectSummaryCellNib
         forCellReuseIdentifier:projectSummaryCellString];
    UINib *projectSummarySubCellNib = [UINib nibWithNibName:projectSummarySubCellString bundle:nil];
    [self.tableView registerNib:projectSummarySubCellNib
         forCellReuseIdentifier:projectSummarySubCellString];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfProjects];
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtSection:(NSInteger)section atRow:(NSInteger)row {
    if ([self.fetchedResultsController sections] == nil) {
        return 0;
    }
    Project *tempProject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    
    return [[tempProject sortedSubProjectsWithFilterActivated] count];
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubSubRowsAtSection:(NSInteger)section atRow:(NSInteger)row atSubRow:(NSInteger)subRow {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(SKSIndexPath *)indexPath {
    ProjectSummaryTableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:projectSummaryCellString
                                           forIndexPath:indexPath.indexPath];
    [cell setSecondaryColor:GLOBALBACKGROUNDCOLOR2];
    cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
    NSIndexPath *fetchIndexPath = [NSIndexPath indexPathForRow:indexPath.row
                                                     inSection:0];
    Project *parentProject = [self.fetchedResultsController objectAtIndexPath:fetchIndexPath];

    if ([[parentProject sortedSubProjectsWithFilterActivated] count] > 0) {
        [cell setExpandable:YES];
    } else {
        [cell setExpandable:NO];
    }
    
    [cell setProject:parentProject isProjectSubproject:NO];
    
    return cell;
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubSubRowsOfCellAtSection:(NSInteger)section atRow:(NSInteger)row atSubRow:(NSInteger)subRow {
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(SKSIndexPath *)indexPath {
    /*
    ProjectSummaryTableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:projectSummaryCellString
                                           forIndexPath:indexPath.indexPath];
    cell.backgroundColor = GLOBALBACKGROUNDCOLOR2;
    NSIndexPath *fetchIndexPath = [NSIndexPath indexPathForRow:indexPath.row
                                                     inSection:0];
    Project *parentProject = [self.fetchedResultsController objectAtIndexPath:fetchIndexPath];
    NSArray<Project *> *subProjects = [parentProject sortedSubProjectsWithFilterActivated];
    Project *subProject = subProjects[indexPath.subRow - 1];
    
    [cell setExpandable:NO];

    [cell setProject:subProject isProjectSubproject:YES];
    
    return cell;
     */
    ProjectSummarySubTableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:projectSummarySubCellString
                                           forIndexPath:indexPath.indexPath];
    cell.backgroundColor = GLOBALBACKGROUNDCOLOR2;
    NSIndexPath *fetchIndexPath = [NSIndexPath indexPathForRow:indexPath.row
                                                     inSection:0];
    Project *parentProject = [self.fetchedResultsController objectAtIndexPath:fetchIndexPath];
    NSArray<Project *> *subProjects = [parentProject sortedSubProjectsWithFilterActivated];
    Project *subProject = subProjects[indexPath.subRow - 1];
    
    [cell setExpandable:NO];
    
    [cell setProject:subProject];
    
    return cell;
    
}

#pragma mark - private methods

- (NSUInteger)numberOfProjects {
    if ([self.fetchedResultsController sections] == nil) {
        return 0;
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

#pragma mark - public methods

- (void)reload {
    [self.tableView refreshData];
}


@end
