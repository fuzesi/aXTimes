//
//  AXCopyrightViewController.m
//  aXTimes
//
//  Created by fuesec on 5/30/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXCopyrightViewController.h"

@interface AXCopyrightViewController ()

@property (strong, nonatomic) IBOutlet UINavigationItem *customNavigationItem;
@property (strong, nonatomic) IBOutlet UILabel *websiteIntroLabel;
@property (strong, nonatomic) IBOutlet UILabel *supportIntroLabel;
@property (strong, nonatomic) IBOutlet UIButton *websiteButton;
@property (strong, nonatomic) IBOutlet UIButton *supportSiteButton;
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) IBOutlet UILabel *bottomLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@end

@implementation AXCopyrightViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self =  [super initWithCoder:aDecoder];
	if (self) {
		self.navigationController.navigationBar.topItem.title = NSLS_INFORMATION;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
//	self.navigationController.navigationItem.title = NSLS_INFORMATION;
//	self.view.backgroundColor = SELECTIONCOLOR;
    self.containerView.backgroundColor = GLOBALBACKGROUNDCOLOR;
	self.websiteIntroLabel.text = NSLS_WEBSITEINTRO;
	self.supportIntroLabel.text = NSLS_SUPPORTINTRO;
	self.versionLabel.text = APPLICATIONFULLVERSION;
	self.bottomLabel.text = BOTTOM_INFOSCREEN;
	[self.websiteButton setTitle:WEBSITE_DISPLAY forState:UIControlStateNormal];
	[self.supportSiteButton setTitle:SUPPORTSITE_DISPLAY forState:UIControlStateNormal];

	[self.websiteButton addTarget:self action:@selector(openWebsite) forControlEvents:UIControlEventTouchUpInside];
	[self.supportSiteButton addTarget:self action:@selector(openSupportWebsite) forControlEvents:UIControlEventTouchUpInside];

	UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen)];
	swipeGestureLeft.direction = (UISwipeGestureRecognizerDirectionLeft);
	swipeGestureLeft.numberOfTouchesRequired = 1;
	[self.view addGestureRecognizer:swipeGestureLeft];

	UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen)];
	swipeGestureRight.direction = (UISwipeGestureRecognizerDirectionRight);
	swipeGestureRight.numberOfTouchesRequired = 1;
	[self.view addGestureRecognizer:swipeGestureRight];
}

- (void)viewWillAppear:(BOOL)animated {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self.navigationController.navigationBar.layer removeAllAnimations];
    }

	[super viewWillAppear:animated];
}

- (void)openWebsite {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLS_WEBSITE]];
}

- (void)openSupportWebsite {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:SUPPORTSITE]];
}

- (void)swipedScreen {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneAction:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
