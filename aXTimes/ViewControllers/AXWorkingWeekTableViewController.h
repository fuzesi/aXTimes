//
//  AXWorkingWeekTableViewController.h
//  aXTimes
//
//  Created by fuesec on 2/16/14.
//  Copyright (c) 2014 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AXWorkingWeekTableViewControllerProtocol <NSObject>
- (void)trySaveWorkWeekSetting:(NSMutableArray *)settingsWorkingweek;
@end


@interface AXWorkingWeekTableViewController : UITableViewController
@property (strong, nonatomic) id<AXWorkingWeekTableViewControllerProtocol> delegate;
@end
