//
//  AXDataStore.m
//  aXTimes
//
//  Created by fuesec on 5/9/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXDataStore.h"

#import "NSDate+AXNSDateCategory.h"
#import "NSString+AXNSStringCategory.h"
#import "NSCalendar+AXNSCalendarCategory.h"

@interface AXDataStore ()
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSPersistentStore *oldStore;
@property (strong, nonatomic) NSURL *oldStoreURL;


@end

NSString *const dataModelName = @"DataModel";
NSString *const storeName = @"aXTimes.sqlite";
NSString *const databasePathExtension = @"sqlite";
NSString *const storeNameWithoutFileExtension = @"aXTimes";
NSString *const remoteStoreNameWithoutFileExtension = @"aXTimesRemoteStore";
NSString *const persistentStoreUbiquitousContentNameKey =  @"iCloud_aXTimes";

@implementation AXDataStore
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

static AXDataStore *sharedInstance = nil; // Singleton

#pragma mark - lifecycle methods
+ (AXDataStore *)sharedInstance {
	DEFINE_SHARED_INSTANCE_USING_BLOCK (^{
											sharedInstance = [self new];
											return sharedInstance;
										});
}

- (id)init {
	self = [super init];

	if (self) {
        [self setupObservers];
	}

	return self;
}

- (void)dealloc {
    [self removeAllObservers];
}

- (void)setupObservers {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleDataModelChange:)
     name:NSManagedObjectContextObjectsDidChangeNotification
     object:[self managedObjectContext]];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(contextDidSave:)
     name:NSManagedObjectContextDidSaveNotification
     object:[self managedObjectContext]];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(contextWillSave:)
     name:NSManagedObjectContextWillSaveNotification
     object:[self managedObjectContext]];
}

- (void)removeAllObservers {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSManagedObjectContextObjectsDidChangeNotification
     object:[self managedObjectContext]];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSManagedObjectContextDidSaveNotification
     object:[self managedObjectContext]];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSManagedObjectContextWillSaveNotification
     object:[self managedObjectContext]];
}

- (NSURL *)localStoreURL {
    return [[[self applicationDocumentsDirectory]
             URLByAppendingPathComponent:storeNameWithoutFileExtension isDirectory:NO]
            URLByAppendingPathExtension:databasePathExtension];
}

- (NSMutableDictionary *)basicPersistentStoreOptions {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:
                                       @{ NSInferMappingModelAutomaticallyOption : @YES,
                                          NSMigratePersistentStoresAutomaticallyOption : @YES, }];
    return dictionary;
}

#pragma mark - public methods
// http://stackoverflow.com/questions/3256195/how-to-deal-with-temporary-nsmanagedobject-instances
- (NSManagedObject *)temporayManagedObjectForClass:(Class)clazz {
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(clazz) inManagedObjectContext:self.managedObjectContext];
	NSManagedObject *unassociatedObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];

	return unassociatedObject;
}

// http://stackoverflow.com/questions/3256195/how-to-deal-with-temporary-nsmanagedobject-instances
- (void)insertDetachedObject:(NSManagedObject *)object {
    NSManagedObjectContext *context = [self managedObjectContext];

    [context insertObject:object];
}

// http://stackoverflow.com/questions/5035057/how-to-get-core-data-object-from-specific-object-id
- (NSManagedObject *)fetchObjectWithManagedObjectIDWithChildContext:(NSManagedObjectID *)objectID andContext:(NSManagedObjectContext *)childContext {
    if (childContext.parentContext == nil) {
        NSManagedObjectContext *context = [self managedObjectContext];
        childContext.parentContext = context;
    }
    
    NSError *error = nil;
    NSManagedObject *returnObject = nil;
    returnObject = [childContext existingObjectWithID:objectID error:&error];
    return returnObject;
    //might be interesting in future http://www.cocoawithlove.com/2008/08/safely-fetching-nsmanagedobject-by-uri.html
}

- (void)turnIntoChildContext:(NSManagedObjectContext *)childContext{
    NSManagedObjectContext *context = [self managedObjectContext];
    childContext.parentContext = context;
}


// for future to merge changes http://stackoverflow.com/questions/6969034/how-do-we-prevent-coredata-could-not-fulfill-a-fault

- (void)deleteObject:(NSManagedObject *)object {
	NSManagedObjectContext *context = [self managedObjectContext];

	[context deleteObject:object];
}

- (NSArray *)getAllManagedObjectsForClass:(Class)clazz {
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(clazz) inManagedObjectContext:self.managedObjectContext];

	[fetchRequest setEntity:entity];

	NSError *error = nil;
	NSArray *fetchedResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedResults == nil) {
		NSLog(@"%@", [error debugDescription]);
		return nil;
	} else {
		return fetchedResults;
	}
}

