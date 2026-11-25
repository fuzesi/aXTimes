//
//  AXTextFieldTableViewCell.m
//  aXTimes
//
//  Created by Christopher Füseschi on 04/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXTextFieldTableViewCell.h"

@implementation AXTextFieldTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.keyboardType = UIKeyboardTypeEmailAddress;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.returnKeyType = UIReturnKeyDefault;
    self.textField.textAlignment = NSTextAlignmentRight;
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
        self.textField.adjustsFontForContentSizeCategory = YES;
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
    self.textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.textField becomeFirstResponder];
    }
}

@end
