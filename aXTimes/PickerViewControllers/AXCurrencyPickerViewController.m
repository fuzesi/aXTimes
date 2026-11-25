//
//  AXCurrencyPickerViewController.m
//  aXTimes
//
//  Created by fuesec on 5/24/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXCurrencyPickerViewController.h"
#import "AXSettingsManager.h"

@interface AXCurrencyPickerViewController ()
@property (nonatomic, strong) AXSettingsManager *settingsController;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation AXCurrencyPickerViewController

#pragma mark - view lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    self.settingsController = [AXSettingsManager new];
    self.dataArray = [NSLocale ISOCurrencyCodes];
    [self.view setBackgroundColor:GLOBALBACKGROUNDCOLOR2];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.pickerView.delegate = self;
	NSInteger rowToSelect  = 0;

	NSString *selectString = [self.settingsController getCurrencyIso];
	for (int i = 0; i < self.dataArray.count; i++) {
		if ([[self.dataArray objectAtIndex:i] isEqualToString:selectString]) {
			rowToSelect = i;
		}
	}
	[self.pickerView selectRow:rowToSelect inComponent:0 animated:NO];
}


#pragma mark - picker view delegate and datasource methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSString *isoIdentifier = [self.dataArray objectAtIndex:row];

	return isoIdentifier;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.settingsController setCurrencyIso:[self.dataArray objectAtIndex:row]];
}

#pragma mark - picker view datasource methods
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataArray.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

@end
