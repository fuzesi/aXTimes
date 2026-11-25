//
//  AXAppDelegate.m
//  aXTimes
//
//  Created by fuesec on 4/27/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//



#import "AXAppDelegate.h"

#import "NSString+AXNSStringCategory.h"
#import "NSNumber+AXNSNumberCategory.h"
#import "AXAttendanceRecorder.h"
#import "NSCalendar+AXNSCalendarCategory.h"


#import <os/log.h>

static NSString *kReadPasteboardDataQuery = @"readPasteboardData";

@interface AXAppDelegate ()

@property (strong, nonatomic) SettingsManager *settingsManager;

@end

@interface AXTimesSceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation AXAppDelegate

@synthesize window = _window;

#pragma mark application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    application.applicationSupportsShakeToEdit = YES;
    self.settingsManager = [SettingsManager new];
    [AXDataStore sharedInstance];
    if (![self setupBasicProject]) {
        [self setupBasicProject];
    }

    [self.settingsManager setupInitialWithForce:NO];
    [self setupApperance];
    
    [self.settingsManager defaultProjectCheck];

//	NSArray *allDayEntries = [[AXDataStore sharedInstance] getAllManagedObjectsForClass:[DayEntry class]];
//    for (DayEntry *entry in allDayEntries) {
////        entry.hourlyWage = @(170);
//        NSLog(@"%@", JSONDictionary);
//    }

//    NSArray *aasdf = [[AXDataStore sharedInstance] getAllManagedObjectsForClass:[DefaultPauseSetting class]];
//    for (DefaultPauseSetting *asdf in aasdf ) {
//        DebugLog(@"%@", asdf);
//    }

    [IAPProducts store];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(contextDidSave:)
     name:NSManagedObjectContextDidSaveNotification
     object:[[AXDataStore sharedInstance] managedObjectContext]];

    [WatchCommunication shared].appDelegate = self;

	return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)session options:(UISceneConnectionOptions *)options {
    UISceneConfiguration *configuration = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:session.role];
    configuration.delegateClass = [AXTimesSceneDelegate class];
    return configuration;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self writeToSharedSpace];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	// Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - appearance methods

- (void)setupApperance {
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Picker views
    [[UITableView appearanceWhenContainedIn:[UIPickerView class], nil]
     setBackgroundColor:[UIColor clearColor]];
//    [[UILabel appearanceWhenContainedIn:[UIPickerView class], nil]
//     setTextColor:[UIColor blackColor]];
    [[UIPickerView appearance] setBackgroundColor:GLOBALBACKGROUNDCOLOR];
    
    // Tabbar
    [[UITabBar appearance] setTintColor:SELECTIONCOLOR];
    [[UITabBar appearance] setBarTintColor:GLOBALBACKGROUNDCOLOR];

    // UIBarButtonItems
    [[UIBarButtonItem appearance] setTintColor:GLOBALBACKGROUNDCOLOR];
    
    // Navigationbar
    [[UINavigationBar appearance] setBarTintColor:SELECTIONCOLOR]; // background
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:GLOBALBACKGROUNDCOLOR forKey:NSForegroundColorAttributeName]];
    [[UINavigationBar appearance] setTintColor:GLOBALBACKGROUNDCOLOR];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:GLOBALBACKGROUNDCOLOR];
    [UINavigationBar appearance].translucent = NO;
    
    // other
    [[UITableView appearance] setBackgroundColor:GLOBALBACKGROUNDCOLOR2];
    [[UITextField appearance] setTextColor:GLOBALFONTCOLOR];
    [[UITextView appearance] setBackgroundColor:GLOBALBACKGROUNDCOLOR];
    [[UITableViewCell appearance] setBackgroundColor:GLOBALBACKGROUNDCOLOR];
    [[UITableViewCell appearance] setTintColor:SELECTIONCOLOR];
    [[UILabel appearance] setHighlightedTextColor:GLOBALFONTCOLOR];
    [[UISegmentedControl appearance] setTintColor:SELECTIONCOLOR];
}

#pragma mark - settings setup

