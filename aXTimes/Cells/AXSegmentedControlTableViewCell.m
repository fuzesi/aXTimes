//
//  AXSegmentedControlTableViewCell.m
//  aXTimes
//
//  Created by Christopher Füseschi on 08/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXSegmentedControlTableViewCell.h"

@implementation AXSegmentedControlTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.segmentedControl.tintColor = SELECTIONCOLOR;
    if ([self.contentView respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.contentView.preservesSuperviewLayoutMargins = YES;
    }
    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.preservesSuperviewLayoutMargins = YES;
    }
}


@end
