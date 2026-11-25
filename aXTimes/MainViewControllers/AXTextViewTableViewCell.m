//
//  AXTextViewTableViewCell.m
//  aXTimes
//
//  Created by Christopher Füseschi on 04/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXTextViewTableViewCell.h"

@implementation AXTextViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.textView becomeFirstResponder];
    }
}

@end