- (NSUInteger)getCountForAllManagedObjectsForClass:(Class)clazz {
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(clazz) inManagedObjectContext:self.managedObjectContext];

	[fetchRequest setEntity:entity];

	NSError *error = nil;
	NSInteger entityCount = 0;
	entityCount = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];

	if (entityCount == NSNotFound) {
		DebugLog(@"%@",
                 [error debugDescription]);
		return 0;
	} else {
		return entityCount;
	}
}

- (NSArray *)getListDayEntriesDateBetween:(NSDate *)fromDate andDate:(NSDate *)toDate {
	return [self standardFetchWithBeginDate:fromDate andEndDate:toDate];
}

- (NSArray<DayEntry *> *)getDayEntriesForDate:(NSDate *)date {
	NSCalendar *cal = [NSCalendar defaultCalendar_Static:YES];
	NSDateComponents *components = [cal components:CALENDARUNITCOMPONENTS fromDate:date];

	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];

	NSDate *todayMidnightDate = [cal dateFromComponents:components];

	[components setHour:23];
	[components setMinute:59];
	[components setSecond:59];

	NSDate *todayEndDate =  [NSDate dateWithTimeInterval:0.999 sinceDate:[cal dateFromComponents:components]];

	NSArray *fetchedObjects = [self standardFetchWithBeginDate:todayMidnightDate andEndDate:todayEndDate];

	if (fetchedObjects == nil) {
		return nil;
	} else if ([fetchedObjects count] == 0) {
		return fetchedObjects;
	}
	return fetchedObjects;
}

- (NSArray *)standardFetchWithBeginDate:(NSDate *)checkInDate andEndDate:(NSDate *)checkOutDate {
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:NSStringFromClass([DayEntry class])
                                   inManagedObjectContext:self.managedObjectContext];

	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"((checkInTime >= %@) AND (checkInTime <= %@))",
                              checkInDate,
                              checkOutDate];
	[fetchRequest setPredicate:predicate];
    
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"checkInTime"
                                        ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];

	NSError *error = nil;
	NSArray *fetchedResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedResults == nil) {
		NSLog(@"%@", [error debugDescription]);
		return nil;
	} else {
		return fetchedResults;
	}
}

- (NSArray *)getListDayEntryForMonthInDetailView:(NSDate *)date {
    NSCalendar *cal = [NSCalendar defaultCalendar_Static:YES];

	NSDateComponents *components = [cal components:CALENDARUNITCOMPONENTS fromDate:date];

	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	[components setDay:1];

	NSDate *monthStart = [cal dateFromComponents:components];

	[components setHour:23];
	[components setMinute:59];
	[components setSecond:59];

	NSRange days = [cal rangeOfUnit:NSCalendarUnitDay
							 inUnit:NSCalendarUnitMonth
							forDate:date];

	[components setDay:days.length];

	NSDate *monthEnd = [NSDate dateWithTimeInterval:0.999 sinceDate:[cal dateFromComponents:components]];

	return [self standardFetchWithBeginDate:monthStart andEndDate:monthEnd];
}

#pragma mark - working week settings methods
- (NSArray *)getListWorkingWeekSettingsForDate:(NSDate *)date {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];

	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setLocale:[NSLocale currentLocale]];
	[dateFormatter setDateFormat:@"yyyy"];
	NSNumber *yearNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:date]];
	[dateFormatter setDateFormat:@"MM"];
	NSNumber *monthNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:date]];
	[dateFormatter setDateFormat:@"dd"];
	NSNumber *dayNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:date]];

	NSString *predicateForDate = [NSString stringWithFormat:@"((year = %@) AND (month = %@) AND (day >= %@)) OR ((year = %@) AND (month > %@) AND (day >=%@))  OR ((year > %@) AND (month => %@) AND (day => %@))",
                                  yearNumber,
                                  monthNumber,
                                  dayNumber,
                                  yearNumber,
                                  monthNumber,
                                  @1,
                                  yearNumber,
                                  @1,
                                  @1];

	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([WorkingWeekSetting class])
                                              inManagedObjectContext:self.managedObjectContext];

	[fetchRequest setEntity:entity];

	NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"validUntil" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateSort]];

	//	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%@ <= validUntil)", date];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateForDate];
	[fetchRequest setPredicate:predicate];

	NSError *error = nil;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

	if (fetchedObjects == nil) {
		NSLog(@"%@", [error debugDescription]);
		return nil;
	} else {
		return fetchedObjects;
	}
}

- (NSArray *)standardSummaryFetchWorkingWeekSettingsWithPredicate:(NSString *)predicate {
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([WorkingWeekSetting class]) inManagedObjectContext:self.managedObjectContext];

	[fetchRequest setEntity:entity];

	NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateSort]];
	NSPredicate *tempPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@", predicate]];

	[fetchRequest setPredicate:tempPredicate];

	NSError *error = nil;
	NSArray *fetchedResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedResults == nil) {
		NSLog(@"%@", [error debugDescription]);
		return nil;
	} else {
		return fetchedResults;
	}
}

