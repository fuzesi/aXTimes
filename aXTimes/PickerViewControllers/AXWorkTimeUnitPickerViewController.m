//
//  AXWorkTimeUnitPickerViewController.m
//  aXTimes
//
//  Created by fuesec on 6/11/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXWorkTimeUnitPickerViewController.h"
#import "AXSettingsManager.h"

@interface AXWorkTimeUnitPickerViewController ()
@property (nonatomic, strong) AXSettingsManager *settingsController;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation AXWorkTimeUnitPickerViewController
#pragma mark - view lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    self.settingsController = [AXSettingsManager new];
    self.dataArray = WORKTIMEUNITS;
    [self.view setBackgroundColor:GLOBALBACKGROUNDCOLOR2];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.pickerView.delegate = self;
    NSInteger rowToSelect  = 0;
    double selectValue = [self.settingsController getWorkTimeUnit];
    for (int i = 0; i < self.dataArray.count; i++) {
        if ([[self.dataArray objectAtIndex:i]doubleValue] == selectValue) {
            rowToSelect = i;
        }
    }
    
    [self.pickerView selectRow:rowToSelect inComponent:0 animated:NO];
}

#pragma mark - picker view delegate and datasource methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSNumber *timeUnit = [self.dataArray objectAtIndex:row];
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    return [NSString stringWithFormat:@"%@ %@", [numberFormatter stringFromNumber:timeUnit], NSLS_MINUTE_SHORT];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.settingsController setWorkTimeUnit:[[self.dataArray objectAtIndex:row] doubleValue]];
}

#pragma mark - picker view datasource methods
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataArray.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

@end
