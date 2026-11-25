//
//  AXDayEntrySummaryTableViewCell.h
//  aXTimes
//
//  Created by Christopher Füseschi on 22/06/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXDayEntrySummaryTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *grossTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *netTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *salaryLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleGrossTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleNetTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleSalaryLabel;
@end