- (WorkingWeekSetting *)getLatestWorkingWeekSettingForDate:(NSDate *)date {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];

	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setLocale:[NSLocale currentLocale]];
	[dateFormatter setDateFormat:@"yyyy"];
	NSNumber *yearNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:date]];
	[dateFormatter setDateFormat:@"MM"];
	NSNumber *monthNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:date]];
	[dateFormatter setDateFormat:@"dd"];
	NSNumber *dayNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:date]];

	NSString *predicateForDate = [NSString stringWithFormat:@"((year = %@) AND (month = %@) AND (day >= %@)) OR ((year = %@) AND (month > %@) AND (day >=%@))  OR ((year > %@) AND (month => %@) AND (day => %@))", yearNumber, monthNumber, dayNumber, yearNumber, monthNumber, [NSNumber numberWithInt:1], yearNumber, [NSNumber numberWithInt:1], [NSNumber numberWithInt:1]];

	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([WorkingWeekSetting class]) inManagedObjectContext:self.managedObjectContext];

	[fetchRequest setEntity:entity];

	NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"validUntil" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateSort]];

	[fetchRequest setFetchLimit:1];

	//	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%@ <= validUntil)", date];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateForDate];
	[fetchRequest setPredicate:predicate];

	NSError *error = nil;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

	if (fetchedObjects == nil) {
		return nil;
	} else if ([fetchedObjects count] == 0) {
		return nil;
	}
	return (WorkingWeekSetting *)fetchedObjects[0];
}

#pragma mark - day types methods
- (NSArray *)getListDayTypesForTimeUnit:(SummaryUnit)unit andDate:(NSDate *)date withType:(DayTypus)type {
	NSArray *returnArray = [NSArray new];

	switch (unit) {
		case SummaryUnitWeek :
			returnArray = [self getListDayTypesForWeek:date withType:type];
			break;
		case SummaryUnitMonth :
			returnArray = [self getListDayTypesForMonth:date withType:type];
			break;
		case SummaryUnitYear :
			returnArray = [self getListDayTypesForYear:date withType:type];
			break;
		default :
			break;
	}
	return returnArray;
}

- (NSArray *)getListDayTypesForMonth:(NSDate *)date withType:(DayTypus)type {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];

	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setLocale:[NSLocale currentLocale]];
	[dateFormatter setDateFormat:@"yyyy"];
	NSNumber *yearNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:date]];
	[dateFormatter setDateFormat:@"MM"];
	NSNumber *monthNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:date]];

	return [self standardSummaryFetchDayTypesWithType:type withPredicateStart:[NSString stringWithFormat:@"(year == %@) AND (month == %@)", yearNumber, monthNumber]];
}

- (NSArray *)getListDayTypesForWeek:(NSDate *)date withType:(DayTypus)type {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];

	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setLocale:[NSLocale currentLocale]];
	[dateFormatter setDateFormat:@"yyyy"];
	NSNumber *yearNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:date]];
	[dateFormatter setDateFormat:@"MM"];
	NSNumber *monthNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:date]];

    NSDate *weekStart = [date weekBeginning];

	[dateFormatter setDateFormat:@"dd"];
	NSNumber *weekStartNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:weekStart]];

	NSLog(@"Original date is %@ and beginning of week is %@", date, weekStart);

    NSDate *weekEnd = [[weekStart addDays:7] addMinutes:-1];
	NSNumber *weekEndNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:weekEnd]];

	[dateFormatter setDateFormat:@"yyyy"];
	NSNumber *yearNumberEnd = [numberFormatter numberFromString:[dateFormatter stringFromDate:weekEnd]];
	[dateFormatter setDateFormat:@"MM"];
	NSNumber *monthNumberEnd = [numberFormatter numberFromString:[dateFormatter stringFromDate:weekEnd]];

	NSString *predicate = @"";
	if ([monthNumber compare:monthNumberEnd] != NSOrderedSame) {
        // woche schneidet zwei monate
        // und jahr könnte auch anders sein
		predicate = [NSString stringWithFormat:@"(((year == %@) AND (month == %@) AND (day => %@) AND (day =< 31)) OR ((year == %@) AND (month == %@) AND (day => 1) AND (day =< %@)))", yearNumber, monthNumber, weekStartNumber, yearNumberEnd, monthNumberEnd, weekEndNumber];
	} else {
		predicate = [NSString stringWithFormat:@"((year == %@) AND (month == %@) AND (day => %@) AND (day =< %@))", yearNumber, monthNumber, weekStartNumber, weekEndNumber];
	}

	DebugLog(@"Original date is %@ and end of week is %@", date, weekEnd);

	return [self standardSummaryFetchDayTypesWithType:type
                                   withPredicateStart:predicate];
}

