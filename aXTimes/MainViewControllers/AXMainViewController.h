//
//  AXMainViewController.h
//  aXTimes
//
//  Created by fuesec on 4/27/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXProjectCheckinSettingsViewController.h"
#import "AXNoteViewController.h"

@interface AXMainViewController : UIViewController<UIScrollViewDelegate, AXInitiateCheckInOnSpecificProjectProtocol, AXNoteViewControllerProtocol>

@end
