//
//  AXCommetTableViewCell.m
//  aXTimes
//
//  Created by fuesec on 2/25/14.
//  Copyright (c) 2014 aXimilate. All rights reserved.
//

#import "AXStandardTableViewCell.h"

@interface AXStandardTableViewCell ()
@end

@implementation AXStandardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.customTextLabel.textColor = GLOBALFONTCOLOR;
    self.customDetailTextLabel.textColor = GLOBALFONTCOLOR;
    self.customTextLabel.numberOfLines = 0;
    self.customDetailTextLabel.numberOfLines = 5;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([self.contentView respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.contentView.preservesSuperviewLayoutMargins = YES;
    }
    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.preservesSuperviewLayoutMargins = YES;
    }
    [self setupTextUI];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        self.customTextLabel.adjustsFontForContentSizeCategory = YES;
        self.customDetailTextLabel.adjustsFontForContentSizeCategory = YES;
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
    self.customDetailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

@end
