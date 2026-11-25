//
//  AXRoundingSettingsTableViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 04/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXRoundingSettingsTableViewController.h"
#import "UITableView+Helper.h"

@interface AXRoundingSettingsTableViewController ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation AXRoundingSettingsTableViewController

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLS_ROUNDING;
    self.dataArray = ROUNDINGBEHAVIOURNAMES;
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
    
    NSString *roundingName = self.dataArray[indexPath.row];
    
    cell.textLabel.text = roundingName;
    
    if (self.initialValue == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView toggleCheckmark:indexPath];
        
    if ([self.delegate respondsToSelector:@selector(setSelectedRoundingBehaviour:)]) {
        [self.delegate setSelectedRoundingBehaviour:indexPath.row];
    }
}

@end
