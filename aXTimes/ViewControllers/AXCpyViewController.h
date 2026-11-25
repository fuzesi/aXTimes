//
//  AXCpyViewController.h
//  aXTimes
//
//  Created by fuesec on 05/07/15.
//  Copyright (c) 2015 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXCpyViewController : UIViewController


@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) DayEntry *currentDayEntry;
@property (nonatomic, strong) SettingsManager *settingsController;
@property (nonatomic, strong) NSMutableArray *settingsWorkingweek;

@end
