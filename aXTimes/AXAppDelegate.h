//
//  AXAppDelegate.h
//  aXTimes
//
//  Created by fuesec on 4/27/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@protocol WatchCommunicationAppDelegate;

@interface AXAppDelegate : UIResponder <UIApplicationDelegate, WatchCommunicationAppDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UIStoryboard *storyboard;
@property (strong, nonatomic) Project *project;

@end
