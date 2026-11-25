//
//  AXPauseTableViewController.h
//  aXTimes
//
//  Created by fuesec on 5/19/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//


@interface AXPauseViewController : UITableViewController
@property (strong, nonatomic) Pause *currentPause;
@property (strong, nonatomic) DayEntry *currentDayEntry;
@property BOOL newPause;

@end