- (BOOL)setupBasicProject {
    if ([[AXDataStore sharedInstance] getBasicProject]) {
        return YES;
    }
    
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [[AXDataStore sharedInstance] turnIntoChildContext:childContext];
    Project *basicProject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Project class]) inManagedObjectContext:childContext];
    basicProject.name = BASIC_GLOBAL_PROJECT_NAME;
    basicProject.projectDescription = @"";
    basicProject.hourlyWage = [NSDecimalNumber zero];
    
    basicProject.defaultComment = @"";
    basicProject.colourAsHex = @"#359BA5"; // our selection color
    
    //net rounding
    basicProject.roundingBehaviour = [NSNumber numberWithUnsignedInteger:RoundingBehaviourDefault];
    
    //timeunit
    basicProject.timeUnit = WORKTIMEUNITS[0];
    
    basicProject.position = @(-1);
    
    //currently the project we want to check-in on
    basicProject.defaultProject = @YES;
    
    //only basic project which should not be deleted
    basicProject.basicProject = @YES;
    
    //kein Budget für dieses Projekt
    basicProject.budget = nil;
    
    //dieses projekt ist immer aktiv
    basicProject.active = @YES;
    
    basicProject.code = @"";
    
    basicProject.useSubProjectsBudget = @NO;
    basicProject.filterActive = @YES;
    basicProject.partialFilterActive = @YES;
    
    NSDate *date = [NSDate date];
    basicProject.creationDate = date;
    basicProject.lastModifiedDate = date;
    basicProject.identifier = [[NSUUID UUID] UUIDString];
    
    NSError *error = nil;
    BOOL result = [[basicProject managedObjectContext] save:&error];
    if (!result) {
        NSLog(@"Error: %@ %@", error, [error userInfo]);
    }
    return result;
}

#pragma mark - shared space

- (void)writeToSharedSpace {
    NSString *suiteName = [NSString stringWithFormat:@"group.%@", [[NSBundle mainBundle] bundleIdentifier]];
    os_log(OS_LOG_DEFAULT, "suiteName:: %@", suiteName);

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];

    [userDefaults removeObjectForKey:@"checkInTime"];
    [userDefaults removeObjectForKey:@"checkOutTime"];
    [userDefaults removeObjectForKey:@"startTime"];
    [userDefaults removeObjectForKey:@"checkInTimeZone"];
    [userDefaults removeObjectForKey:@"checkOutTimeZone"];
    [userDefaults removeObjectForKey:@"comment"];
    [userDefaults removeObjectForKey:@"secondsPaused"];
    [userDefaults removeObjectForKey:@"checkoutTimeString"];
    
    [userDefaults removeObjectForKey:@"hourlyWage"];
    [userDefaults removeObjectForKey:@"currency"];
    [userDefaults removeObjectForKey:@"checkoutSalaryString"];
    
    NSDate *nowDate = [NSDate date];
    
    //for case if user has not worked yet [NSString stringWithFormat:@" 0%@00", [[NSNumberFormatter new] decimalSeparator]];
    
    DayEntry *dayEntry = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:nowDate];
    BOOL noPause = YES;
    
    if (dayEntry != nil) {
        if (dayEntry.checkInTime != nil && dayEntry.checkOutTime == nil) {
            // currently checked in
            [userDefaults setObject:dayEntry.checkInTime forKey:@"checkInTime"];
            [userDefaults setObject:dayEntry.checkInTimeZone forKey:@"checkInTimeZone"];
            
            Pause *pause = [dayEntry lastSortedPause];
            if (pause != nil && pause.startTime != nil && pause.endTime == nil) {
                // there is currently a pause running
                noPause = NO;
                NSString *checkoutSalaryString = [dayEntry incomeUntilNowDisplayValue];
                [userDefaults setObject:checkoutSalaryString forKey:@"checkoutSalaryString"]; // since salary wont change during a pause
                [userDefaults setObject:pause.startTime forKey:@"startTime"];
            }
            
        } else if (dayEntry.checkInTime != nil &&
                   dayEntry.checkOutTime != nil){
            // there is a last dayentry but user already checked out
            [userDefaults setObject:dayEntry.checkInTime forKey:@"checkInTime"];
            [userDefaults setObject:dayEntry.checkInTimeZone forKey:@"checkInTimeZone"];
            [userDefaults setObject:dayEntry.checkOutTime forKey:@"checkOutTime"];
            [userDefaults setObject:dayEntry.checkOutTimeZone forKey:@"checkOutTimeZone"];
            NSDecimalNumber *value = [[dayEntry netMinutes] decimalNumberByMultiplyingBy:[NSDecimalNumber sixty]];
            NSString *checkoutTimeString = [value numberAsSecondsToCountdownString];
            [userDefaults setObject:checkoutTimeString forKey:@"checkoutTimeString"];
            
            NSString *checkoutSalaryString = [dayEntry incomeDisplayValueForCounter];
            [userDefaults setObject:checkoutSalaryString forKey:@"checkoutSalaryString"];
        }
        
        if ((dayEntry.checkInTime != nil && dayEntry.checkOutTime != nil) || (dayEntry.checkInTime != nil && dayEntry.checkOutTime == nil && noPause)) {
            NSNumber *secondsPausedNumber = [NSNumber numberWithDouble:[[dayEntry minutesPausedNotZeroed] doubleValue] * 60];
            [userDefaults setObject:secondsPausedNumber forKey:@"secondsPaused"];
        }
        
        if (dayEntry.comment && ![[dayEntry.comment trim] isEqualToString:@""]) {
            [userDefaults setObject:dayEntry.comment forKey:@"comment"];
        }
        
        if (dayEntry.hourlyWage) {
            [userDefaults setObject:dayEntry.actualHourlyWage forKey:@"hourlyWage"];
        }
        
        [userDefaults setObject:[self.settingsManager currencyIso] forKey:@"currency"];
    }

    NSDictionary *dataToSend = [userDefaults dictionaryRepresentation];
    [[WatchCommunication shared] updateApplicationContext:dataToSend error:NULL];
    
    BOOL success = [userDefaults synchronize];
    if (!success) {
        DebugLog(@"Failed to synchronize");
    }
}

