//
//  AXSuperCalendarViewController.m
//  aXTimes
//
//  Created by fuesec on 6/30/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXSuperCalendarViewController.h"

@interface AXSuperCalendarViewController ()

@end

@implementation AXSuperCalendarViewController

#pragma mark - lifecycle methods
- (void)viewDidLoad {
	[super viewDidLoad];
	UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight)];
	swipeGestureRight.direction = (UISwipeGestureRecognizerDirectionRight);
	swipeGestureRight.numberOfTouchesRequired = 1;
	[self.view addGestureRecognizer:swipeGestureRight];

	UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft)];
	swipeGestureLeft.direction = (UISwipeGestureRecognizerDirectionLeft);
	swipeGestureLeft.numberOfTouchesRequired = 1;
	[self.view addGestureRecognizer:swipeGestureLeft];
}

#pragma mark - private methods
- (void)swipedRight {
	[self navigateForward:NO];
}

- (void)swipedLeft {
	[self navigateForward:YES];
}

- (void)navigateForward:(BOOL)forward {
	[self doesNotRecognizeSelector:_cmd];
}

@end
