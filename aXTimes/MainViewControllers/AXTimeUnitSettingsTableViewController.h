//
//  AXTimeUnitSettingsTableViewController.h
//  aXTimes
//
//  Created by Christopher Füseschi on 03/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AXTimeUnitSettingsTableViewControllerDelegate<NSObject>
- (void)setSelectedTimeUnit:(NSUInteger)timeUnitInMinutes;
@end

@interface AXTimeUnitSettingsTableViewController : UITableViewController
@property (strong, nonatomic) id<AXTimeUnitSettingsTableViewControllerDelegate> delegate;

// must be a value contained in 'WORKTIMEUNITS'
@property NSUInteger initialValue;
@end
