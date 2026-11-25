//
//  AXGeneralSettingsTableViewController.h
//  aXTimes
//
//  Created by Christopher Füseschi on 03/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AXDefaultPauseTableViewController.h"
#import "AXNumbersTextFieldTableViewCell.h"
#import "AXDefaultCommentViewController.h"
#import "AXWorkingWeekTableViewController.h"

@interface AXGeneralSettingsTableViewController : UITableViewController<AXDefaultPauseTableViewControllerDelegate, AXNumbersTextFieldTableViewCellProtocol, AXDefaultCommentViewControllerDelegate, AXWorkingWeekTableViewControllerProtocol, UITextFieldDelegate>

@end
