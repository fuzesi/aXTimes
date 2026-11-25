//
//  AXOverviewViewController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 31/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <os/log.h>

#import "AXOverviewViewController.h"
#import "UIViewController+Container.h"
#import "AXDayEntriesListViewController.h"
#import "AXTimeLineViewController.h"
#import "NSDate+AXNSDateCategory.h"
#import "AXUtility.h"
#import "AXDayEntryEditViewController.h"
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "NSDateFormatter+AXDateFormatters.h"
#import "UIImage+AXUIImageCategory.h"
#import "NSCalendar+AXNSCalendarCategory.h"

#import <AudioToolbox/AudioToolbox.h>

@interface AXOverviewViewController ()
@property (strong, nonatomic) JTCalendarMenuView *calendarMenuView;
@property (strong, nonatomic) JTHorizontalCalendarView *calendarContentView;
@property (strong, nonatomic) JTCalendarManager *calendarManager;
@property (strong, nonatomic) NSLayoutConstraint *calendarContentViewHeightConstraint;

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIViewController *activeContainerViewController;

@property (strong, nonatomic) NSFetchedResultsController *dayEntryFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *dayTypeFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *workingWeekSettingFetchedResultsController;

@property (strong, nonatomic) NSMutableDictionary *fetchedDayEntries;

@property (strong, nonatomic) NSMutableArray<NSString *> *dayEntrySectionNames;
@property (strong, nonatomic) NSMutableArray<NSString *> *dayTypeSectionNames;
@property (strong, nonatomic) NSMutableArray<NSString *> *workingWeekSettingSectionNames;

@property (strong, nonatomic) UIColor *colorNotWorkingCellColor;
@property (strong, nonatomic) UIColor *colorWorkingCellColor;

@property (nonatomic) BOOL loadingPage;

@property (strong, nonatomic) NSArray *fromUserSettingsWorkingWeekArray;

@property (strong, nonatomic) AXDayEntriesListViewController *aXDayEntriesListViewController;
@property (strong, nonatomic) AXTimeLineViewController *aXTimeLineViewController;

@property (strong, nonatomic) UIBarButtonItem *switchViewButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIImage *weekImage;
@property (strong, nonatomic) UIImage *monthImage;


@end

@implementation AXOverviewViewController
@synthesize dayEntryFetchedResultsController = __dayEntryFetchedResultsController;
@synthesize dayTypeFetchedResultsController = __dayTypeFetchedResultsController;
@synthesize workingWeekSettingFetchedResultsController = __workingWeekSettingFetchedResultsController;

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLS_TABDETAIL;
    self.view.backgroundColor = GLOBALBACKGROUNDCOLOR;
    
    self.aXDayEntriesListViewController = [AXDayEntriesListViewController new];
    self.aXTimeLineViewController = [AXTimeLineViewController new];

    self.loadingPage = NO;
    
    self.fromUserSettingsWorkingWeekArray = [[SettingsManager new] workingWeek];

    self.colorWorkingCellColor = GLOBALBACKGROUNDCOLOR;
    self.colorNotWorkingCellColor = NOTWORKINGCELLCOLOR;
    
    self.dayEntrySectionNames = [NSMutableArray new];
    self.dayTypeSectionNames = [NSMutableArray new];
    self.workingWeekSettingSectionNames = [NSMutableArray new];
    
    [self prepareDayEntryDataSource];
    [self prepareDayTypeDataSource];
    [self prepareWorkingWeekSettingDataSource];
    
    [self setupViewsAndConstraints];
    [self setupBarButtonItems];
    [self setupCalendManager];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(contextDidSave:)
     name:NSManagedObjectContextDidSaveNotification
     object:[[AXDataStore sharedInstance] managedObjectContext]];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(importDataFinished:)
     name:NOTIFICATION_IMPORTDATAFINISHED
     object:nil];
    [[NSUserDefaults standardUserDefaults]
     addObserver:self
     forKeyPath:@"settings_workingweek"
     options:NSKeyValueObservingOptionNew
     context:NULL];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(jumpToDate:)
     name:NOTIFICATION_JUMP_TO_DATE
     object:nil];
    
    self.curDaySelectionArray = [[NSMutableArray alloc] init];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSManagedObjectContextDidSaveNotification
     object:[[AXDataStore sharedInstance] managedObjectContext]];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NOTIFICATION_IMPORTDATAFINISHED
     object:nil];
    [[NSUserDefaults standardUserDefaults]
     removeObserver:self
     forKeyPath:@"settings_workingweek"];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NOTIFICATION_JUMP_TO_DATE
     object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self selectDate:self.selectedDateViewModel.currentlySelectedDate];
}

