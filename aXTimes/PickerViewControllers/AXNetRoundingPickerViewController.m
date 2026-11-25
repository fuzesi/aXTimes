//
//  AXNetRoundingPickerViewController.m
//  aXTimes
//
//  Created by fuesec on 6/11/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXNetRoundingPickerViewController.h"
#import "AXSettingsManager.h"

@interface AXNetRoundingPickerViewController ()
@property (nonatomic, strong) AXSettingsManager *settingsController;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation AXNetRoundingPickerViewController
#pragma mark - view lifecycle
- (void)awakeFromNib {
    self.settingsController = [AXSettingsManager new];
    self.dataArray = ROUNDINGBEHAVIOURNAMES;
    [self.view setBackgroundColor:GLOBALBACKGROUNDCOLOR2];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.pickerView.delegate = self;
    NSInteger rowToSelect  = 0;
    ROUNDINGBEHAVIOUR selectValue = [self.settingsController getNetRounding];
    rowToSelect = selectValue;
    [self.pickerView selectRow:rowToSelect inComponent:0 animated:NO];
}

#pragma mark - picker view delegate and datasource methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *roundingName = [self.dataArray objectAtIndex:row];
    
    return roundingName;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.settingsController setNetRounding:row];
}

#pragma mark - picker view datasource methods
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataArray.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

@end
