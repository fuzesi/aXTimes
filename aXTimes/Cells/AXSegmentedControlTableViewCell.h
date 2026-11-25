//
//  AXSegmentedControlTableViewCell.h
//  aXTimes
//
//  Created by Christopher Füseschi on 08/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXSegmentedControlTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *customTextLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end
