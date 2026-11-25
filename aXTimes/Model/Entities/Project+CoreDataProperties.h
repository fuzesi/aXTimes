////
////  Project+CoreDataProperties.h
////  aXTimes
////
////  Created by Christopher Füseschi on 17/08/16.
////  Copyright © 2016 aXimilate. All rights reserved.
////
////  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
////  to delete and recreate this implementation file for your updated model.
////
//
//#import "Project.h"
//
//NS_ASSUME_NONNULL_BEGIN
//
//@interface Project (CoreDataProperties)
//
//@property (nullable, nonatomic, retain) NSNumber *active;
//@property (nullable, nonatomic, retain) NSNumber *basicProject;
//@property (nullable, nonatomic, retain) NSDecimalNumber *budget;
//@property (nullable, nonatomic, retain) NSNumber *isUseSubProjectsBudget;
//@property (nullable, nonatomic, retain) NSString *code;
//@property (nullable, nonatomic, retain) NSString *colourAsHex;
//@property (nullable, nonatomic, retain) NSDate *creationDate;
//@property (nullable, nonatomic, retain) NSString *defaultComment;
//@property (nullable, nonatomic, retain) NSNumber *defaultPause;
//@property (nullable, nonatomic, retain) NSDate *defaultPauseEnd;
//@property (nullable, nonatomic, retain) NSDate *defaultPauseStart;
//@property (nullable, nonatomic, retain) NSNumber *defaultProject;
//@property (nullable, nonatomic, retain) NSNumber *filterActive;
//@property (nullable, nonatomic, retain) NSDate *fromDate;
//@property (nullable, nonatomic, retain) NSString *fromDateTimeZone;
//@property (nullable, nonatomic, retain) NSDecimalNumber *hourlyWage;
//@property (nullable, nonatomic, retain) NSDate *lastModifiedDate;
//@property (nullable, nonatomic, retain) NSString *name;
//@property (nullable, nonatomic, retain) NSNumber *position;
//@property (nullable, nonatomic, retain) NSString *projectDescription;
//@property (nullable, nonatomic, retain) NSNumber *roundingBehaviour;
//@property (nullable, nonatomic, retain) NSNumber *timeUnit;
//@property (nullable, nonatomic, retain) NSDate *toDate;
//@property (nullable, nonatomic, retain) NSString *toDateTimeZone;
//@property (nullable, nonatomic, retain) NSNumber *partialFilterActive;
//@property (nullable, nonatomic, retain) Customer *customer;
//@property (nullable, nonatomic, retain) NSSet<DayEntry *> *dayEntries;
//@property (nullable, nonatomic, retain) NSSet<DefaultPauseSetting *> *defaultPauseSettings;
//@property (nullable, nonatomic, retain) Project *parentProject;
//@property (nullable, nonatomic, retain) NSSet<Project *> *subProjects;
//
//@end
//
//@interface Project (CoreDataGeneratedAccessors)
//
//- (void)addDayEntriesObject:(DayEntry *)value;
//- (void)removeDayEntriesObject:(DayEntry *)value;
//- (void)addDayEntries:(NSSet<DayEntry *> *)values;
//- (void)removeDayEntries:(NSSet<DayEntry *> *)values;
//
//- (void)addDefaultPauseSettingsObject:(DefaultPauseSetting *)value;
//- (void)removeDefaultPauseSettingsObject:(DefaultPauseSetting *)value;
//- (void)addDefaultPauseSettings:(NSSet<DefaultPauseSetting *> *)values;
//- (void)removeDefaultPauseSettings:(NSSet<DefaultPauseSetting *> *)values;
//
//- (void)addSubProjectsObject:(Project *)value;
//- (void)removeSubProjectsObject:(Project *)value;
//- (void)addSubProjects:(NSSet<Project *> *)values;
//- (void)removeSubProjects:(NSSet<Project *> *)values;
//
//@end
//
//NS_ASSUME_NONNULL_END