- (NSDictionary *)prepareDictionaryForSharedSpace:(DayEntry *)dayEntry {
    //    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.aximilate.axtimes"];
    NSMutableDictionary *userDefaults = [NSMutableDictionary new];
    
    BOOL noPause = YES;
    
    if (dayEntry != nil) {
        if (dayEntry.checkInTime != nil && dayEntry.checkOutTime == nil) {
            // currently checked in
            [userDefaults setObject:dayEntry.checkInTime forKey:@"checkInTime"];
            [userDefaults setObject:dayEntry.checkInTimeZone forKey:@"checkInTimeZone"];
            
            Pause *pause = [dayEntry lastSortedPause];
            if (pause != nil && pause.startTime != nil && pause.endTime == nil) {
                // there is currently a pause running
                noPause = NO;
                NSString *checkoutSalaryString = [dayEntry incomeUntilNowDisplayValue];
                [userDefaults setObject:checkoutSalaryString forKey:@"checkoutSalaryString"]; // since salary wont change during a pause
                [userDefaults setObject:pause.startTime forKey:@"startTime"];
            }
            
        } else if (dayEntry.checkInTime != nil &&
                   dayEntry.checkOutTime != nil){
            // there is a last dayentry but user already checked out
            [userDefaults setObject:dayEntry.checkInTime forKey:@"checkInTime"];
            [userDefaults setObject:dayEntry.checkInTimeZone forKey:@"checkInTimeZone"];
            [userDefaults setObject:dayEntry.checkOutTime forKey:@"checkOutTime"];
            [userDefaults setObject:dayEntry.checkOutTimeZone forKey:@"checkOutTimeZone"];
            NSDecimalNumber *value = [[dayEntry netMinutes] decimalNumberByMultiplyingBy:[NSDecimalNumber sixty]];
            NSString *checkoutTimeString = [value numberAsSecondsToCountdownString];
            [userDefaults setObject:checkoutTimeString forKey:@"checkoutTimeString"];
            
            NSString *checkoutSalaryString = [dayEntry incomeDisplayValueForCounter];
            [userDefaults setObject:checkoutSalaryString forKey:@"checkoutSalaryString"];
        }
        
        if ((dayEntry.checkInTime != nil && dayEntry.checkOutTime != nil) || (dayEntry.checkInTime != nil && dayEntry.checkOutTime == nil && noPause)) {
            NSNumber *secondsPausedNumber = [NSNumber numberWithDouble:[[dayEntry minutesPausedNotZeroed] doubleValue] * 60];
            [userDefaults setObject:secondsPausedNumber forKey:@"secondsPaused"];
        }
        
        if (dayEntry.comment && ![[dayEntry.comment trim] isEqualToString:@""]) {
            [userDefaults setObject:dayEntry.comment forKey:@"comment"];
        }
        
        if (dayEntry.hourlyWage) {
            [userDefaults setObject:dayEntry.actualHourlyWage forKey:@"hourlyWage"];
        }

        [userDefaults setObject:[self.settingsManager currencyIso] forKey:@"currency"];
    }
    
    return userDefaults;
}

#pragma mark - apple watch callback

