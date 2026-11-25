//
//  AXClientSelectionTableViewController.h
//  aXTimes
//
//  Created by Christopher Füseschi on 21/06/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXClientSelectionTableViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) Project *project;

@end
