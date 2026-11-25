//
//  AXTextFieldTableViewCell.h
//  aXTimes
//
//  Created by Christopher Füseschi on 04/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXTextFieldTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *customTextLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
