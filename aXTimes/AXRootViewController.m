//
//  DEMOViewController.m
//  RESideMenuStoryboards
//
//  Created by Roman Efimov on 10/9/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "AXRootViewController.h"
#import "AXLeftMenuViewController.h"

#import "AXMainViewController.h"
#import "AXOverviewViewController.h"
#import "AXSummaryCalendarViewController.h"
#import "AXOverviewSettingsTableViewController.h"

typedef NS_ENUM (NSUInteger, TabIndex) {
    TabIndexLive = 0,
    TabIndexDetail,
    TabIndexReport,
    TabIndexSettings
};

@interface AXRootViewController ()

@end

@implementation AXRootViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.contentViewShadowColor = [UIColor blackColor];
    self.contentViewShadowOffset = CGSizeMake(0, 0);
    self.contentViewShadowOpacity = 0.6;
    self.contentViewShadowRadius = 12;
    self.contentViewShadowEnabled = YES;
    
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    
    UITabBarController *tabBarController = (UITabBarController *)self.contentViewController;
    
    NSArray<UIViewController *> *viewControllers;
    
    AXMainViewController *aXMainViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AXMainViewController class])];
    UINavigationController *liveNavigationController = [[UINavigationController alloc] initWithRootViewController:aXMainViewController];
    liveNavigationController.title = NSLS_TABMAIN;
    liveNavigationController.tabBarItem.image = [UIImage imageNamed:@"clock_fine"];
    liveNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"clock_fine_selected"];

    SelectedDateViewModel *selectedDateViewModel = [[SelectedDateViewModel alloc] initWithDate:[NSDate date]];

    AXOverviewViewController *aXOverviewViewController = [AXOverviewViewController new];
    aXOverviewViewController.selectedDateViewModel = selectedDateViewModel;
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:aXOverviewViewController];
    detailNavigationController.title = NSLS_TABDETAIL;
    detailNavigationController.tabBarItem.image = [UIImage imageNamed:@"detail_fine"];
    detailNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"detail_fine_selected"];
    
    AXSummaryCalendarViewController *aXSummaryCalendarViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AXSummaryCalendarViewController class])];
    aXSummaryCalendarViewController.selectedDateViewModel = selectedDateViewModel;
    aXSummaryCalendarViewController.title = NSLS_TABSUMMARY;
    UINavigationController *reportNavigationController = [[UINavigationController alloc] initWithRootViewController:aXSummaryCalendarViewController];
    reportNavigationController.title = NSLS_TABSUMMARY;
    reportNavigationController.tabBarItem.image = [UIImage imageNamed:@"overview_fine"];
    reportNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"overview_fine_selected"];
    
    AXOverviewSettingsTableViewController *aXOverviewSettingsTableViewController = [AXOverviewSettingsTableViewController new];
    UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:aXOverviewSettingsTableViewController];
    settingsNavigationController.title = NSLS_TABSETTINGS;
    settingsNavigationController.tabBarItem.image = [UIImage imageNamed:@"settings_fine"];
    settingsNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"settings_fine_selected"];
    
    viewControllers = @[liveNavigationController,
                        detailNavigationController,
                        reportNavigationController,
                        settingsNavigationController];
    
    [tabBarController setViewControllers:viewControllers];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:TABBAR_FIRST_START]) {
        tabBarController.selectedIndex = TabIndexSettings;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TABBAR_FIRST_START];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    AXLeftMenuViewController *leftMenuViewController = [AXLeftMenuViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:leftMenuViewController];
    
    self.leftMenuViewController = navigationController;
    self.scaleMenuView = NO;
    self.scaleContentView = NO;
    self.parallaxEnabled = NO;
    self.scaleBackgroundImageView = NO;
    self.fadeMenuView = NO;
    self.backgroundImage = nil;
    self.contentViewInPortraitOffsetCenterX = 115;
    self.delegate = self;
}

#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController {
    NSLog(@"willShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController {
    NSLog(@"didShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController {
    NSLog(@"willHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController {
    NSLog(@"didHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (BOOL)sideMenu:(RESideMenu *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer {
    UITabBarController *tabBarController;
    
    if ([self.contentViewController isKindOfClass:[UITabBarController class]]) {
        tabBarController = (UITabBarController *)self.contentViewController;
        if (tabBarController) {
            if (tabBarController.selectedIndex == TabIndexDetail ||
                tabBarController.selectedIndex == TabIndexReport) {
                return YES;
            }
        }
    }

    return NO;
}

@end
