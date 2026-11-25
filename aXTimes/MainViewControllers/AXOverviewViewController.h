//
//  AXOverviewViewController.h
//  aXTimes
//
//  Created by Christopher Füseschi on 31/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"

@class SelectedDateViewModel;

@interface AXOverviewViewController : UIViewController<JTCalendarDelegate, UIScrollViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) SelectedDateViewModel *selectedDateViewModel;
@property (strong, nonatomic) NSMutableArray *curDaySelectionArray;


@end
