//
//  AXTimeUnitSettingsTableViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 03/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXTimeUnitSettingsTableViewController.h"
#import "UITableView+Helper.h"

@interface AXTimeUnitSettingsTableViewController ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation AXTimeUnitSettingsTableViewController

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLS_TIME_UNIT;
    self.dataArray = WORKTIMEUNITS;
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
    
    NSNumber *timeUnit = self.dataArray[indexPath.row];
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    NSString *displayString = [NSString stringWithFormat:@"%@ %@",
                               [numberFormatter stringFromNumber:timeUnit],
                               NSLS_MINUTE_SHORT];
    
    cell.textLabel.text = displayString;
    
    if (self.initialValue == [self.dataArray[indexPath.row] unsignedIntegerValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView toggleCheckmark:indexPath];

    if ([self.delegate respondsToSelector:@selector(setSelectedTimeUnit:)]) {
        [self.delegate setSelectedTimeUnit:[self.dataArray[indexPath.row] unsignedIntegerValue]];
    }
}

@end
