//
//  AXNumbersTextFieldTableViewCell.m
//  aXTimes
//
//  Created by Christopher Füseschi on 03/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "AXNumbersTextFieldTableViewCell.h"

@implementation AXNumbersTextFieldTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.keyboardType = UIKeyboardTypeDecimalPad;
    self.textField.textAlignment = NSTextAlignmentRight;
    
    self.customTextLabel.textColor = GLOBALFONTCOLOR;
    self.textField.textColor = GLOBALFONTCOLOR;

    // http://stackoverflow.com/a/19469381
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 44.0f)];
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.translucent = YES;
    toolbar.tintColor = GLOBALBACKGROUNDCOLOR;
    // Create a flexible space to align buttons to the right
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil
                                      action:nil];
    
    // Create a cancel button to dismiss the keyboard
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self
                                      action:@selector(donePressed)];
    // Add buttons to the toolbar
    [toolbar setItems:@[flexibleSpace, barButtonItem]];
    // Set the toolbar as accessory view of an UITextField object
    self.textField.inputAccessoryView = toolbar;

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

- (void)donePressed {
    if ([self.delegate respondsToSelector:@selector(donePressed)]) {
        [self.delegate donePressed];
    }
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    // http://stackoverflow.com/a/18552074
    if (self.isUserInteractionEnabled) {
        self.textField.textColor = GLOBALFONTCOLOR;
    } else {
        [self.textField setTextColor:[UIColor lightGrayColor]];
    }
    self.customTextLabel.enabled = self.isUserInteractionEnabled;
}

@end
