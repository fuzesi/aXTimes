//
//  AXDefaultCommentViewController.m
//  aXTimes
//
//  Created by fuesec on 6/11/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXDefaultCommentViewController.h"
#import "NSString+AXNSStringCategory.h"

@interface AXDefaultCommentViewController ()

@property (strong, nonatomic) UITextView *textView;

@end

@implementation AXDefaultCommentViewController

#pragma mark - view lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];

    self.title = self.controllerTitle;

    self.textView = [UITextView new];
    [self.textView setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    
    [self.view addSubview:self.textView];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.textView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.textView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.textView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.textView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
	UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"eraser"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(clear)];
	clearButton.tintColor = SELECTIONCOLOR;
    self.navigationItem.rightBarButtonItem = clearButton;
    [self.textView setText:self.initialString];
    [self.textView becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.textView resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(setStringFromTextView:)]) {
        [self.delegate setStringFromTextView:self.textView.text];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(setStringFromTextView:)]) {
        [self.delegate setStringFromTextView:self.textView.text];
    }
}

#pragma mark - private methods

- (void)clear {
	self.textView.text = @"";
    if ([self.delegate respondsToSelector:@selector(setStringFromTextView:)]) {
        [self.delegate setStringFromTextView:self.textView.text];
    }
}

#pragma mark - notifications

- (void)keyboardDidShow:(NSNotification *)notification {
    NSValue *keyboardRectAsObject = [[notification userInfo]
                                     objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = CGRectZero;
    [keyboardRectAsObject getValue:&keyboardRect];
    
    self.textView.contentInset = UIEdgeInsetsMake(self.textView.contentInset.top,
                                                  self.textView.contentInset.left,
                                                  keyboardRect.size.height,
                                                  self.textView.contentInset.right);
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.textView.contentInset = UIEdgeInsetsZero;
}

@end
