//
//  AXPauseTableViewCell.m
//  aXTimes
//
//  Created by fuesec on 6/15/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXPauseTableViewCell.h"

@interface AXPauseTableViewCell ()
@end

@implementation AXPauseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.customTextLabel.textColor = GLOBALFONTCOLOR;
    self.timeRangeLabel.textColor = GLOBALDETAILFONTCOLOR;
    self.totalTimeLabel.textColor = GLOBALDETAILFONTCOLOR;
    self.timeRangeLabel.textAlignment = NSTextAlignmentRight;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if ([self.contentView respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.contentView.preservesSuperviewLayoutMargins = YES;
    }
    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.preservesSuperviewLayoutMargins = YES;
    }
    [self setupTextUI];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        self.customTextLabel.adjustsFontForContentSizeCategory = YES;
        self.timeRangeLabel.adjustsFontForContentSizeCategory = YES;
        self.totalTimeLabel.adjustsFontForContentSizeCategory = YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self setupTextUI];
}

- (void)setupTextUI {
    self.customTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.timeRangeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.totalTimeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

@end
