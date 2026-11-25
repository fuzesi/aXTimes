//
//  AXDayEntryEditViewController.h
//  aXTimes
//
//  Created by Christopher Füseschi on 02/06/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXProjectCheckinSettingsViewController.h"
#import "AXNoteViewController.h"

@interface AXDayEntryEditViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, AXProjectCheckinSettingsViewControllerProtocol, AXNoteViewControllerProtocol>;

@property (strong, nonatomic) DayEntry *dayEntry;
@property BOOL newDayEntry;
@property (strong, nonatomic) NSDate *date;

@end