#pragma mark - setup methods

- (void)setupViewsAndConstraints {
    self.calendarMenuView = [JTCalendarMenuView new];
    self.calendarContentView = [JTHorizontalCalendarView new];
    self.calendarContentView.delegate = self;
    self.containerView = [UIView new];
    
    [self.view addSubview:_calendarMenuView];
    [self.view addSubview:self.calendarContentView];
    [self.view addSubview:self.containerView];
    
    self.calendarMenuView.translatesAutoresizingMaskIntoConstraints = NO;
    self.calendarContentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.calendarContentViewHeightConstraint = [self.calendarContentView.heightAnchor constraintEqualToConstant:300];
    [NSLayoutConstraint activateConstraints:@[
        [self.calendarMenuView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor],
        [self.calendarMenuView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.calendarMenuView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.calendarMenuView.heightAnchor constraintEqualToConstant:50],
        [self.calendarContentView.topAnchor constraintEqualToAnchor:self.calendarMenuView.bottomAnchor],
        [self.calendarContentView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.calendarContentView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        self.calendarContentViewHeightConstraint,
        [self.containerView.topAnchor constraintEqualToAnchor:self.calendarContentView.bottomAnchor],
        [self.containerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.containerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.containerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)setupCalendManager {
    self.calendarManager = [JTCalendarManager new];
    self.calendarManager.delegate = self;
    
    
    [self.calendarManager setMenuView:self.calendarMenuView];
    [self.calendarManager setContentView:self.calendarContentView];
    [self.calendarManager setDate:self.selectedDateViewModel.currentlySelectedDate];
    [self selectDate:self.selectedDateViewModel.currentlySelectedDate];
}

- (void)setupBarButtonItems {
    self.weekImage = [UIImage imageNamed:@"week"];
    self.monthImage = [UIImage imageNamed:@"month"];
    UIBarButtonItem *sideMenuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter"] style:UIBarButtonItemStylePlain target:self action:@selector(showSideMenu)];
    
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:NSLS_TODAY style:UIBarButtonItemStylePlain target:self action:@selector(today)];
    self.navigationItem.leftBarButtonItems = @[sideMenuButton, todayButton];
    
    self.switchViewButton = [[UIBarButtonItem alloc] initWithImage:self.weekImage style:UIBarButtonItemStylePlain target:self action:@selector(switchView)];
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItems = @[self.addButton, self.switchViewButton];
}

#pragma mark - barbuttonitem methods

- (void)switchView {
    self.calendarManager.settings.weekModeEnabled = !self.calendarManager.settings.weekModeEnabled;
//    [self.calendarManager reload];
    [self selectDate:self.selectedDateViewModel.currentlySelectedDate];

    CGFloat newHeight = 300;
    if(self.calendarManager.settings.weekModeEnabled){
        newHeight = 86;
        [self.switchViewButton setImage:self.monthImage];
    } else {
        [self.switchViewButton setImage:self.weekImage];
    }
    self.calendarContentViewHeightConstraint.constant = newHeight;
    [self.view layoutIfNeeded];
}

- (void)insertNewObject {
    if (![self allowedToCreateEntry]) {
        return;
    }
    AXDayEntryEditViewController *aXDayEntryEditViewController = [AXDayEntryEditViewController new];
    aXDayEntryEditViewController.dayEntry = nil;
    aXDayEntryEditViewController.newDayEntry = YES;
    aXDayEntryEditViewController.date = self.selectedDateViewModel.currentlySelectedDate;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:aXDayEntryEditViewController];
    navigationController.extendedLayoutIncludesOpaqueBars = YES;
    
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

- (void)showSideMenu {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)today {
    [self selectDate:[NSDate date]];
}

#pragma mark - CalendarManager delegate

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    JTCalendarDayView* dayView = (JTCalendarDayView*)gesture.view;
    NSDate *pressedDate = dayView.date;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    NSString *dateString = [formatter stringFromDate: pressedDate];
    
    
    
    if(UIGestureRecognizerStateBegan == gesture.state) {
        

        // Called on start of gesture, do work here
        os_log(OS_LOG_DEFAULT, "LONG PRESSS UIGestureRecognizerStateBegan");
        
        // Prepare the generator when the gesture begins.
        
        UIImpactFeedbackGenerator *myGen = [[UIImpactFeedbackGenerator alloc] initWithStyle:(UIImpactFeedbackStyleHeavy)];
        [myGen impactOccurred];
        myGen = NULL;
        
        // Do end work here when finger is lifted
        os_log(OS_LOG_DEFAULT, "LONG PRESSS UIGestureRecognizerStateEnded");
        os_log(OS_LOG_DEFAULT, " Date %@ long pressed", dateString);
        
        [self.curDaySelectionArray removeAllObjects];
        
        if(self.selectedDateViewModel.currentlySelectedDate){
            
            NSDate *selectedDate = self.selectedDateViewModel.currentlySelectedDate;
            
            os_log(OS_LOG_DEFAULT, " selected Date %@ ",[formatter stringFromDate: selectedDate]);
            NSDate *minDate;
            NSDate *maxDate;
            if( [pressedDate timeIntervalSinceDate:selectedDate] > 0 ) {
                minDate = selectedDate;
                maxDate = pressedDate;
            }else{
                minDate = pressedDate;
                maxDate = selectedDate;
            }
            
            [self.curDaySelectionArray addObject:minDate];
            
            // minDate and maxDate represent your date range
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
            NSDateComponents *days = [[NSDateComponents alloc] init];
            NSInteger dayCount = 0;
            while ( TRUE ) {
                [days setDay: ++dayCount];
                NSDate *date = [gregorianCalendar dateByAddingComponents: days toDate: minDate options: 0];
                if ( [date compare: maxDate] == NSOrderedDescending )
                    break;
                [self.curDaySelectionArray  addObject:date];
            }
            [self showDayArrayTypeChooserAlert];
        }
    }
    
    if(UIGestureRecognizerStateChanged == gesture.state) {
        // Do repeated work here (repeats continuously) while finger is down
        os_log(OS_LOG_DEFAULT, "LONG PRESSS UIGestureRecognizerStateChanged");
        // Trigger selection feedback.
        
        // Keep the generator in a prepared state.

    }
    
    /*
     
     */
    
    if(UIGestureRecognizerStateEnded == gesture.state) {
        
    }
}


// Customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView {
    // resetting
    //let longPressRecognizer = UILongPressGestureRecognizer(target: dayView, action: "longPressed:")
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.45;
    [dayView addGestureRecognizer:longPress];


    dayView.squareView.hidden = YES;
    dayView.squareView.backgroundColor = [UIColor clearColor];
    [dayView setDotViewColors:nil];
    dayView.squareView.layer.backgroundColor = [[UIColor clearColor] CGColor];
    dayView.squareView.layer.borderColor = [[UIColor clearColor] CGColor];
    dayView.circleView.hidden = YES;
    dayView.textLabel.textColor = [UIColor blackColor];

    // Today and in current month
    if ([self.calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date] &&
        [self.calendarManager.dateHelper date:self.calendarContentView.date isTheSameMonthThan:dayView.date]) {
        dayView.circleRatio = 0.55;
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = C_TODAY;
        dayView.textLabel.textColor = [UIColor whiteColor];

        // special case if today is also selected
        if (self.selectedDateViewModel.currentlySelectedDate &&
            [self.calendarManager.dateHelper date:self.selectedDateViewModel.currentlySelectedDate isTheSameDayThan:dayView.date]) {
            dayView.squareView.layer.borderColor = [C_SELECTEDDATE CGColor];
            dayView.squareView.layer.backgroundColor = [[UIColor clearColor] CGColor];
            dayView.squareView.hidden = NO;
        } else {
            dayView.squareView.hidden = YES;
        }
    }
    // Selected date
    else if (self.selectedDateViewModel.currentlySelectedDate &&
             [self.calendarManager.dateHelper date:self.selectedDateViewModel.currentlySelectedDate isTheSameDayThan:dayView.date]) {
        dayView.squareView.layer.borderColor = [C_SELECTEDDATE CGColor];
        dayView.squareView.layer.backgroundColor = [[UIColor clearColor] CGColor];
        dayView.squareView.hidden = NO;
    }

    // Other month RETURN
    if (![self.calendarManager.dateHelper date:self.calendarContentView.date isTheSameMonthThan:dayView.date]) {
        dayView.textLabel.textColor = C_NEXTMONTH;
        return;
    }
    
    NSArray<Project *> *projects = [DayEntry distinctParentProjectsForArray:[self dayEntriesForDate:dayView.date]];
    NSMutableArray<UIColor *> *colors = [NSMutableArray new];
    for (Project *project in projects) {
        if ([project color] != nil) {
            [colors addObject:[project color]];
        }
    }
    [dayView setDotViewColors:colors];

    if ([self haveDayTypeForDate:dayView.date]) {
        DayType *dayType = [self dayTypeForDate:dayView.date];
        if ([dayType isWork] &&
            ![dayType isVacation] &&
            ![dayType isSickness]) {
            dayView.textLabel.textColor = [UIColor blackColor];
        } else {
            dayView.squareView.backgroundColor = [dayType primaryColor];
            dayView.squareView.hidden = NO;
            dayView.textLabel.textColor = [UIColor whiteColor];
        }
        
        return; //DO NOT CHANGE the textlabel color LATER ON
    }
    
    // setNotWorkingColor
    if ([self isDateNotWorkingColor:dayView.date]) {
        dayView.textLabel.textColor = C_WEEKEND;
    }
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView {
    NSDate *currentDate = self.calendarContentView.date;
    NSDate *selectedDate = dayView.date;
    
    BOOL otherMonth = ![self.calendarManager.dateHelper date:currentDate isTheSameMonthThan:selectedDate];
    
    // Animation for the circleView
    // dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    
    if (otherMonth) {
        [UIView transitionWithView:dayView
                          duration:.25
                           options:0
                        animations:^{
                            // dayView.circleView.transform = CGAffineTransformIdentity;
                            
                            // Load the previous or next page if touch a day from another month
                            //                            if (otherMonth) {
                            if ([currentDate compare:selectedDate] == NSOrderedAscending) {
                                [self.calendarContentView loadNextPageWithInAnimation];
                            } else {
                                [self.calendarContentView loadPreviousPageWithInAnimation];
                            }
                            //                            }
                        } completion:^(BOOL finished) {
                            [self selectDate:selectedDate];
                        }];
    } else {
        [self selectDate:selectedDate];
    }
}

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar {
    self.loadingPage = YES;
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar {
    self.loadingPage = YES;
}

- (void)calendar:(JTCalendarManager *)calendar prepareMenuItemView:(UIView *)menuItemView date:(NSDate *)date {
    UILabel *label;
    if ([menuItemView isKindOfClass:[UILabel class]]) {
        label = (UILabel *)menuItemView;
        label.text = [[NSDateFormatter formatter_Month_Year_Static:YES] stringFromDate:date];
    }
}

#pragma mark - private methods

- (BOOL)isDateNotWorkingColor:(NSDate *)date {
    BOOL setNotWorkingColor = NO;
    NSArray<WorkingWeekSetting *> *workSettingsArray = [self.workingWeekSettingFetchedResultsController fetchedObjects];
    WorkingWeekSetting *workingWeekSetting = nil;
    
    if ([workSettingsArray count] != 0) {
        // TODO kann optimiert werden
        
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *yearNumber = [numberFormatter numberFromString:[date formatAs_yyyy]];
        NSNumber *monthNumber = [numberFormatter numberFromString:[date formatAs_MM]];
        NSNumber *dayNumber = [numberFormatter numberFromString:[date formatAs_dd]];
        
        // TODO kann optimiert werden
        NSArray *tempDayTypesArray = [workSettingsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"((year = %@) AND (month = %@) AND (day >= %@)) OR ((year = %@) AND (month > %@) AND (day >=%@))  OR ((year > %@) AND (month => %@) AND (day => %@))", yearNumber, monthNumber, dayNumber, yearNumber, monthNumber, [NSNumber numberWithInt:1], yearNumber, [NSNumber numberWithInt:1], [NSNumber numberWithInt:1]] ];
        
        if ([tempDayTypesArray count] != 0) {
            if ([tempDayTypesArray count] > 1) {
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"validUntil" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                NSArray *sortedArray = [tempDayTypesArray sortedArrayUsingDescriptors:sortDescriptors];
                
                workingWeekSetting = sortedArray[0];
            } else {
                workingWeekSetting = tempDayTypesArray[0];
            }
        }
    }
    
    // TODO kann optimiert werden
    NSCalendar *calendar = [NSCalendar defaultCalendar_Static:YES];

    NSDateComponents *components = [calendar components:CALENDARUNITCOMPONENTS fromDate:date];
    
    NSDate *tempDate =  [calendar dateFromComponents:components];
    NSDateComponents *tempComponents = [calendar components:NSCalendarUnitWeekday fromDate:tempDate];
    NSUInteger weekday = [tempComponents weekday];
    NSInteger position = [AXUtility standardizeWeekDayFromDateComponents:weekday];
    NSArray *settingsWorkingweek = nil;
    
    if (workingWeekSetting == nil) {
        settingsWorkingweek = self.fromUserSettingsWorkingWeekArray;
    } else {
        settingsWorkingweek = [workingWeekSetting workingWeek];
    }
    
    if (![((NSNumber *)settingsWorkingweek[position]) boolValue]) {
        setNotWorkingColor = YES;
    }
    
    return setNotWorkingColor;
}

- (void)selectDate:(NSDate *)date {
    self.selectedDateViewModel.currentlySelectedDate = date;
    [self tryToEnableAddButton];
    self.calendarManager.date = self.selectedDateViewModel.currentlySelectedDate;

//    if (!self.calendarManager.settings.weekModeEnabled) { // TODO enable later 
        [self displayDayEntriesListWithDate:date];
//    } else {
//        [self displayTimeLineViewController:date];
//    }
    
    [self.calendarManager reload];
}

- (BOOL)haveDayEntryForDate:(NSDate *)date {
    if ([self.dayEntrySectionNames containsObject:[date dayKey]]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)haveDayTypeForDate:(NSDate *)date {
    if ([self.dayTypeSectionNames containsObject:[date dayKey]]) {
        return YES;
    }
    
    return NO;
}

- (void)displayDayEntriesListWithDate:(NSDate *)date {
    if (!self.activeContainerViewController) {
        self.activeContainerViewController = self.aXDayEntriesListViewController;
    } else if (![self.activeContainerViewController isKindOfClass:[AXDayEntriesListViewController class]]){
        [self containerRemoveChildViewController:self.activeContainerViewController];
        self.activeContainerViewController = self.aXDayEntriesListViewController;
    }
    
    self.aXDayEntriesListViewController.date = date;

    if ([self haveDayEntryForDate:date]) {
        self.aXDayEntriesListViewController.entries = [NSMutableArray arrayWithArray:[self dayEntriesForDate:date]];
    } else {
        self.aXDayEntriesListViewController.entries = nil;
    }
    
    if ([self haveDayTypeForDate:date]) {
        DayType *dayType = [self dayTypeForDate:date];
        self.aXDayEntriesListViewController.dayType = dayType;
    } else {
        self.aXDayEntriesListViewController.working = ![self isDateNotWorkingColor:date];
        self.aXDayEntriesListViewController.dayType = nil;
    }
    
    [self.aXDayEntriesListViewController refresh];
    
    [self containerAddChildViewController:self.activeContainerViewController
                          toContainerView:self.containerView
                            useAutolayout:YES];
}

- (void)displayTimeLineViewController:(NSDate *)date {
    if (!self.activeContainerViewController) {
        self.activeContainerViewController = self.aXTimeLineViewController;
    } else if (![self.activeContainerViewController isKindOfClass:[AXTimeLineViewController class]]){
        [self containerRemoveChildViewController:self.activeContainerViewController];
        self.activeContainerViewController = self.aXTimeLineViewController;
    }
    
    self.aXTimeLineViewController.entries = [self dayEntriesForDate:date];
    self.aXTimeLineViewController.date = date;
    [self.aXTimeLineViewController refresh];
    
    [self containerAddChildViewController:self.activeContainerViewController
                          toContainerView:self.containerView
                            useAutolayout:YES];
}

- (void)getDayEntries {
    [self.fetchedDayEntries removeAllObjects];
    
    NSArray *results = [[AXDataStore sharedInstance] getListDayEntryForMonthInDetailView:self.selectedDateViewModel.currentlySelectedDate];
    if (results != nil && [results count] > 0) {
        for (DayEntry *dayEntry in results) {
            NSDateComponents *components = [[NSCalendar defaultCalendar_Static:YES]
                                            components:NSCalendarUnitDay
                                            fromDate:[dayEntry checkInTime]];
            NSMutableArray *array = [self.fetchedDayEntries objectForKey:[NSNumber numberWithInteger:[components day]]];
            if (array == nil) {
                NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:@[dayEntry]];
                [self.fetchedDayEntries setObject:newArray forKey:[NSNumber numberWithInteger:[components day]]];
            } else {
                [array addObject:dayEntry];
            }
        }
    }
}

- (NSArray<DayEntry *> *)dayEntriesForDate:(NSDate *)date {

    NSUInteger index = [self.dayEntrySectionNames indexOfObject:[date dayKey]];
    if (NSNotFound != index) {
        id<NSFetchedResultsSectionInfo> section = [self.dayEntryFetchedResultsController sections][index];
        
        return [section objects];
    }
    return nil;
}

- (DayType *)dayTypeForDate:(NSDate *)date {
    
    NSUInteger index = [self.dayTypeSectionNames indexOfObject:[date dayKey]];
    if (NSNotFound != index) {
        
        id<NSFetchedResultsSectionInfo> section = [self.dayTypeFetchedResultsController sections][index];
        
        return [section objects][0];
    }
    return nil;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.loadingPage) {
        NSDateComponents *components = [[NSCalendar defaultCalendar_Static:YES]
                                        components:CALENDARUNITCOMPONENTS
                                        fromDate:self.calendarManager.date];
        components.day = 1;
        NSDate *selectDate = [[NSCalendar defaultCalendar_Static:YES]
                              dateFromComponents:components];
        [self selectDate:selectDate];
        self.loadingPage = NO;
    }
}

- (void)tryToEnableAddButton {
    self.addButton.enabled = [self allowedToAdd];
}

- (BOOL)allowedToAdd {
    return [self allowedToCreateEntryFutureRule];
}

- (BOOL)allowedToCreateEntry {
    NSDate *currentDate = self.selectedDateViewModel.currentlySelectedDate;
    
    NSArray<DayEntry *> *entries = [self dayEntriesForDate:currentDate];
    DayEntry *lastEntry = entries[[entries count] - 1];
    
    if (lastEntry) {
        if (lastEntry.checkOutTime == nil ||
            ![lastEntry.checkOutTime isSameDay:currentDate
                      withReceiverTimeZoneName:lastEntry.checkInTimeZone
                          andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS_WARNINGPOPUP
                                                                message:NSLS_CANTADD_INCOMPLETE
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLS_OKPOPUP, nil];
                [alert show];
                return NO;
            }
    }
    
    
    DayEntry *tempDayEntry = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:currentDate];
    
    // dayentry cuts over several days
    if (![tempDayEntry.checkInTime isSameDay:currentDate] && [tempDayEntry.checkInTime compare:currentDate] == NSOrderedAscending &&
        ![tempDayEntry.checkOutTime isSameDay:currentDate] && [tempDayEntry.checkOutTime compare:currentDate] == NSOrderedDescending) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS_WARNINGPOPUP
                                                        message:NSLS_CANTCREATEENTRY
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLS_OKPOPUP, nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

- (BOOL)allowedToCreateEntryFutureRule {
    NSDate *currentDate = self.selectedDateViewModel.currentlySelectedDate;
    NSDate *nowDate = [NSDate date];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS_WARNINGPOPUP message:NSLS_FUTURERULE delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLS_OKPOPUP, nil];
//    [alert show];
    if ([currentDate compare:nowDate] == NSOrderedDescending) {
        return NO;
    }
    return YES;
}


