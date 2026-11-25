//
//  AXExportDecimalSeparatorViewController.m
//  aXTimes
//
//  Created by fuesec on 6/14/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXExportDecimalSeparatorPickerViewController.h"
#import "AXSettingsManager.h"

@interface AXExportDecimalSeparatorPickerViewController ()
@property (nonatomic, strong) AXSettingsManager *settingsController;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation AXExportDecimalSeparatorPickerViewController
#pragma mark - view lifecycle
- (void)awakeFromNib {
    self.settingsController = [AXSettingsManager new];
    self.dataArray = DECIMALSEPARATORS;
    [self.view setBackgroundColor:GLOBALBACKGROUNDCOLOR2];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.pickerView.delegate = self;
    NSInteger rowToSelect  = 0;
    NSString *selectString = [self.settingsController getExportDecimalSeparator];
    for (int i = 0; i < self.dataArray.count; i++) {
        if ([[self.dataArray objectAtIndex:i]isEqualToString:selectString]) {
            rowToSelect = i;
        }
    }
    
    [self.pickerView selectRow:rowToSelect inComponent:0 animated:NO];
}

#pragma mark - picker view delegate and datasource methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *decimalSeperator = [self.dataArray objectAtIndex:row];
    
    if ([decimalSeperator isEqualToString:NULLSTRING]) {
        return [NSString stringWithFormat:@" %@ (%@)", DEFAULTSTRING, [[NSNumberFormatter new] decimalSeparator]];
    }
    return decimalSeperator;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.settingsController setExportDecimalSeparator:[self.dataArray objectAtIndex:row]];
}

#pragma mark - picker view datasource methods
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataArray.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


@end
