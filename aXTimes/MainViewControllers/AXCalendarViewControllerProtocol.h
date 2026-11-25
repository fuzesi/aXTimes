//
//  AXCalendarViewControllerProtocol.h
//  aXTimes
//
//  Created by fuesec on 5/8/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//


@protocol AXCalendarViewControllerProtocol <NSObject>

- (void)navigateForward:(BOOL)forward;
- (UITableView *)getNonActiveTableView;
- (NSLayoutConstraint *)getConstraint:(UITableView *)tableView;
- (void)goToToday;
@optional

- (void)showOptions;



@end