#pragma mark - NSFetchedResultsController methods

- (NSFetchedResultsController *)dayEntryFetchedResultsController {
    if (__dayEntryFetchedResultsController != nil) {
        return __dayEntryFetchedResultsController;
    }
    
    self.dayEntryFetchedResultsController = [[AXDataStore sharedInstance] getAllDayEntryEntitiesHonouringFilter];
    self.dayEntryFetchedResultsController.delegate = self;
    
    return __dayEntryFetchedResultsController;
}

- (NSFetchedResultsController *)dayTypeFetchedResultsController {
    if (__dayTypeFetchedResultsController != nil) {
        return __dayTypeFetchedResultsController;
    }
    
    self.dayTypeFetchedResultsController = [[AXDataStore sharedInstance] getAllDayTypeEntities];
    self.dayTypeFetchedResultsController.delegate = self;
    
    return __dayTypeFetchedResultsController;
}

- (NSFetchedResultsController *)workingWeekSettingFetchedResultsController {
    if (__workingWeekSettingFetchedResultsController != nil) {
        return __workingWeekSettingFetchedResultsController;
    }
    
    self.workingWeekSettingFetchedResultsController = [[AXDataStore sharedInstance] getAllWorkingWeekSettingEntities];
    self.workingWeekSettingFetchedResultsController.delegate = self;
    
    return __workingWeekSettingFetchedResultsController;
}

