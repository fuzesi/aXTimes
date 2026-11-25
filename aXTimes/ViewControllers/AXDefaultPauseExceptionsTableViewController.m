//
//  AXDefaultPauseExceptionsTableViewController.m
//  aXTimes
//
//  Created by fuesec on 04/10/15.
//  Copyright © 2015 aXimilate. All rights reserved.
//

#import "AXDefaultPauseExceptionsTableViewController.h"

@interface AXDefaultPauseExceptionsTableViewController ()
@property (nonatomic, strong) NSArray *weekdaySymbolsArray;
@property NSInteger selectedRow;
@end

@implementation AXDefaultPauseExceptionsTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDateFormatter *dayDateFormatter = [NSDateFormatter new];
    NSString *deviceLanguageLocaleString = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:deviceLanguageLocaleString];
    [dayDateFormatter setLocale:locale];
    self.weekdaySymbolsArray = [dayDateFormatter weekdaySymbols];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLS_RESET style:UIBarButtonItemStylePlain target:self action:@selector(reset)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
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
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";

    //http://stackoverflow.com/questions/12737860/assertion-failure-in-dequeuereusablecellwithidentifierforindexpath
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
    cell.textLabel.textColor = GLOBALFONTCOLOR;
    
    NSInteger position = fmod(indexPath.row + 1, 7); //TODO test this with different localizations!!!
    NSString *labelText = self.weekdaySymbolsArray[position];
    cell.textLabel.text = labelText;
    
    if ([[AXDataStore sharedInstance] defaultPauseSettingEntryForWeekDayIndex:indexPath.row]) {
        cell.detailTextLabel.text = NSLS_ON;
    } else {
        cell.detailTextLabel.text = NSLS_OFF;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRow = indexPath.row;
    
    DefaultPauseSetting *defaultPauseSetting = [[AXDataStore sharedInstance] defaultPauseSettingEntryForWeekDayIndex:indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];

    AXDefaultPauseTableViewController *defaultPauseTableViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AXDefaultPauseTableViewController class])];
    defaultPauseTableViewController.delegate = self;
    defaultPauseTableViewController.leftDetailLabelStringForSwitchCell = [NSString stringWithFormat:@"%@: %@", NSLS_DEFAULTPAUSE_SETTINGS, [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    
    if (defaultPauseSetting) {
        defaultPauseTableViewController.defaultPauseEnabledState = YES;
        defaultPauseTableViewController.defaultPauseStartDate = defaultPauseSetting.start;
        defaultPauseTableViewController.defaultPauseEndDate = defaultPauseSetting.end;
    } else {
        defaultPauseTableViewController.defaultPauseEnabledState = NO;
        defaultPauseTableViewController.defaultPauseStartDate = [[SettingsManager new] defaultPauseStart];
        defaultPauseTableViewController.defaultPauseEndDate = [[SettingsManager new] defaultPauseEnd];
    }
    
    [self.navigationController pushViewController:defaultPauseTableViewController animated:YES];
}

#pragma mark - AXDefaultPauseTableViewControllerDelegate
- (void)setDefaultPauseEnabled:(BOOL)enabled {
    DefaultPauseSetting *defaultPauseSetting = [[AXDataStore sharedInstance] defaultPauseSettingEntryForWeekDayIndex:self.selectedRow];

    if (enabled) {
        if (!defaultPauseSetting) { // else case should not happen
            defaultPauseSetting = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([DefaultPauseSetting class]) inManagedObjectContext:[AXDataStore sharedInstance].managedObjectContext];
            defaultPauseSetting.dayOfWeek = [NSNumber numberWithInteger:self.selectedRow];
        }
    } else {
        if (defaultPauseSetting) {
            [[AXDataStore sharedInstance] deleteObject:defaultPauseSetting];
        }
    }
}

- (void)setDefaultPauseStart:(NSDate *)start {
    DefaultPauseSetting *defaultPauseSetting = [[AXDataStore sharedInstance] defaultPauseSettingEntryForWeekDayIndex:self.selectedRow];
    defaultPauseSetting.start = start;
}

- (void)setDefaultPauseEnd:(NSDate *)end {
    DefaultPauseSetting *defaultPauseSetting = [[AXDataStore sharedInstance] defaultPauseSettingEntryForWeekDayIndex:self.selectedRow];
    defaultPauseSetting.end = end;
}

#pragma mark - private methods
- (void)reset {
    NSArray *settingEntities = [[AXDataStore sharedInstance] getAllManagedObjectsForClass:[DefaultPauseSetting class]];
    if (settingEntities) {
        for (DefaultPauseSetting *entity in settingEntities) {
            [[AXDataStore sharedInstance] deleteObject:entity];
        }
    }
    [self.tableView reloadData];
}


@end
