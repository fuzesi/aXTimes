//
//  DayEntry.h
//  aXTimes
//
//  Created by fuesec on 25/08/14.
//  Copyright (c) 2014 aXimilate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pause, ProjectEntry;

@interface DayEntry : NSManagedObject

@property (nonatomic, retain) NSDate *checkInTime;
@property (nonatomic, retain) NSString *checkInTimeZone;
@property (nonatomic, retain) NSDate *checkOutTime;
@property (nonatomic, retain) NSString *checkOutTimeZone;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSString *currencyLocale;
@property (nonatomic, retain) NSNumber *entryType;
@property (nonatomic, retain) NSNumber *hourlyWage;
@property (nonatomic, retain) NSSet *pauses;
@property (nonatomic, retain) NSSet *projectEntries;
@end

@interface DayEntry (CoreDataGeneratedAccessors)

- (void)addPausesObject:(Pause *)value;
- (void)removePausesObject:(Pause *)value;
- (void)addPauses:(NSSet *)values;
- (void)removePauses:(NSSet *)values;

- (void)addProjectEntriesObject:(ProjectEntry *)value;
- (void)removeProjectEntriesObject:(ProjectEntry *)value;
- (void)addProjectEntries:(NSSet *)values;
- (void)removeProjectEntries:(NSSet *)values;

@end