//- (NSFetchedResultsController *)projectsFetchedResultsController {
//    if (__projectsFetchedResultsController != nil) {
//        return __projectsFetchedResultsController;
//    }
//    
//    self.projectsFetchedResultsController = [[AXDataStore sharedInstance] getAllProjects];
//    self.projectsFetchedResultsController.delegate = self;
//    
//    return __projectsFetchedResultsController;
//}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
//    UITableView *tableView = self.tableView;
//    
//    switch (type) {
//        case NSFetchedResultsChangeInsert :
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete :
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate :
//            //TODO
////            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//        case NSFetchedResultsChangeMove :
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView endUpdates];

    if ([controller isEqual:self.dayEntryFetchedResultsController]) {
        [self prepareDayEntryDataSource];
    } else if([controller isEqual:self.dayTypeFetchedResultsController]) {
        [self prepareDayTypeDataSource];
    } else if ([controller isEqual:self.workingWeekSettingFetchedResultsController]) {
        [self prepareWorkingWeekSettingDataSource];
    }
//    else if  ([controller isEqual:self.projectsFetchedResultsController]) {
//
//    }
    
    [self selectDate:self.selectedDateViewModel.currentlySelectedDate];
}

#pragma mark - notification methods

- (void)importDataFinished:(NSNotification *)notification {
    self.dayTypeFetchedResultsController = nil;
    self.workingWeekSettingFetchedResultsController = nil;
    self.dayEntryFetchedResultsController = nil;
//    self.projectsFetchedResultsController = nil;
    [self prepareDayEntryDataSource];
    [self prepareDayTypeDataSource];
    [self prepareWorkingWeekSettingDataSource];
    [self selectDate:self.selectedDateViewModel.currentlySelectedDate];
}

