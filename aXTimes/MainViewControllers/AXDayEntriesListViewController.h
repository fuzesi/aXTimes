//
//  AXDayEntriesListViewController.h
//  aXTimes
//
//  Created by Christopher Füseschi on 01/06/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXDayEntriesListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIViewControllerPreviewingDelegate>

@property (strong, nonatomic) NSMutableArray<DayEntry *> *entries;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) DayType *dayType;
@property (nonatomic) BOOL working;
- (void)refresh;

@end