- (void)didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *action = message[@"action"];
        NSDate *nowDate = [NSDate date];
        DayEntry *entry = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:nowDate];
        BOOL changedData = NO;

        if ([action isEqualToString:@"checkIn"]) {
            // sanity checks
            if ((entry != nil &&
                 entry.checkInTime != nil &&
                 entry.checkOutTime != nil) ||
                entry == nil) {
                // sanity guaranteed

                entry = [[[AXDataStore sharedInstance] managedObjectContext] newDayEntryEntityWithStart:nowDate];
                [AXAttendanceRecorder
                 performCheckInForEntry:entry
                 withTime:nowDate
                 withProject:nil];
                changedData = YES;
            }
        } else if ([action isEqualToString:@"checkOut"]) {
            // sanity checks
            if (entry != nil &&
                entry.checkInTime != nil &&
                entry.checkOutTime == nil) {
                Pause *pause = [entry lastSortedPause];

                if ((pause != nil &&
                     pause.startTime != nil &&
                     pause.endTime != nil) ||
                    pause == nil) {
                    // sanity guaranteed
                    [AXAttendanceRecorder performCheckOutForEntry:entry
                                                         withTime:nowDate];
                    changedData = YES;
                }
            }
        } else if ([action isEqualToString:@"pauseIn"]) {
            // sanity checks
            if (entry != nil &&
                entry.checkInTime != nil &&
                entry.checkOutTime == nil) {
                Pause *pause = [entry lastSortedPause];

                if ((pause != nil &&
                     pause.startTime != nil &&
                     pause.endTime != nil) ||
                    pause == nil) {
                    // sanity guaranteed
                    Pause *pause = [entry.managedObjectContext newPauseEntityWithStart:nowDate];
                    [entry addPausesObject:pause];
                    changedData = YES;
                }
            }
        } else if ([action isEqualToString:@"pauseOut"]) {
            // sanity checks
            if (entry != nil &&
                entry.checkInTime != nil &&
                entry.checkOutTime == nil) {
                Pause *pause = [entry lastSortedPause];

                if (pause != nil &&
                    pause.startTime != nil &&
                    pause.endTime == nil) {
                    // sanity guaranteed
                    [AXAttendanceRecorder finishPause:pause atTime:nowDate];
                    changedData = YES;
                }
            }
        } else if ([action isEqualToString:@"load"]) {
            replyHandler([self prepareDictionaryForSharedSpace:entry]);
            return;
        }


        if (changedData) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OUTSIDECHANGE_OCCURED object:nil];
            replyHandler([self prepareDictionaryForSharedSpace:entry]);
            [self writeToSharedSpace];
        } else {
            replyHandler([self prepareDictionaryForSharedSpace:entry]);
        }
    });
}

#pragma mark - import callback

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    DebugLog(@"Application launched with URL: %@", url);
    if ([sourceApplication hasPrefix:@"com.aximilate"]) {
        if ([[url query] isEqualToString:kReadPasteboardDataQuery]) {
            [self handleImportOldData:url];
            return YES;
        }
    } else {
        [self handleRestoreBackup:url];
        return YES;
    }
    return NO;
}

#pragma mark - private methods

- (void)contextDidSave:(NSNotification *)notification {
    NSSet *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    
//    NSLog(@"insertObjects: %@", [insertedObjects description]);
//    NSLog(@"deletedObjects: %@", [deletedObjects description]);
//    NSLog(@"updatedObjects: %@", [updatedObjects description]);
    
    NSDate *nowDate = [NSDate date];
    DayEntry *entry = [[AXDataStore sharedInstance] previousDayEntryWithCheckinLesser:nowDate];
    BOOL writeChangesToSharedSpace = NO;
    
    for (NSManagedObject *object in deletedObjects) {
        if ([object isKindOfClass:[DayEntry class]]) {
            DayEntry *dayEntry = (DayEntry *)object;
            if ([dayEntry isEqual:entry]) {
                writeChangesToSharedSpace = YES;
            }
        }
    }
    
    for (NSManagedObject *object in insertedObjects) {
        if ([object isKindOfClass:[DayEntry class]]) {
            DayEntry *dayEntry = (DayEntry *)object;
            if ([dayEntry isEqual:entry]) {
                writeChangesToSharedSpace = YES;
            }
        }
    }
    
    for (NSManagedObject *object in updatedObjects) {
        if ([object isKindOfClass:[DayEntry class]]) {
            DayEntry *dayEntry = (DayEntry *)object;
            if ([dayEntry isEqual:entry]) {
                writeChangesToSharedSpace = YES;
            }
        }
    }
    
    if (writeChangesToSharedSpace) {
        [self writeToSharedSpace];
    }
}

@end

@implementation AXTimesSceneDelegate
- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)options {
    if (![scene isKindOfClass:[UIWindowScene class]]) return;
    AXAppDelegate *delegate = (AXAppDelegate *)UIApplication.sharedApplication.delegate;
    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    self.window.rootViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateInitialViewController];
    delegate.window = self.window;
    [self.window makeKeyAndVisible];

}
- (void)sceneWillResignActive:(UIScene *)scene {
    [(AXAppDelegate *)UIApplication.sharedApplication.delegate applicationWillResignActive:UIApplication.sharedApplication];
}
@end