- (void)contextDidSave:(NSNotification *)notification {
    NSSet *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    
    //    NSLog(@"insertObjects: %@", [insertedObjects description]);
    //    NSLog(@"deletedObjects: %@", [deletedObjects description]);
    //    NSLog(@"updatedObjects: %@", [updatedObjects description]);
    
    BOOL projectsChanged = NO;
    for (NSManagedObject *object in deletedObjects) {
        if ([object isKindOfClass:[Project class]]) {
            projectsChanged = YES;
        }
    }
    
    for (NSManagedObject *object in insertedObjects) {
        if ([object isKindOfClass:[Project class]]) {
            projectsChanged = YES;
        }
    }
    
    for (NSManagedObject *object in updatedObjects) {
        if ([object isKindOfClass:[Project class]]) {
            projectsChanged = YES;
        }
    }
    
    if (projectsChanged) {
        self.dayEntryFetchedResultsController = nil;
        [self prepareDayEntryDataSource];
        [self selectDate:self.selectedDateViewModel.currentlySelectedDate];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqual:@"settings_workingweek"]) {
        self.fromUserSettingsWorkingWeekArray = [[SettingsManager new] workingWeek];
        [self prepareWorkingWeekSettingDataSource];
        [self selectDate:self.selectedDateViewModel.currentlySelectedDate];
    }
}

