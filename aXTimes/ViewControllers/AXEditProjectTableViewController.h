//
//  AXEditProjectTableViewController.h
//  aXTimes
//
//  Created by fuesec on 10/7/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXTimeUnitSettingsTableViewController.h"
#import "AXRoundingSettingsTableViewController.h"

#import "AXDefaultCommentViewController.h"

#import "AXNumbersTextFieldTableViewCell.h"

@interface AXEditProjectTableViewController : UITableViewController<UITextFieldDelegate, AXTimeUnitSettingsTableViewControllerDelegate, AXRoundingSettingsTableViewControllerDelegate, AXDefaultCommentViewControllerDelegate, AXNumbersTextFieldTableViewCellProtocol>

@property (strong, nonatomic) Project *project;
@property (strong, nonatomic) NSString *controllerTitle;
@property BOOL newProject;

@end
