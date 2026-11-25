//
//  AXPauseTableViewController.h
//  aXTimes
//
//  Created by fuesec on 5/19/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//


@interface AXMigrationController : UITableViewController
typedef void (^selectedEntries_t)(NSArray<DayEntry *> * _Nonnull selectedEntries);
@property (nonatomic, strong) selectedEntries_t _Nullable selectedEntriesBlock;

@end
