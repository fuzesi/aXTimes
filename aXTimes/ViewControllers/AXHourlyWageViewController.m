//
//  AXHourlyWageTableViewController.m
//  aXTimes
//
//  Created by fuesec on 5/26/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXHourlyWageViewController.h"
#import "NSString+AXNSStringCategory.h"
#import "NSNumberFormatter+AXNSNumberFormatterCategory.h"

@interface AXHourlyWageViewController ()

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UITextField *activeKeyboardObject;

@end

@implementation AXHourlyWageViewController

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = NSLS_HOURLYWAGE;
    
    UINib *numberTextFieldTabelViewCellNib = [UINib
                                              nibWithNibName:NSStringFromClass([AXNumbersTextFieldTableViewCell class])
                                              bundle:nil];
    [self.tableView registerNib:numberTextFieldTabelViewCellNib
         forCellReuseIdentifier:NSStringFromClass([AXNumbersTextFieldTableViewCell class])];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AXNumbersTextFieldTableViewCell *numberCell;

    numberCell = [tableView
                  dequeueReusableCellWithIdentifier:NSStringFromClass([AXNumbersTextFieldTableViewCell class])
                  forIndexPath:indexPath];
    numberCell.textField.delegate = self;
    [numberCell.textField becomeFirstResponder];
    numberCell.delegate = self;
    [numberCell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
    numberCell.customTextLabel.text = NSLS_HOURLYWAGE;
    numberCell.textField.text = [self.currentDayEntry hourlyWageAsDecimalString];
    numberCell.textField.delegate = self;
    numberCell.delegate = self;

	return numberCell;
}

#pragma mark - buttonbar actions

- (void)saveTextFieldInput:(UITextField *)textField {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter defaultNumberFormatter_Static:YES];

	NSString *stringToParse = @"";
	if ([[textField.text trim] isEqualToString:@""]) {
		stringToParse = @"0";
	} else {
		stringToParse = textField.text;
	}
	NSNumber *tempNumber = [numberFormatter numberFromString:stringToParse];
	NSString *tempString = [NSString stringWithFormat:@"%@",
                            [numberFormatter stringFromNumber:tempNumber]];
	NSNumber *numberSetByUser = [numberFormatter numberFromString:tempString];
	if (numberSetByUser != nil) {
		[self.currentDayEntry setHourlyWage:numberSetByUser.decimalNumber];
    }
}

#pragma mark - private methods

- (void)dismissKeyboard {
	if (self.activeKeyboardObject != nil) {
		[self.activeKeyboardObject resignFirstResponder];
		[self.view removeGestureRecognizer:self.tapGestureRecognizer];
		self.tapGestureRecognizer = nil;
	}
}

- (void)textFieldEditingChanged:(id)sender {
    if ([sender isKindOfClass:[UITextField class]]) {
        [self saveTextFieldInput:sender];
    }
}

#pragma mark - textfield and textview delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self saveTextFieldInput:textField];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.activeKeyboardObject = textField;
	if (self.tapGestureRecognizer == nil) {
		self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
		[self.view addGestureRecognizer:self.tapGestureRecognizer];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - AXNumbersTextFieldTableViewCellProtocol

- (void)donePressed {
    [self dismissKeyboard];
}


@end
