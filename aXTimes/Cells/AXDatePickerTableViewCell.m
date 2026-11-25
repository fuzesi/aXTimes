//
//  AXDatePickerTableViewCell.m
//  aXTimes
//
//  Created by fuesec on 28/06/15.
//  Copyright (c) 2015 aXimilate. All rights reserved.
//

#import "AXDatePickerTableViewCell.h"

@implementation AXDatePickerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSLocale *locale = [NSLocale currentLocale];
    [self.datePicker setLocale:locale];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


@end