- (NSArray *)getListDayTypesForYear:(NSDate *)date withType:(DayTypus)type {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];

	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setLocale:[NSLocale currentLocale]];
	[dateFormatter setDateFormat:@"yyyy"];
	NSNumber *numberToLookFor = [numberFormatter numberFromString:[dateFormatter stringFromDate:date]];

	return [self standardSummaryFetchDayTypesWithType:type
                                   withPredicateStart:[NSString stringWithFormat:@"(year == %@)", numberToLookFor]];
}

- (NSArray *)standardSummaryFetchDayTypesWithType:(DayTypus)type withPredicateStart:(NSString *)predicate {
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([DayType class]) inManagedObjectContext:self.managedObjectContext];

	[fetchRequest setEntity:entity];

	// TODO sort descriptor?
	NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateSort]];
	NSPredicate *tempPredicate = nil;
	NSNumber *yesBoolean = [NSNumber numberWithBool:YES];
	switch (type) {
		case DayTypusVacationDay :
			tempPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ AND (vacation == %@)", predicate, yesBoolean]];
			break;
		case DayTypusSickDay :
			tempPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ AND (sickness == %@)", predicate, yesBoolean]];
			break;
		case DayTypusHoliday :
			tempPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ AND (holiday == %@)", predicate, yesBoolean]];
			break;
		case DayTypusNotAWorkingDay : {
			NSNumber *noBoolean = [NSNumber numberWithBool:NO];

			tempPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ AND (holiday == %@) AND (sickness == %@) AND (vacation == %@) AND (work == %@)", predicate, noBoolean, noBoolean, noBoolean, noBoolean]];
			break;
		}

		default :
			tempPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@", predicate]];
			break;
	}

	[fetchRequest setPredicate:tempPredicate];

	NSError *error = nil;
	NSArray *fetchedResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedResults == nil) {
		NSLog(@"%@", [error debugDescription]);
		return nil;
	} else {
		return fetchedResults;
	}
}

- (DayType *)getDayTypeForCalendarDay:(NSDate *)calendarDate {
	NSDateFormatter *dayFormatter = [NSDateFormatter new];

	[dayFormatter setLocale:[NSLocale currentLocale]];
	[dayFormatter setDateFormat:@"yyyy_MM_dd"];
	NSString *calendarDay = [dayFormatter stringFromDate:calendarDate];

	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([DayType class]) inManagedObjectContext:self.managedObjectContext];

	[fetchRequest setEntity:entity];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(calendarDay == %@)", calendarDay];
	[fetchRequest setPredicate:predicate];

	NSError *error = nil;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

	if (fetchedObjects == nil) {
		return nil;
	} else if ([fetchedObjects count] == 0) {
		return nil;
	} else if ([fetchedObjects count] > 1) {
		NSLog(@"%@", [error debugDescription]);
	}
	return (DayType *)fetchedObjects[0];
}

#pragma mark - comment methods
- (Comment *)getComment:(NSString *)comment{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Comment class]) inManagedObjectContext:self.managedObjectContext];
    
	[fetchRequest setEntity:entity];
    
//    NSSortDescriptor *usedSort = [[NSSortDescriptor alloc] initWithKey:@"used" ascending:NO];
//	NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"lastUsedDate" ascending:NO];
//    
//	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:usedSort, dateSort, nil]];
    
	[fetchRequest setFetchLimit:1];
    NSString * trimmedComment = [comment trim];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"commentText == %@", trimmedComment];
	[fetchRequest setPredicate:predicate];
    
	NSError *error = nil;
	NSArray *fetchedResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
	if (fetchedResults == nil) {
		NSLog(@"%@", [error debugDescription]);
		return nil;
	} else if([fetchedResults count] == 0){
        return nil;
    } else {
        return (Comment*)fetchedResults[0];
    }
}

- (NSUInteger)getCountCommentsAll{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Comment class]) inManagedObjectContext:self.managedObjectContext];
    
	[fetchRequest setEntity:entity];
    
	NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"lastUsedDate" ascending:NO];
    NSSortDescriptor *usedSort = [[NSSortDescriptor alloc] initWithKey:@"usage" ascending:NO];

	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:dateSort, usedSort, nil]];
    
	NSError *error = nil;
    NSUInteger commentsCount = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    
	if (commentsCount == -1) {
		NSLog(@"%@", [error debugDescription]);
		return 0;
	} else {
		return commentsCount;
	}
}

