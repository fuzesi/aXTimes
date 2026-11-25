//
//  AXProjectsSummaryTableViewController.h
//  aXTimes
//
//  Created by Christopher Füseschi on 31/10/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSTableView.h"
#import <CoreData/CoreData.h>

@interface AXProjectsSummaryViewController : UIViewController<SKSTableViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
- (void)reload;

@end