- (void)jumpToDate:(NSNotification *)notification {
    NSDate *date;
    
    if ([notification.object isKindOfClass:[NSDate class]]) {
        date = (NSDate *)notification.object;
    }
    
    if (date) {
        [self selectDate:date];
    }
}

#pragma mark - data source

- (void)prepareDayEntryDataSource {
    [self.dayEntrySectionNames removeAllObjects];
    if ([[self.dayEntryFetchedResultsController sections] count] > 0) {
        for (id<NSFetchedResultsSectionInfo> object in [self.dayEntryFetchedResultsController sections]) {
            [self.dayEntrySectionNames addObject:[object name]];
        }
    }
}

- (void)prepareDayTypeDataSource {
    [self.dayTypeSectionNames removeAllObjects];
    if ([[self.dayTypeFetchedResultsController sections] count] > 0) {
        for (id<NSFetchedResultsSectionInfo> object in [self.dayTypeFetchedResultsController sections]) {
            [self.dayTypeSectionNames addObject:[object name]];
        }
    }
}

- (void)prepareWorkingWeekSettingDataSource {
    [self.workingWeekSettingSectionNames removeAllObjects];
    if ([[self.workingWeekSettingFetchedResultsController sections] count] > 0) {
        for (id<NSFetchedResultsSectionInfo> object in [self.workingWeekSettingFetchedResultsController sections]) {
            [self.workingWeekSettingSectionNames addObject:[object name]];
        }
    }
}

@end
