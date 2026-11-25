//
//  AXCalendarViewController.m
//  aXTimes
//
//  Created by fuesec on 5/8/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXCalendarViewController.h"
#import "AXCalendarViewControllerProtocol.h"
#import <SHActionSheetBlocks.h>
#import "AXDayViewController.h"
#import "AXMonthViewController.h"
#import "AXUtility.h"
#import "AXContainerViewController.h"

@interface AXCalendarViewController ()

@property (strong, nonatomic) UIViewController<AXCalendarViewControllerProtocol> *currentlyActiveViewContainer;
@property (strong, nonatomic) NSArray *dateFormatters;
@property (strong, nonatomic) NSDateFormatter *dayDateFormatter;
@property (strong, nonatomic) NSDateFormatter *monthDateFormatter;
@property (strong, nonatomic)  UIViewController<AXCalendarViewControllerProtocol> *monthViewController;
@property (strong, nonatomic)  UIViewController<AXCalendarViewControllerProtocol> *dayViewController;
@property (nonatomic, weak) AXContainerViewController *containerViewController;

- (void)moveToDayDetail:(NSNotification *)notification;
- (void)goToToday;

@property (strong, nonatomic) IBOutlet UISegmentedControl *calendarSegmentedControl;
@property (strong, nonatomic) IBOutlet UIView *containerView;
// @property (strong, nonatomic) IBOutlet UIBarButtonItem *todayButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *optionsButton;
@property (strong, nonatomic) IBOutlet UINavigationItem *customNavigationItem;
@property (strong, nonatomic) IBOutlet UISegmentedControl *dayTypeSegmentedControl;
@property (strong, nonatomic) IBOutlet UIView *dayTypeSegmentedControlView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceContainer;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *dayTypeView;

- (IBAction)segementedControlAction:(id)sender;
- (IBAction)nextAction:(id)sender;
- (IBAction)previousAction:(id)sender;
// - (IBAction)todayAction:(id)sender;
- (IBAction)optionsAction:(id)sender;
- (IBAction)typeChangedAction:(id)sender;

@end

@implementation AXCalendarViewController

- (NSDateFormatter *)dayDateFormatter {
	if (_dayDateFormatter != nil) {
		return _dayDateFormatter;
	}
	_dayDateFormatter = [NSDateFormatter new];
	_dayDateFormatter.dateFormat = DATEFORMATTERDAYDETAILHEADER;
	return _dayDateFormatter;
}