- (NSUInteger)getCountCommentsFrequent{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Comment class]) inManagedObjectContext:self.managedObjectContext];
    
	[fetchRequest setEntity:entity];
    
    NSSortDescriptor *usedSort = [[NSSortDescriptor alloc] initWithKey:@"usage" ascending:NO];
	NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"lastUsedDate" ascending:NO];
    
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:usedSort, dateSort, nil]];

    NSDate *currentDate = [NSDate date];
    NSLog(@"Current Date = %@", currentDate);
    
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = -6;
    
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    NSLog(@"Date = %@", newDate);
    
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastUsedDate > %@", newDate];
	[fetchRequest setPredicate:predicate];
    
	NSError *error = nil;
    NSUInteger commentsCount = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
	
    if (commentsCount == -1) {
		NSLog(@"%@", [error debugDescription]);
		return 0;
	} else {
		return commentsCount;
	}
}

- (NSArray *)getCommentsAllWithLimit:(NSUInteger)limit withOffset:(NSUInteger)offset{
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Comment class]) inManagedObjectContext:self.managedObjectContext];

	[fetchRequest setEntity:entity];

	NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"lastUsedDate" ascending:NO];
    NSSortDescriptor *usedSort = [[NSSortDescriptor alloc] initWithKey:@"usage" ascending:NO];
    
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:dateSort, usedSort, nil]];
	[fetchRequest setFetchLimit:limit];
    
    [fetchRequest setFetchOffset:offset];
    
//    NSDictionary *entityProperties = [entity propertiesByName];
//    [fetchRequest setReturnsDistinctResults:YES];
//    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"comment"]]];
//    [fetchRequest setResultType:NSDictionaryResultType];

//	// http://stackoverflow.com/questions/22083156/core-data-nspredicate-to-filter-out-empty-string-working-incorrect
//	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comment MATCHES %@", @".{1,}"];
//	[fetchRequest setPredicate:predicate];

	NSError *error = nil;
	NSArray *fetchedResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
	if (fetchedResults == nil) {
		NSLog(@"%@", [error debugDescription]);
		return nil;
	} else {
		return fetchedResults;
	}
}

- (NSArray *)getCommentsFrequentWithLimit:(NSUInteger)limit withOffset:(NSUInteger)offset;{
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Comment class]) inManagedObjectContext:self.managedObjectContext];

	[fetchRequest setEntity:entity];
    [fetchRequest setFetchOffset:offset];

    NSSortDescriptor *usedSort = [[NSSortDescriptor alloc] initWithKey:@"usage" ascending:NO];
	NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"lastUsedDate" ascending:NO];
    
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:usedSort, dateSort, nil]];
	[fetchRequest setFetchLimit:limit];
    
    NSDate *currentDate = [NSDate date];
    NSLog(@"Current Date = %@", currentDate);
    
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = -6;
    
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    NSLog(@"Date = %@", newDate);
    
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastUsedDate > %@", newDate];
	[fetchRequest setPredicate:predicate];

	NSError *error = nil;
	NSArray *fetchedResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedResults == nil) {
		NSLog(@"%@", [error debugDescription]);
		return nil;
	} else {
		return fetchedResults;
	}
}

#pragma mark - summary fetch day entries

- (NSArray *)getListDayEntryForMonth:(NSDate *)date {
	NSDate *monthStart = [date monthBeginning];
	DebugLog(@"Original date is %@ and beginning of month is %@", date, monthStart);

    NSDate *monthEnd = [monthStart addMonths:1];
	DebugLog(@"Original date is %@ and end of month is %@", date, monthEnd);
    
	return [self standardSummaryFetchWithCheckIn:monthStart
                                     andCheckOut:monthEnd];
}

- (NSArray *)getListDayEntryForYear:(NSDate *)date {
    NSCalendar *cal = [NSCalendar defaultCalendar_Static:YES];

	NSDateComponents *components = [cal components:CALENDARUNITCOMPONENTS fromDate:date];

	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	[components setDay:1];
	[components setMonth:1];

	NSDate *yearStart = [cal dateFromComponents:components];
	DebugLog(@"Original date is %@ and beginning of year is %@", date, yearStart);

    NSDate *yearEnd = [yearStart addYears:1];

    DebugLog(@"Original date is %@ and end of year is %@", date, yearEnd);

	return [self standardSummaryFetchWithCheckIn:yearStart andCheckOut:yearEnd];
}

