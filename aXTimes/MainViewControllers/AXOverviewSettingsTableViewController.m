//
//  AXOverviewSettingsTableViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 03/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXOverviewSettingsTableViewController.h"

#import "AXGeneralSettingsTableViewController.h"
#import "AXExportSettingsTableViewController.h"

#import "AXProjectSettingsTableViewController.h"
#import "AXClientSettingsTableViewController.h"


@interface AXOverviewSettingsTableViewController ()

@end

@implementation AXOverviewSettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLS_TABSETTINGS;

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
    self.tableView.sectionFooterHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionFooterHeight = 40;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // import old data only shown if app aximilate with correct version is installed
    // on the user's device and this might happen at runtime of axtimes pro
    [self.tableView reloadData];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_SHOWWELCOMEPOPUP]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SETTINGS_SHOWWELCOMEPOPUP];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLS_WELCOMETITLEALERT message:NSLS_WELCOMEMESSAGE preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLS_OKPOPUP style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 2;
    } else if (section == 2) {
        return 1;
    } else if (section == 3) {
        return 1;
    } else {
        // Support, sharing, and a direct App Store review link.
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ReuseIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:ReuseIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLS_GENERAL_SETTINGS;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLS_REPORT_SETTINGS;
        } else {
            cell.textLabel.text = NSLS_EXPORT_SETTINGS;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLS_CLIENTS;
        } else {
            cell.textLabel.text = NSLS_PROJECTS;
        }
    } else if (indexPath.section == 2) {
        cell.textLabel.text = NSLS_DATA_MANAGEMENT;
    } else if (indexPath.section == 3) {
        cell.textLabel.text = NSLS_PREMIUMFEATURES;
    } else {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLS_CONTACT_SUPPORT;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLS_TELLAFRIEND_CELL;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Rate %@", nil), APPLICATIONNAME];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }

    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            AXGeneralSettingsTableViewController *aXGeneralSettingsTableViewController = [AXGeneralSettingsTableViewController new];
            [self.navigationController pushViewController:aXGeneralSettingsTableViewController animated:YES];
        } else if (indexPath.row == 1) {
            ReportSettingsTableViewController *reportSettingsTableViewController = [ReportSettingsTableViewController new];
            [self.navigationController pushViewController:reportSettingsTableViewController animated:YES];
        } else {
            AXExportSettingsTableViewController *aXExportSettingsTableViewController = [AXExportSettingsTableViewController new];
            [self.navigationController pushViewController:aXExportSettingsTableViewController animated:YES];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            AXClientSettingsTableViewController *aXClientSettingsTableViewController = [AXClientSettingsTableViewController new];
            [self.navigationController pushViewController:aXClientSettingsTableViewController animated:YES];
        } else {
            AXProjectSettingsTableViewController *aXProjectSettingsTableViewController = [AXProjectSettingsTableViewController new];
            [self.navigationController pushViewController:aXProjectSettingsTableViewController animated:YES];
        }
    } else if (indexPath.section == 2) {
        DataManagementTableViewController *dataManagementTableViewController;
        dataManagementTableViewController = [[DataManagementTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        
        [self.navigationController pushViewController:dataManagementTableViewController
                                             animated:YES];
    } else if (indexPath.section == 3) {
        ProductsViewController *productsViewController;
        productsViewController = [[ProductsViewController alloc] init];

        [self.navigationController pushViewController:productsViewController
                                             animated:YES];
    } else {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SUPPORTSITE]];
        } else if (indexPath.row == 1) {
            NSString *appName = APPLICATIONNAME;
            NSURL *appStoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", APPID]];

            NSString *shareText = [NSString stringWithFormat:NSLS_TELLAFRIEND_TEXT, appName, appStoreURL];

            UIActivityViewController *controller;
            controller = [[UIActivityViewController alloc]
                          initWithActivityItems:@[shareText]
                          applicationActivities:nil];
            [self presentViewController:controller
                               animated:YES
                             completion:nil];
        } else if (indexPath.row == 2) {
            [[UIApplication sharedApplication] openURL:[AXOverviewSettingsTableViewController appReviewURL]
                                               options:@{}
                                     completionHandler:nil];
        }
    }
}

+ (NSURL *)appReviewURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://apps.apple.com/app/id%@?action=write-review", APPID]];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 4) {
        UIView *containerView = [UIView new];
        UILabel *label = [UILabel new];
        [containerView addSubview:label];
        label.font = [UIFont systemFontOfSize:11];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = [NSString stringWithFormat:@"%@\n%@", APPLICATIONFULLVERSION, BOTTOM_INFOSCREEN];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [label.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:20],
            [label.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor],
            [label.leftAnchor constraintEqualToAnchor:containerView.leftAnchor],
            [label.rightAnchor constraintEqualToAnchor:containerView.rightAnchor]
        ]];
        return containerView;
    }
    return nil;
}

@end
