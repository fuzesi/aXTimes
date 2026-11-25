//
//  AXDecimalSeparatorTableViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 04/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXDecimalSeparatorTableViewController.h"
#import "UITableView+Helper.h"

@interface AXDecimalSeparatorTableViewController ()

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) SettingsManager *settingsManager;

@end

@implementation AXDecimalSeparatorTableViewController

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingsManager = [SettingsManager new];

    self.title = NSLS_DECIMALSEPARATOR_SETTINGS;
    self.dataArray = [self.settingsManager decimalSeparators];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ReuseIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:ReuseIdentifier];
    }
    
    NSString *decimalSeperator = self.dataArray[indexPath.row];
    
    if ([decimalSeperator isEqualToString:NULLSTRING]) {
        decimalSeperator = [NSString stringWithFormat:@"%@ (%@)", NSLS_SYSTEM, [[NSNumberFormatter new] decimalSeparator]];
    }
    
    cell.textLabel.text = decimalSeperator;
    
    if ([self.dataArray[indexPath.row] isEqualToString:[self.settingsManager exportDecimalSeparator]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView toggleCheckmark:indexPath];
    
    [self.settingsManager setExportDecimalSeparator:self.dataArray[indexPath.row]];
}

@end
