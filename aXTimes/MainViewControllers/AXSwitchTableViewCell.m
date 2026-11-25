//
//  AXSwitchTableViewCell.m
//  aXTimes
//
//  Created by Christopher Füseschi on 04/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXSwitchTableViewCell.h"

@implementation AXSwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.switchControl setOnTintColor:C_SYSTEM_GREEN];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    if ([self.contentView respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.contentView.preservesSuperviewLayoutMargins = YES;
    }
    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.preservesSuperviewLayoutMargins = YES;
    }
    [self setupTextUI];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        self.customTextLabel.adjustsFontForContentSizeCategory = YES;
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

//- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
//    if (previousTraitCollection.preferredContentSizeCategory != self.traitCollection.preferredContentSizeCategory) {
//        [self setupTextUI];
//    }
//}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self setupTextUI];
}

- (void)setupTextUI {
    self.customTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

@end
