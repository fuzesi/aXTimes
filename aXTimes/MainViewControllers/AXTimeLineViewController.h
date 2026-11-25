//
//  AXTimeLineViewController.h
//  aXTimes
//
//  Created by Christopher Füseschi on 02/06/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDCalendarView.h"

@interface AXTimeLineViewController : UIViewController<DDCalendarViewDelegate, DDCalendarViewDataSource>

@property (strong, nonatomic) NSArray<DayEntry *> *entries;
@property (strong, nonatomic) NSDate *date;

- (void)refresh;

@end