- (NSArray *)standardSummaryFetchWithCheckIn:(NSDate *)checkInDate andCheckOut:(NSDate *)checkOutDate {
	NSDate *timeZoneIncludedBeginDate = [checkInDate addDays:-1];
	NSDate *timeZoneIncludedEndDate = [checkOutDate addDays:1]; //TODO warum

	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:NSStringFromClass([DayEntry class])
                                   inManagedObjectContext:self.managedObjectContext];

	[fetchRequest setEntity:entity];

	NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"checkInTime" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateSort]];

	NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(checkOutTime != nil AND (checkInTime >= %@) AND (checkInTime <= %@))",
                              timeZoneIncludedBeginDate,
                              timeZoneIncludedEndDate];
	[fetchRequest setPredicate:predicate];

	NSError *error = nil;
	NSArray *fetchedResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

	if (fetchedResults == nil) {
		NSLog(@"%@", [error debugDescription]);
		return nil;
	} else {
		NSMutableArray *tempFetchedResults = [NSMutableArray arrayWithArray:fetchedResults];

		NSArray *actuallyNotInThisMonth = [tempFetchedResults filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(checkInTime < %@ OR checkInTime > %@)", checkInDate, checkOutDate]];

		for (DayEntry *entry in actuallyNotInThisMonth) {
			if ([entry.checkInTimeZone isEqualToString:[[NSTimeZone systemTimeZone] name]]) {
				[tempFetchedResults removeObject:entry];
			} else {
				if (([entry.checkInTime compare:checkInDate] == NSOrderedAscending &&
                     ![entry.checkInTime isSameDay:checkInDate withReceiverTimeZoneName:entry.checkInTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]]) ||
                    ([entry.checkInTime compare:checkOutDate] == NSOrderedDescending &&
                     ![entry.checkInTime isSameDay:checkOutDate withReceiverTimeZoneName:entry.checkInTimeZone andInputTimeZoneName:[[NSTimeZone systemTimeZone] name]])) {
					[tempFetchedResults removeObject:entry];
				}
			}
		}

		return tempFetchedResults;
	}
}

#pragma mark - project methods

- (Project *)getBasicProject {
    return [self getBasicProjectWithContext:nil];
}

- (Project *)getBasicProjectWithContext:(NSManagedObjectContext *)context {
    // create a fetch request from template
    NSManagedObjectContext *currentContext;
    NSFetchRequest *fetchRequest;
    NSArray *fetchedObjects;
    
    if (context == nil) {
        currentContext = self.managedObjectContext;
    } else {
        currentContext = context;
    }
    
    fetchRequest = [self.managedObjectModel
                    fetchRequestTemplateForName:@"BasicProject_Request"];
    
    fetchedObjects = [currentContext
                      executeFetchRequest:fetchRequest
                      error:nil];
    
    if ([fetchedObjects firstObject]) {
        return [fetchedObjects firstObject];
    }
    DebugLog(@"SEVERE: project should not be nil");
    return nil;
}