- (NSDateFormatter *)monthDateFormatter {
	if (_monthDateFormatter != nil) {
		return _monthDateFormatter;
	}
	_monthDateFormatter = [NSDateFormatter new];
	_monthDateFormatter.dateFormat = DATEFORMATTERMONTHYEAR;
	return _monthDateFormatter;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self =  [super initWithCoder:aDecoder];
	if (self) {
		self.dateFormatters = [[NSArray alloc] initWithObjects:self.dayDateFormatter, self.monthDateFormatter, nil];

//		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//		self.dayViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AXDayViewController class])];
//		[self addChildViewController:self.dayViewController];

//		self.monthViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AXMonthViewController class])];
//		[self addChildViewController:self.monthViewController];

//		self.currentlyActiveViewContainer = self.childViewControllers [DAY];
//        self.currentlyActiveViewContainer = self.dayViewController;

		self.currentlyActiveDateFormatter = self.dateFormatters[DAY];

		[[NSNotificationCenter defaultCenter]
				 addObserver:self
					selector:@selector(moveToDayDetail:)
						name:NOTIFICATION_MOVETODAYDETAIL
					  object:nil];
		self.tabBarItem.selectedImage = [UIImage imageNamed:@"detail_fine_selected.png"];
	}
	return self;
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
    self.headerView.backgroundColor = GLOBALBACKGROUNDCOLOR2;
    self.dayTypeView.backgroundColor = GLOBALBACKGROUNDCOLOR2;
    
	self.calendarSegmentedControl.selectedSegmentIndex = DAY;

	self.dayTypeSegmentedControl.tintColor = SELECTIONCOLOR;

	self.optionsButton.title = NSLS_OPTIONS;

	// bug storyboard localization does not work so we set title manually
	[self.calendarSegmentedControl setTitle:NSLS_DAY forSegmentAtIndex:0];
	[self.calendarSegmentedControl setTitle:NSLS_MONTH forSegmentAtIndex:1];
    
    // Frame setzen sollte nicht hier gemacht werden aber -> viewdidlayoutsubviews
    // http://stackoverflow.com/questions/6757018/why-am-i-having-to-manually-set-my-views-frame-in-viewdidload
    // http://stackoverflow.com/questions/16796783/uiviewcontroller-viewdidload-incorrect-width-height

//    [self addChildViewController:self.currentlyActiveViewContainer];                 // 1
//	[self.containerView addSubview:self.currentlyActiveViewContainer.view];
//    [self.currentlyActiveViewContainer didMoveToParentViewController:self];
    [[NSNotificationCenter defaultCenter]
				 addObserver:self
					selector:@selector(updateHeaderLabel:)
                        name:NOTIFICATION_NAVIGATION_TRIGGERED
                      object:nil];
    [[NSNotificationCenter defaultCenter]
				 addObserver:self
					selector:@selector(optionsButtonNeedsUpdate:)
                        name:NOTIFICATION_OPTIONS_BUTTON_NEEDSUPDATE
                      object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:NSLS_TODAY style:UIBarButtonItemStylePlain target:self action:@selector(goToToday)];
    self.customNavigationItem.leftBarButtonItem = todayButton;

//    self.containerView.backgroundColor = [UIColor yellowColor];
//    [self.monthViewController.view layoutIfNeeded];
//    self.dayViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.monthViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

//    NSMutableArray * constraints = [NSMutableArray array];
//    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.monthViewController.view
//                                                        attribute:NSLayoutAttributeTrailing
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:self.containerView
//                                                        attribute:NSLayoutAttributeTrailing
//                                                       multiplier:1.0
//                                                         constant:0]];
//    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.monthViewController.view
//                                                        attribute:NSLayoutAttributeLeading
//                                                        relatedBy:NSLayoutRelationEqual 
//                                                           toItem:self.containerView
//                                                        attribute:NSLayoutAttributeLeading
//                                                       multiplier:1.0
//                                                         constant:0]];
//    [self.view addConstraints:constraints];
//
//    
//    CGRect asdf = self.dayViewController.view.frame;
//    CGRect asdf2 = self.containerView.frame;
//   self.currentlyActiveViewContainer.view.frame = self.containerView.frame;
//    [self.containerView addSubview:self.currentlyActiveViewContainer.view];
//    [self.currentlyActiveViewContainer didMoveToParentViewController:self];
    
	NSDate *tempDate = [[AXDateManager sharedInstance] currentDate];
	self.headerLabel.text = [[self.currentlyActiveDateFormatter stringFromDate:tempDate] capitalizedString];
	[AXUtility setSelectedSegmentIndexOnDayTypeSegementedControl:self.dayTypeSegmentedControl withDate:tempDate];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//        self.monthViewController.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width,  self.containerView.frame.size.height);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - user outlet actions
- (IBAction)segementedControlAction:(id)sender {
    
    
    if (self.calendarSegmentedControl.selectedSegmentIndex == DAY) {
        self.customNavigationItem.rightBarButtonItem = self.optionsButton;
        self.verticalSpaceContainer.constant = self.verticalSpaceContainer.constant + 40;
        [self.view bringSubviewToFront:self.dayTypeSegmentedControlView];
    } else {
        self.verticalSpaceContainer.constant = self.verticalSpaceContainer.constant - 40;
        [self.view sendSubviewToBack:self.dayTypeSegmentedControlView];
        self.customNavigationItem.rightBarButtonItem = nil;
    }
    
    
    [self.containerViewController swapViewControllers];

//    
//    UIViewController *oldC = self.currentlyActiveViewContainer;
//    UIViewController<AXCalendarViewControllerProtocol> *newC = nil;
//
//    if (self.calendarSegmentedControl.selectedSegmentIndex == DAY) {
//        newC = self.dayViewController;
//    } else {
//        newC = self.monthViewController;
//    }
//
//    [oldC willMoveToParentViewController:nil];                        // 1
//    [self addChildViewController:newC];
//    
//    newC.view.frame = [self newViewStartFrame];                       // 2
//    CGRect endFrame = [self oldViewEndFrame];
    

    
//    [self transitionFromViewController: oldC toViewController: newC   // 3
//                              duration: 0 options:0
//                            animations:^{
////                                newC.view.frame = oldC.view.frame;                       // 4
////                                oldC.view.frame = endFrame;
//                            }
//                            completion:^(BOOL finished) {
//                                [oldC removeFromParentViewController];                   // 5
//                                [newC didMoveToParentViewController:self];
//                            }];
    
    
//	[self transitionFromViewController:oldC toViewController:newC duration:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
////        CGFloat asdf = self.containerView.frame.size.width;
////		 ((UIViewController *)self.childViewControllers [[self.calendarSegmentedControl selectedSegmentIndex]]).view.frame = CGRectMake(0, 0, self.containerView.frame.size.width,  self.containerView.frame.size.height);
////        UIView *view = ((UIViewController *)self.childViewControllers [[self.calendarSegmentedControl selectedSegmentIndex]]).view;
////        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view                                                              attribute:NSLayoutAttributeWidth
////                                                              relatedBy:NSLayoutRelationEqual
////                                                                 toItem:nil
////                                                              attribute:NSLayoutAttributeNotAnAttribute
////                                                             multiplier:1.0
////                                                               constant:containerWidth]];
//	 }];
//	self.currentlyActiveViewContainer = newC;
	self.currentlyActiveDateFormatter = self.dateFormatters [[self.calendarSegmentedControl selectedSegmentIndex]];
	self.headerLabel.text = [[self.currentlyActiveDateFormatter stringFromDate:[[AXDateManager sharedInstance] currentDate]] capitalizedString];
}

- (IBAction)nextAction:(id)sender {
	[self navigateForward:YES];
}

- (IBAction)previousAction:(id)sender {
	[self navigateForward:NO];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    DebugLog(@"%s", __PRETTY_FUNCTION__);
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DebugLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([segue.identifier isEqualToString:@"embedContainerDetail"]) {
        self.containerViewController = segue.destinationViewController;
    }
}

// - (IBAction)todayAction:(id)sender {
//	[self.currentlyActiveViewContainer goToToday];
//	self.headerLabel.text = [[self.currentlyActiveDateFormatter stringFromDate:[[AXDateManager sharedInstance] currentDate]] capitalizedString];
// }

- (void)goToToday {
	[self.containerViewController goToToday];
	self.headerLabel.text = [[self.currentlyActiveDateFormatter stringFromDate:[[AXDateManager sharedInstance] currentDate]] capitalizedString];
}

- (IBAction)optionsAction:(id)sender {
	[self.containerViewController showOptions];
}

- (IBAction)typeChangedAction:(id)sender {
	[AXUtility dayTypeChanged:self.dayTypeSegmentedControl withDate:[[AXDateManager sharedInstance] currentDate]];
}

#pragma mark - private methods
- (void)moveToDayDetail:(NSNotification *)notification {
	[AXUtility setSelectedSegmentIndexOnDayTypeSegementedControl:self.dayTypeSegmentedControl withDate:[[AXDateManager sharedInstance] currentDate]];
	[self.calendarSegmentedControl setSelectedSegmentIndex:0];
	[self segementedControlAction:nil];
}

- (void)updateHeaderLabel:(NSNotification *)notification {
    self.headerLabel.text = [[self.currentlyActiveDateFormatter stringFromDate:[[AXDateManager sharedInstance] currentDate]] capitalizedString];
    if (self.calendarSegmentedControl.selectedSegmentIndex == 0) {
        [AXUtility setSelectedSegmentIndexOnDayTypeSegementedControl:self.dayTypeSegmentedControl withDate:[[AXDateManager sharedInstance] currentDate]];
    }
}

- (void)optionsButtonNeedsUpdate:(NSNotification *)notification {
    NSNumber *enable = [notification object];
    [self enableOptionButton:[enable boolValue]];
}

- (void)navigateForward:(BOOL)forward {
    [self.containerViewController navigateForward:forward];
    
	self.headerLabel.text = [[self.currentlyActiveDateFormatter stringFromDate:[[AXDateManager sharedInstance] currentDate]] capitalizedString];
	if (self.calendarSegmentedControl.selectedSegmentIndex == 0) {
		[AXUtility setSelectedSegmentIndexOnDayTypeSegementedControl:self.dayTypeSegmentedControl withDate:[[AXDateManager sharedInstance] currentDate]];
	}
}

#pragma mark - public methods
- (void)enableOptionButton:(BOOL)enabled {
	self.optionsButton.enabled = enabled;
}

@end
