//
//  AXNumbersTextFieldTableViewCell.h
//  aXTimes
//
//  Created by Christopher Füseschi on 03/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AXNumbersTextFieldTableViewCellProtocol <NSObject>

- (void)donePressed;

@end

@interface AXNumbersTextFieldTableViewCell : UITableViewCell

@property (weak, nonatomic) id<AXNumbersTextFieldTableViewCellProtocol> delegate;
@property (weak, nonatomic) IBOutlet UILabel *customTextLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
