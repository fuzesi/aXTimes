//
//  AXDayEntrySummaryTableViewCell.m
//  aXTimes
//
//  Created by Christopher Füseschi on 22/06/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXDayEntrySummaryTableViewCell.h"

@implementation AXDayEntrySummaryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.titleGrossTimeLabel.text = NSLS_GROSS;
    self.titleNetTimeLabel.text = NSLS_NET;
    self.titleSalaryLabel.text = NSLS_SALARY;
    
    if ([self.contentView respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.contentView.preservesSuperviewLayoutMargins = YES;
    }
    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.preservesSuperviewLayoutMargins = YES;
    }
    [self setupTextUI];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        self.titleGrossTimeLabel.adjustsFontForContentSizeCategory = YES;
        self.titleNetTimeLabel.adjustsFontForContentSizeCategory = YES;
        self.titleSalaryLabel.adjustsFontForContentSizeCategory = YES;
        self.grossTimeLabel.adjustsFontForContentSizeCategory = YES;
        self.netTimeLabel.adjustsFontForContentSizeCategory = YES;
        self.salaryLabel.adjustsFontForContentSizeCategory = YES;
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
    self.titleGrossTimeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.titleNetTimeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.titleSalaryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.grossTimeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.netTimeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.salaryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

@end
