//
//  AXHourlyWageTableViewController.h
//  aXTimes
//
//  Created by fuesec on 5/26/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXNumbersTextFieldTableViewCell.h"

@interface AXHourlyWageViewController : UITableViewController<UITextFieldDelegate, AXNumbersTextFieldTableViewCellProtocol>
@property (strong, nonatomic) DayEntry *currentDayEntry;
@end
