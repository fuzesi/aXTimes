//
//  AXEditCustomerTableViewController.h
//  aXTimes
//
//  Created by Christopher Füseschi on 04/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AXDefaultCommentViewController.h"

@class Customer;

@interface AXEditCustomerTableViewController : UITableViewController<UITextFieldDelegate, AXDefaultCommentViewControllerDelegate>

@property (strong, nonatomic) Customer *customer;
@property BOOL newCustomer;

@end
