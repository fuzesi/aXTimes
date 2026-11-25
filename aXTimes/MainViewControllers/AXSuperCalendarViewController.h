//
//  AXSuperCalendarViewController.h
//  aXTimes
//
//  Created by fuesec on 6/30/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXCalendarViewControllerProtocol.h"

@interface AXSuperCalendarViewController : UIViewController

@property (weak, nonatomic) id<AXCalendarViewControllerProtocol> delegate;

@end
