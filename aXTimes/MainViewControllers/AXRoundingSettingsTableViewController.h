//
//  AXRoundingSettingsTableViewController.h
//  aXTimes
//
//  Created by Christopher Füseschi on 04/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, RoundingBehaviour) {
    RoundingBehaviourDefault = 0,
    RoundingBehaviourRoundDown = 1,
    RoundingBehaviourRoundUp = 2
};

@protocol AXRoundingSettingsTableViewControllerDelegate<NSObject>
- (void)setSelectedRoundingBehaviour:(RoundingBehaviour)roundingBehaviour;
@end

@interface AXRoundingSettingsTableViewController : UITableViewController
@property (strong, nonatomic) id<AXRoundingSettingsTableViewControllerDelegate> delegate;

// must be a value contained in enum 'ROUNDINGBEHAVIOUR'
@property RoundingBehaviour initialValue;
@end
