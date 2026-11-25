//
//  AXWorkingWeekTableViewController.m
//  aXTimes
//
//  Created by fuesec on 2/16/14.
//  Copyright (c) 2014 aXimilate. All rights reserved.
//

#import "AXWorkingWeekTableViewController.h"
#import "UITableView+Helper.h"

@interface AXWorkingWeekTableViewController ()
@property (nonatomic, strong) NSDateFormatter *dayDateFormatter;
@property (nonatomic, strong) NSDateComponents *dateComponents;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSArray *weekdaySymbolsArray;
@property (nonatomic, strong) SettingsManager *settingsController;
@property (nonatomic, strong) NSMutableArray *settingsWorkingweek;
@end

@implementation AXWorkingWeekTableViewController

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.settingsController = [SettingsManager new];
	self.title = NSLS_WORKINGWEEK;
	self.dayDateFormatter = [NSDateFormatter new];
	NSString *deviceLanguageLocaleString = [[NSLocale preferredLanguages] objectAtIndex:0];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:deviceLanguageLocaleString];
	[self.dayDateFormatter setLocale:locale];
	self.weekdaySymbolsArray = [self.dayDateFormatter weekdaySymbols];
	self.settingsWorkingweek = [NSMutableArray arrayWithArray:[[SettingsManager new] workingWeek]];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;

    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.delegate respondsToSelector:@selector(trySaveWorkWeekSetting:)]) {
        [self.delegate trySaveWorkWeekSetting:self.settingsWorkingweek];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
	cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
	cell.textLabel.textColor = GLOBALFONTCOLOR;

	NSInteger position = fmod(indexPath.row + 1, 7);
	NSString *labelText = self.weekdaySymbolsArray[position];
	cell.textLabel.text = labelText;
	NSNumber *weekdayValue = ((NSNumber *)self.settingsWorkingweek[indexPath.row]);
	if ([weekdayValue boolValue] == NO) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

	if (cell.accessoryType == UITableViewCellAccessoryNone) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		self.settingsWorkingweek[indexPath.row] = [NSNumber numberWithBool:YES];
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		self.settingsWorkingweek[indexPath.row] = [NSNumber numberWithBool:NO];
	}

	[tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return NSLS_SETTINGS_WORKINGWEEK_FOOTER;
}

@end