- (NSFetchedResultsController *)getAllActiveCustomersWithContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest;
    NSEntityDescription *entity;
    NSFetchedResultsController *aFetchedResultsController;
    NSSortDescriptor *sortDescriptor;
    NSArray *sortDescriptors;
    NSPredicate *predicate;
    
    fetchRequest = [NSFetchRequest new];
    entity = [NSEntityDescription
              entityForName:NSStringFromClass([Customer class])
              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    sortDescriptor = [[NSSortDescriptor alloc]
                      initWithKey:@"displayName"
                      ascending:YES];
    sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    predicate = [NSPredicate
                 predicateWithFormat:@"active == %@", @YES];
    [fetchRequest setPredicate:predicate];
    
    aFetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:context
                                 sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        /*
         * Replace this implementation with code to handle the error appropriately.
         *
         * abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)getAllEntitiesFetchedResultsControllerForClass:(Class)clazz withSortDescriptorKey:(NSString *)descriptorKey sectionNameKeyPath:(NSString *)sectionNameKey {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(clazz) inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    // Edit the sort key as appropriate.
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:descriptorKey ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKey cacheName:nil];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        /*
         * Replace this implementation with code to handle the error appropriately.
         *
         * abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)getAllDayEntryEntities {
    return [self getAllEntitiesFetchedResultsControllerForClass:[DayEntry class] withSortDescriptorKey:@"checkInTime" sectionNameKeyPath:@"dayKey"];
}

- (NSFetchedResultsController *)getAllDayEntryEntitiesHonouringFilter {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([DayEntry class]) inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    // Edit the sort key as appropriate.
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"checkInTime" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"project.filterActive == %@", @YES];
    [fetchRequest setPredicate:predicate];
    
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"dayKey" cacheName:nil];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        /*
         * Replace this implementation with code to handle the error appropriately.
         *
         * abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)getAllDayTypeEntities {
    return [self getAllEntitiesFetchedResultsControllerForClass:[DayType class] withSortDescriptorKey:@"calendarDate" sectionNameKeyPath:@"dayKey"];
}

- (NSFetchedResultsController *)getAllWorkingWeekSettingEntities {
    return [self getAllEntitiesFetchedResultsControllerForClass:[WorkingWeekSetting class] withSortDescriptorKey:@"validUntil" sectionNameKeyPath:@"dayKey"];
}

- (NSFetchedResultsController *)getAllActiveProjects {
    return [self getAllActiveProjectsWithContext:nil];
}

- (NSFetchedResultsController *)getAllActiveProjectsWithContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"active == %@ AND name != %@ AND basicProject == %@ AND parent == %@", @YES, BASIC_GLOBAL_PROJECT_NAME, @NO, nil];
    return [self getProjectsWithPredicate:predicate
                              withContext:context];
}

- (NSFetchedResultsController *)getAllProjects {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent == %@", nil];
    
    return [self getProjectsWithPredicate:predicate
                              withContext:nil];
}

- (NSFetchedResultsController *)runningProjects:(NSManagedObjectContext *)context
                                    withinStart:(NSDate *)start
                                         andEnd:(NSDate *)end {
    NSDate *finalStart;
    NSDate *finalEnd;
    
    if (start == nil) {
        finalStart = [NSDate date];
    } else {
        finalStart = start;
    }
    
    if (end == nil) {
        finalEnd = [NSDate date];
    } else {
        finalEnd = end;
    }
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"parent == %@ AND fromDate <= %@ AND (toDate == %@ OR toDate >= %@)",
                              nil,
                              finalStart,
                              nil,
                              finalEnd];
    
    return [self getProjectsWithPredicate:predicate
                              withContext:context];
}

- (NSFetchedResultsController *)getAllProjectsWithoutBasic {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent == %@ AND name != %@  AND basicProject == %@", nil, BASIC_GLOBAL_PROJECT_NAME, @NO];
    return [self getProjectsWithPredicate:predicate
                              withContext:nil];
}

- (NSFetchedResultsController *)getAllProjectsWithFilterActivated {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent == %@ AND filterActive == %@", nil, @YES];
    return [self getProjectsWithPredicate:predicate
                              withContext:nil];
}

- (NSFetchedResultsController *)getAllProjectsWithFilterAndPartialFilterActivated {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent == %@ AND (filterActive == %@ OR partialFilterActive == %@)", nil, @YES, @YES];
    return [self getProjectsWithPredicate:predicate
                              withContext:nil];
}

- (NSFetchedResultsController *)getProjectsWithPredicate:(NSPredicate *)predicate
                                             withContext:(NSManagedObjectContext *)context {
    NSManagedObjectContext *currentContext;
    NSFetchRequest *fetchRequest;
    NSEntityDescription *entity;
    NSFetchedResultsController *aFetchedResultsController;
    if (context == nil) {
        currentContext = self.managedObjectContext;
    } else {
        currentContext = context;
    }
    
    fetchRequest = [NSFetchRequest new];
    entity = [NSEntityDescription
              entityForName:NSStringFromClass([Project class])
              inManagedObjectContext:currentContext];


	[fetchRequest setEntity:entity];
	// Edit the sort key as appropriate.

	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];

	[fetchRequest setSortDescriptors:sortDescriptors];
	[fetchRequest setPredicate:predicate];

	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	aFetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:currentContext
                                 sectionNameKeyPath:nil
                                 cacheName:nil];

	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
		/*
		 * Replace this implementation with code to handle the error appropriately.
		 *
		 * abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}

	return aFetchedResultsController;
}

- (NSFetchedResultsController *)getAllActiveCustomers {
    return [self getAllActiveCustomersWithContext:self.managedObjectContext];
}

- (NSInteger)projectPosition {
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Project class]) inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"active == %@", [NSNumber numberWithBool:YES]];
	[fetchRequest setPredicate:predicate];
    
    fetchRequest.fetchLimit = 1;

	NSError *error = nil;
    NSArray *answer = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                               error:&error];

	if (answer && [answer count] > 0 && answer[0] && [answer[0] isKindOfClass:[Project class]]) {
        Project *project = answer[0];
		return [project.position integerValue] + 1;
	} else {
        if (error) {
            NSLog(@"%@", [error debugDescription]);
        }
		return 0;
	}
}

#pragma mark - private methods

- (void)handleDataModelChange:(NSNotification *)notification {
//    NSSet *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
//	NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
//	NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
//
//    NSLog(@"insertObjects: %@", [insertedObjects description]);
//    NSLog(@"deletedObjects: %@", [deletedObjects description]);
//    NSLog(@"updatedObjects: %@", [updatedObjects description]);

    
	[self saveContext];
}

- (void)contextDidSave:(NSNotification *)notification {
    NSSet *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
//    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    
//    NSLog(@"insertObjects: %@", [insertedObjects description]);
//    NSLog(@"deletedObjects: %@", [deletedObjects description]);
//    NSLog(@"updatedObjects: %@", [updatedObjects description]);
    
    for (NSManagedObject *object in deletedObjects) {
        if ([object isKindOfClass:[DayEntry class]]) {
            DayEntry *dayEntry = (DayEntry *)object;
            // old comment
            if (![[dayEntry.comment trim] isEqualToString:@""]) {
                Comment *comment = [[AXDataStore sharedInstance] getComment:dayEntry.comment];
                if([comment.usage isEqualToNumber:@(1)]){
                    [[AXDataStore sharedInstance] deleteObject:comment];
                } else {
                    comment.usage = @([comment.usage intValue] - 1);
                }
            }
        }
    }
    
    for (NSManagedObject *object in insertedObjects) {
        if ([object isKindOfClass:[DayEntry class]]) {
            // new comment or updated comment
            DayEntry *dayEntry = (DayEntry *)object;
            
            if (dayEntry.comment &&
                ![[dayEntry.comment trim] isEqualToString:@""]) {
                Comment *comment = [[AXDataStore sharedInstance] getComment:dayEntry.comment];
                if (comment) {
                    comment.usage = @([comment.usage intValue] + 1);
                    comment.lastUsedDate = [NSDate date];
                } else {
                    comment = [[[AXDataStore sharedInstance] managedObjectContext] newCommentEntityWithComment:dayEntry.comment];
                }
            }
        }
    }
}

- (void)saveContext {
	NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;

//    [managedObjectContext reset];
//    [managedObjectContext mergeChangesFromContextDidSaveNotification:nil];
	if (managedObjectContext != nil) {
		if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 * Replace this implementation with code to handle the error appropriately.
			 *
			 * abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
}

- (void)contextWillSave:(NSNotification *)notification {
    // If you change property values using primitive accessors, you avoid the possibility of infinite recursion, but Core Data will not notice the change you make.
    // https://developer.apple.com/library/mac/documentation/Cocoa/Reference/CoreDataFramework/Classes/NSManagedObject_Class/index.html

    if (self.preservingImportedMetadata) { return; }
    NSManagedObjectContext *context = [notification object];
    if ([context isEqual:self.managedObjectContext]) {
        NSDate *dateOfTheLastModification = [NSDate date];
        for (NSManagedObject *obj in [context insertedObjects]) {
            if ([obj respondsToSelector:@selector(creationDate)]) {
                [obj setPrimitiveValue:dateOfTheLastModification forKey:@"creationDate"];
            }
            if ([obj respondsToSelector:@selector(lastModifiedDate)]) {
                [obj setPrimitiveValue:dateOfTheLastModification forKey:@"lastModifiedDate"];
            }
            if ([obj respondsToSelector:@selector(identifier)]) {
                if ([obj primitiveValueForKey:@"identifier"] == nil) {
                    [obj setPrimitiveValue:[[NSUUID UUID] UUIDString] forKey:@"identifier"];
                }
                //                else {
                //                    DebugLog(@"identifier already set");
                //                }
            }
        }
        for (NSManagedObject *obj in [context updatedObjects]) {
            if ([obj respondsToSelector:@selector(lastModifiedDate)]) {
                [obj setPrimitiveValue:dateOfTheLastModification forKey:@"lastModifiedDate"];
            }
        }
        
    }
}

#pragma mark - Core Data stack
/**
 * Returns the managed object context for the application.
 * If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext { //lazy initialization
	if (__managedObjectContext != nil) {
		return __managedObjectContext;
	}

	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
		__managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//		__managedObjectContext = [NSManagedObjectContext new];
		[__managedObjectContext setPersistentStoreCoordinator:coordinator]; //TODO aktuell scheint es confinement zu sein ist aber
        //deprecated ----->>> UPDATE habe es geändert jetzt mit mainqueueconcurrencytype
//		[__managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
	}
	return __managedObjectContext;
}

/**
 * Returns the managed object model for the application.
 * If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
	if (__managedObjectModel != nil) {
		return __managedObjectModel;
	}
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:dataModelName withExtension:@"momd"];
	__managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return __managedObjectModel;
}

/**
 * Returns the persistent store coordinator for the application.
 * If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	if (__persistentStoreCoordinator != nil) {
		return __persistentStoreCoordinator;
	}
	NSURL *storeURL = [self localStoreURL];
	NSError *error = nil;
	__persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    // Performing automatic lightweight migration by passing the following dictionary as the options parameter:
	NSMutableDictionary *options = [self basicPersistentStoreOptions];

	if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
		/*
		 * Replace this implementation with code to handle the error appropriately.
		 *
		 * abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		 *
		 * Typical reasons for an error here include:
		 * The persistent store is not accessible;
		 * The schema for the persistent store is incompatible with current managed object model.
		 * Check the error message to determine what the actual problem was.
		 *
		 *
		 * If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
		 *
		 * If you encounter schema incompatibility errors during development, you can reduce their frequency by:
		 * Simply deleting the existing store:
		 * [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
		 *
		 */

        //// NSPersistentStoreRebuildFromUbiquitousContentOption

		DebugLog(@" SEVERE: Unresolved error %@, %@", error, [error userInfo]);
	}

    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 * Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
