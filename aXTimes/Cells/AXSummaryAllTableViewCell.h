//
//  AXDatePickerTableViewCell.h
//  aXTimes
//
//  Created by fuesec on 28/06/15.
//  Copyright (c) 2015 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSTableViewCellProtocol.h"

@interface AXSummaryAllTableViewCell : UITableViewCell<SKSTableViewCellProtocol>
@property (strong, nonatomic) IBOutlet UILabel *customTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeRangeLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *customImageView;
@property (strong, nonatomic) IBOutlet UIView *iconBackground;

/**
 * The boolean value showing the receiver is expandable or not. The default value of this property is NO.
 */
@property (nonatomic, assign, getter = isExpandable) BOOL expandable;

/**
 * The boolean value showing the receiver is expanded or not. The default value of this property is NO.
 */
@property (nonatomic, assign, getter = isExpanded) BOOL expanded;

@end
