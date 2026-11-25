//
//  AXDefaultPauseTableViewController.h
//  aXTimes
//
//  Created by fuesec on 01/02/15.
//  Copyright (c) 2015 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AXDefaultPauseTableViewControllerDelegate

- (void)setDefaultPauseEnabled:(BOOL)enabled;
- (void)setDefaultPauseStart:(NSDate *)start;
- (void)setDefaultPauseEnd:(NSDate *)end;

@end

@interface AXDefaultPauseTableViewController : UITableViewController

@property (strong, nonatomic) id<AXDefaultPauseTableViewControllerDelegate> delegate;
@property BOOL defaultPauseEnabledState;
@property (strong, nonatomic) NSDate *defaultPauseStartDate;
@property (strong, nonatomic) NSDate *defaultPauseEndDate;

@property (strong, nonatomic) NSString *leftDetailLabelStringForSwitchCell;

@end
