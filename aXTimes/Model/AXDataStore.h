//
//  AXDataStore.h
//  aXTimes
//
//  Created by fuesec on 5/9/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//
#import "AXCalculation.h"
#import <CoreData/CoreData.h>

typedef NS_ENUM (NSInteger, DayTypus) {
    DayTypusNotSpecified = -2,
    DayTypusNoSelectionIsWork = -1,
    DayTypusNotAWorkingDay = 0,
    DayTypusHoliday = 1,
    DayTypusVacationDay = 2,
    DayTypusSickDay = 3
};

@class Comment;
@class WorkingWeekSetting;
@class DayType;
@class Pause;

@interface AXDataStore : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
// Preserve timestamps supplied by a backup while its changes are committed.
@property (nonatomic, assign) BOOL preservingImportedMetadata;


#pragma mark - class methods
+ (AXDataStore *)sharedInstance;

//#pragma mark - iCloud methods
//- (void)migrateLocalStoreToiCloudStore;

#pragma mark - instance methods
- (NSArray<DayEntry *> *)standardSummaryFetchWithCheckIn:(NSDate *)checkInDate andCheckOut:(NSDate *)checkOutDate;
- (void)deleteObject:(NSManagedObject *)object;
- (NSArray<DayEntry *> *)getDayEntriesForDate:(NSDate *)date;

- (NSArray *)getAllManagedObjectsForClass:(Class)clazz;
- (NSArray<DayEntry *> *)allDayEntriesSorted;
- (NSUInteger)getCountForAllManagedObjectsForClass:(Class)clazz;

- (NSManagedObject *)temporayManagedObjectForClass:(Class)clazz;
- (void)insertDetachedObject:(NSManagedObject *)object;
- (NSManagedObject *)fetchObjectWithManagedObjectIDWithChildContext:(NSManagedObjectID *)objectID andContext:(NSManagedObjectContext *)childContext;
- (void)turnIntoChildContext:(NSManagedObjectContext *)childContext;

- (NSArray *)getListDayEntryForMonthInDetailView:(NSDate *)date;
- (NSArray *)getListDayEntryForMonth:(NSDate *)date;
- (NSArray *)getListDayEntryForYear:(NSDate *)date;
- (NSArray *)getListDayEntriesDateBetween:(NSDate *)fromDate andDate:(NSDate *)toDate;

- (NSArray *)getCommentsAllWithLimit:(NSUInteger)limit withOffset:(NSUInteger)offset;
- (NSUInteger)getCountCommentsAll;
- (NSArray *)getCommentsFrequentWithLimit:(NSUInteger)limit withOffset:(NSUInteger)offset;
- (NSUInteger)getCountCommentsFrequent;
- (Comment *)getComment:(NSString *)comment;

- (Project *)getBasicProject;
- (Project *)getBasicProjectWithContext:(NSManagedObjectContext *)context;
- (NSFetchedResultsController *)getAllProjects;
- (NSFetchedResultsController *)runningProjects:(NSManagedObjectContext *)context
                                    withinStart:(NSDate *)start
                                         andEnd:(NSDate *)end;
- (NSFetchedResultsController *)getAllProjectsWithoutBasic;
- (NSFetchedResultsController *)getAllProjectsWithFilterActivated;
- (NSFetchedResultsController *)getAllProjectsWithFilterAndPartialFilterActivated;
- (NSFetchedResultsController *)getAllActiveProjects;
- (NSFetchedResultsController *)getAllActiveProjectsWithContext:(NSManagedObjectContext *)context;
- (NSFetchedResultsController *)getAllActiveCustomers;
- (NSFetchedResultsController *)getAllActiveCustomersWithContext:(NSManagedObjectContext *)context;
- (NSInteger)projectPosition;

- (NSArray *)getListWorkingWeekSettingsForDate:(NSDate *)date;
- (WorkingWeekSetting *)getLatestWorkingWeekSettingForDate:(NSDate *)date;

- (NSArray *)getListDayTypesForTimeUnit:(SummaryUnit)unit andDate:(NSDate *)date withType:(DayTypus)type;
- (NSArray *)getListDayTypesForMonth:(NSDate *)date withType:(DayTypus)type;
- (NSArray *)getListDayTypesForWeek:(NSDate *)date withType:(DayTypus)type;
- (NSArray *)getListDayTypesForYear:(NSDate *)date withType:(DayTypus)type;
- (DayType *)getDayTypeForCalendarDay:(NSDate *)calendarDay;

- (NSFetchedResultsController *)getAllEntitiesFetchedResultsControllerForClass:(Class)clazz withSortDescriptorKey:(NSString *)descriptorKey sectionNameKeyPath:(NSString *)sectionNameKey;
- (NSFetchedResultsController *)getAllDayEntryEntities;
- (NSFetchedResultsController *)getAllDayEntryEntitiesHonouringFilter;
- (NSFetchedResultsController *)getAllDayTypeEntities;
- (NSFetchedResultsController *)getAllWorkingWeekSettingEntities;

@end
