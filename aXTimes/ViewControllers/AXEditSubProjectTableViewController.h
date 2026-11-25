//
//  AXEditSubProjectTableViewController.h
//  aXTimes
//
//  Created by fuesec on 07/10/15.
//  Copyright © 2015 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXDefaultCommentViewController.h"
#import "AXNumbersTextFieldTableViewCell.h"

@interface AXEditSubProjectTableViewController : UITableViewController<UITextFieldDelegate, AXDefaultCommentViewControllerDelegate, AXNumbersTextFieldTableViewCellProtocol>

@property (strong, nonatomic) Project *parentProject;
@property (strong, nonatomic) Project *subProject;
@property (strong, nonatomic) NSString *controllerTitle;
@property BOOL newSubProject;

@end
