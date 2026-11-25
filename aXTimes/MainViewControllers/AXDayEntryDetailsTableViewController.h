//
//  AXDayEntryDetailsTableViewController.h
//  aXTimes
//
//  Created by Christopher Füseschi on 22/06/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXDayEntryDetailsTableViewController : UITableViewController
@property (strong, nonatomic) DayEntry *dayEntry;
- (void)copyEntry;
@end
