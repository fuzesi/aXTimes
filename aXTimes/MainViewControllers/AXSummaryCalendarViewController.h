//
//  AXSummaryCalendarViewController.h
//  aXTimes
//
//  Created by fuesec on 5/11/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "AXCalendarViewControllerProtocol.h"
#import "AXSuperCalendarViewController.h"
#import "SKSTableView.h"

@interface AXSummaryCalendarViewController : AXSuperCalendarViewController<AXCalendarViewControllerProtocol, SKSTableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) SelectedDateViewModel *selectedDateViewModel;

@end
