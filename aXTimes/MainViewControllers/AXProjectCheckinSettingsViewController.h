//
//  AXProjectCheckinSettingsViewController.h
//  aXTimes
//
//  Created by Christopher Füseschi on 30/05/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSTableView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AXProjectCheckinSettingsViewControllerProtocol <NSObject>
- (void)projectSelectionChanged:(Project *)project;
- (Project *)relevantProject;
- (NSDate *)projectStart;
- (NSDate *)projectEnd;
@end

@protocol AXInitiateCheckInOnSpecificProjectProtocol <NSObject>
- (void)triggerCheckInOnProject:(Project *)project;
@end

@interface AXProjectCheckinSettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, SKSTableViewDelegate>

@property (strong, nonatomic) id <AXProjectCheckinSettingsViewControllerProtocol> _Nullable projectSelectionDelegate;
@property (strong, nonatomic) id <AXInitiateCheckInOnSpecificProjectProtocol> _Nullable checkInOnProjectDelegate;
@property (strong, nonatomic) NSManagedObjectContext *childContext;

@property (strong, nonatomic)  NSString * _Nullable controllerTitle;
@property (strong, nonatomic)  NSString * _Nullable firstSectionFooterTitle;
typedef void (^selectedProjectBlock_t)(Project * _Nonnull selectedProject);
@property (nonatomic, strong) selectedProjectBlock_t _Nullable selectedProjectBlock;
@property (nonatomic) BOOL isOldDataImport;
@property (strong, nonatomic)  NSString * _Nullable doneButtonTitle;
@property (nonatomic) BOOL isShowCancelAndDone;

@end

NS_ASSUME_NONNULL_END
