//
//  AXProjectsDayViewController.m
//  aXTimes
//
//  Created by fuesec on 10/6/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXProjectsDayViewController.h"
#import "AXUtility.h"
#import "AXHourlyWageViewController.h"
#import "AXSettingsManager.h"
#import "AXPauseTableViewCell.h"
#import "NSDate+AXNSDateCategory.h"
#import <MEAlertView.h>
#import "UIImage+AXUIImageCategory.h"
#import "ProjectEntry.h"
#import "NSString+AXNSStringCategory.h"

@interface AXProjectsDayViewController ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) DayEntry *currentDayEntry;
@property (nonatomic, strong) AXTimePickerViewController *cpyPickerViewController;
//@property (strong, nonatomic) AXPickerViewController *activePickerViewController;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) AXUtility *utility;
@property (nonatomic, strong) AXSettingsManager *settingsController;
@property (nonatomic) CGRect originalTableViewFrame;
@property (nonatomic, strong) UITextField *activeKeyboardObject;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property int selectedRow;
- (void)dismissDatePicker;
- (void)setupWithDate:(NSDate *)date;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (ProjectEntry *)projectEntryOfDayEntry:(DayEntry *)dayEntry forProject:(Project *)project;
- (void)noteButtonClicked:(id)sender;
- (ProjectEntry *)projectEntryForUIView:(UIView *)view;
- (void)dismissKeyboard;
//- (void)dismissPicker:(AXPickerViewController *)picker;

@property (strong, nonatomic) UITableView *activeTableViewCenter;
@property (strong, nonatomic) NSLayoutConstraint *activeTableViewContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableView2Constraint;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableView *tableView2;

@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;
@property (strong, nonatomic) IBOutlet UIView *summaryCalculationView;
@property (strong, nonatomic) IBOutlet UIButton *noteButton;
@property (strong, nonatomic) IBOutlet UIButton *cpButton;
@property (strong, nonatomic) IBOutlet UIButton *clearButton;
@property (strong, nonatomic) IBOutlet UILabel *hoursToDistributeLabel;
@property (strong, nonatomic) IBOutlet UILabel *hoursWorkedLabel;
@property (strong, nonatomic) IBOutlet UILabel *hoursToDistributeCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *hoursWorkedCountLabel;
- (IBAction)clearAction:(id)sender;
- (IBAction)noteAction:(id)sender;
- (IBAction)copyAction:(id)sender;

@end

@implementation AXProjectsDayViewController
@synthesize fetchedResultsController = __fetchedResultsController;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self =  [super initWithCoder:aDecoder];
	if (self) {
		self.cpyPickerViewController = [AXTimePickerViewController new];
		[self.cpyPickerViewController setDelegate:self];
		self.cpyPickerViewController.datePicker.datePickerMode = UIDatePickerModeDate;

		self.dateFormatter = [NSDateFormatter new];
		self.dateFormatter.dateFormat = @"HH:mm";
		self.utility = [AXUtility new];
		self.settingsController = [AXSettingsManager new];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];

	self.hoursToDistributeLabel.text = NSLocalizedString(@"Hours to distribute", @"Translate the term 'Hours to distribute'");
	self.hoursWorkedLabel.text = NSLocalizedString(@"Hours worked", @"Translate the term 'Hours worked'");

	self.buttonContainerView.backgroundColor = GLOBALBACKGROUNDCOLOR2;
	self.summaryCalculationView.backgroundColor = GLOBALBACKGROUNDCOLOR2;
	self.view.backgroundColor = GLOBALBACKGROUNDCOLOR2;

	self.noteButton.clipsToBounds = YES;
	self.noteButton.layer.cornerRadius = self.noteButton.frame.size.width / 2;
	self.noteButton.layer.borderColor = SELECTIONCOLOR.CGColor;
	self.noteButton.layer.borderWidth = 1.0f;
	self.noteButton.backgroundColor = GLOBALBACKGROUNDCOLOR;
	[self.noteButton setTintColor:SELECTIONCOLOR];

	self.cpButton.clipsToBounds = YES;
	self.cpButton.layer.cornerRadius = self.cpButton.frame.size.width / 2;
	self.cpButton.layer.borderColor = SELECTIONCOLOR.CGColor;
	self.cpButton.layer.borderWidth = 1.0f;
	self.cpButton.backgroundColor = GLOBALBACKGROUNDCOLOR;
	[self.cpButton setTintColor:SELECTIONCOLOR];

	self.clearButton.clipsToBounds = YES;
	self.clearButton.layer.cornerRadius = self.clearButton.frame.size.width / 2;
	self.clearButton.layer.borderColor = SELECTIONCOLOR.CGColor;
	self.clearButton.layer.borderWidth = 1.0f;
	self.clearButton.backgroundColor = GLOBALBACKGROUNDCOLOR;
	[self.clearButton setTintColor:SELECTIONCOLOR];

	self.tableView2Constraint.constant = 320;
	[self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
	self.activeTableViewCenter = self.tableView;
	self.activeTableViewContraint = self.tableViewConstraint;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setupWithDate:[[AXDateManager sharedInstance] currentDate]];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self dismissDatePicker];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([self.fetchedResultsController sections] == nil) {
		return 0;
	}
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

	[self configureCell:cell atIndexPath:indexPath];


	return cell;
}

/**
 *  Method used with plain tableView style to eliminate the empty rows.
 */
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	// cfu
	if ([indexPath row] == ((NSIndexPath *)[[tableView indexPathsForVisibleRows] lastObject]).row) {
		// end of table loading
		if (self.currentDayEntry != nil && [self.currentDayEntry checkInTime] != nil) {
			self.cpButton.layer.borderColor = SELECTIONCOLOR.CGColor;
			self.cpButton.enabled = YES;
			self.cpButton.userInteractionEnabled = YES;
			self.cpButton.titleLabel.enabled = YES;
			self.clearButton.layer.borderColor = SELECTIONCOLOR.CGColor;
			self.clearButton.enabled = YES;
			self.clearButton.userInteractionEnabled = YES;
			self.clearButton.titleLabel.enabled = YES;
			self.noteButton.layer.borderColor = SELECTIONCOLOR.CGColor;
			self.noteButton.enabled = YES;
			self.noteButton.userInteractionEnabled = YES;
			self.noteButton.titleLabel.enabled = YES;
		} else {
			self.clearButton.layer.borderColor = RGB(0, 0, 0, 0.1).CGColor;
			self.clearButton.enabled = NO;
			self.clearButton.userInteractionEnabled = NO;
			self.clearButton.titleLabel.enabled = NO;
			self.noteButton.layer.borderColor = RGB(0, 0, 0, 0.1).CGColor;
			self.noteButton.enabled = NO;
			self.noteButton.userInteractionEnabled = NO;
			self.noteButton.titleLabel.enabled = NO;
			self.cpButton.layer.borderColor = RGB(0, 0, 0, 0.1).CGColor;
			self.cpButton.enabled = NO;
			self.cpButton.userInteractionEnabled = NO;
			self.cpButton.titleLabel.enabled = NO;
		}

		if (self.currentDayEntry != nil && [self.currentDayEntry checkOutTime] != nil) {
			self.hoursToDistributeCountLabel.text = [self.currentDayEntry netHoursAsDecimalString];
			self.hoursWorkedCountLabel.text = [self.currentDayEntry netHoursAsDecimalString];
		} else {
			self.hoursToDistributeCountLabel.text = NULLSTRING;
			self.hoursWorkedCountLabel.text = NULLSTRING;
		}
	}
}

// -(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return @"test";
// }

/*
 * // Override to support conditional editing of the table view.
 * - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 * // Return NO if you do not want the specified item to be editable.
 * return YES;
 * }
 */

/*
 * // Override to support editing the table view.
 * - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 * if (editingStyle == UITableViewCellEditingStyleDelete) {
 * // Delete the row from the data source
 * [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 * }
 * else if (editingStyle == UITableViewCellEditingStyleInsert) {
 * // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 * }
 * }
 */

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentDayEntry == nil) {
		return;
	}

	[self.utility hidePicker:self.cpyPickerViewController withTable:self.activeTableViewCenter withOriginalFrame:self.originalTableViewFrame];


	Project *tempProject = [self.fetchedResultsController objectAtIndexPath:indexPath];

	ProjectEntry *projectEntry = [self projectEntryOfDayEntry:self.currentDayEntry forProject:tempProject];

	if (projectEntry != nil) {
		[[AXDataStore sharedInstance] deleteObject:projectEntry];
	} else {
		[[AXDataStore sharedInstance] createProjectEntryWithDayEntry:self.currentDayEntry andProject:tempProject];
	}

	[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
}

#pragma mark - AXTimePickerViewControllerProtocol methods
- (void)cancelActionDatePicker {
	if ([self.utility isViewOnScreen:self.cpyPickerViewController]) {
		[self dismissDatePicker];
	}
}

- (void)doneActionDatePicker:(NSDate *)date {
	if ([self.utility isViewOnScreen:self.cpyPickerViewController]) {
		DayEntry *dayEntry = [[AXDataStore sharedInstance] getLatestDayEntryForDate:date];
		if (dayEntry == nil) {
			dayEntry = [[AXDataStore sharedInstance] createDayEntry];
			dayEntry.checkInTime = [self.currentDayEntry.checkInTime updateDayMonthYearComponentWithDate:date];
			dayEntry.checkOutTime = [self.currentDayEntry.checkOutTime updateDayMonthYearComponentWithDate:date];
			dayEntry.comment = self.currentDayEntry.comment;
			dayEntry.hourlyWage = self.currentDayEntry.hourlyWage;
			for (Pause *pause in self.currentDayEntry.pauses) {
				Pause *newPause = [[AXDataStore sharedInstance] createPause];
				newPause.startTime = [pause.startTime updateDayMonthYearComponentWithDate:date];
				newPause.endTime = [pause.endTime updateDayMonthYearComponentWithDate:date];
				[dayEntry addPausesObject:newPause];
			}
		} else {
			MEAlertView *alertView = [[MEAlertView alloc] initWithTitle:NSLS_WARNINGPOPUP message:NSLocalizedString(@"Do you wish to overwrite an existing day entry?", "Overwrite dayentry alert view content: Do you wish to overwrite an existing day entry?")];
			[alertView setCancelButtonWithTitle:NSLocalizedString(@"No", "Alert view deny answer: No.")];

			// Example with block. addOtherButtonWithTitle:target:action:withObject: and its variants are also available.
			[alertView addOtherButtonWithTitle:NSLocalizedString(@"Yes", "Alert view accept answer: Yes.") onTapped:^{
			     // cfu refactor
				 dayEntry.checkInTime = [self.currentDayEntry.checkInTime updateDayMonthYearComponentWithDate:date];
				 dayEntry.checkOutTime = [self.currentDayEntry.checkOutTime updateDayMonthYearComponentWithDate:date];
				 dayEntry.comment = self.currentDayEntry.comment;
				 dayEntry.hourlyWage = self.currentDayEntry.hourlyWage;
				 for (Pause * pause in self.currentDayEntry.pauses) {
					 Pause *newPause = [[AXDataStore sharedInstance] createPause];
					 newPause.startTime = [pause.startTime updateDayMonthYearComponentWithDate:date];
					 newPause.endTime = [pause.endTime updateDayMonthYearComponentWithDate:date];
					 [dayEntry addPausesObject:newPause];
				 }
			 }];
			[alertView show];
		}
	}
	[self dismissDatePicker];
}

- (void)dateActionDatePicker {
	// cfu empty implementation
//	if ([self.utility isViewOnScreen:self.timePickerViewController]) {
//		NSIndexPath *indexPath = [self.activeTableViewCenter indexPathForSelectedRow];
//		UITableViewCell *cell = [self.activeTableViewCenter cellForRowAtIndexPath:indexPath];
//
//		cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.timePickerViewController.datePicker.date];
//	} else if ([self.utility isViewOnScreen:self.cpyPickerViewController]) {
//		if ([[[AXDateManager sharedInstance]currentDate] isSameDay:self.cpyPickerViewController.datePicker.date]) {
//			NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//			NSDateComponents *components = [NSDateComponents new];
//			components.day = 1;
//			[self.cpyPickerViewController.datePicker setDate:[cal dateByAddingComponents:components toDate:self.cpyPickerViewController.datePicker.date options:0] animated:YES];
//		}
//	}
}

#pragma mark - private methods
- (void)setupWithDate:(NSDate *)date {
	// cfu schauen wir mal ob ich das brauche
	self.fetchedResultsController = [[AXDataStore sharedInstance] getAllActiveProjects];
	[[AXDateManager sharedInstance] setCurrentDate:date];
	self.currentDayEntry = [[AXDataStore sharedInstance] getLatestDayEntryForDate:date];
	[self.activeTableViewCenter reloadData];
}

- (void)dismissDatePicker {
	[self.utility hidePicker:self.cpyPickerViewController withTable:self.activeTableViewCenter withOriginalFrame:self.originalTableViewFrame];
}

- (UITableView *)getNonActiveTableView {
	if (self.activeTableViewCenter == self.tableView) {
		return self.tableView2;
	} else {
		return self.tableView;
	}
}

- (NSLayoutConstraint *)getConstraint:(UITableView *)tableView {
	if (tableView == self.tableView2) {
		return self.tableView2Constraint;
	} else {
		return self.tableViewConstraint;
	}
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	Project *tempProject = [self.fetchedResultsController objectAtIndexPath:indexPath];

	cell.detailTextLabel.textColor = GLOBALFONTCOLOR;
	cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
	cell.detailTextLabel.font = [UIFont fontWithName:GLOBALFONTNAME2 size:17.0];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	ProjectEntry *projectEntry = [self projectEntryOfDayEntry:self.currentDayEntry forProject:tempProject];
	UIImage *image = (projectEntry != nil) ? [UIImage imageNamed:@"checkmark_fine_selected.png"] : [UIImage imageNamed:@"checkmark_fine_unselected.png"];

	cell.imageView.image = [image imageWithBurnTint:SELECTIONCOLOR];
	cell.textLabel.numberOfLines = 2;
	if (projectEntry != nil) {
		UIView *viewContainer = [UIView new];
		viewContainer.frame = CGRectMake(0, 0, 133, 40);
//		viewContainer.backgroundColor = [UIColor redColor];
		UIView *view = [UIView new];
		view.frame = CGRectMake(0, 3, 133, 35);
		[viewContainer addSubview:view];
		CGRect textFieldFrame = CGRectMake(0.0f, 0.0f, 85, 35.0f);
		UITextField *textField = [[UITextField alloc] initWithFrame:textFieldFrame];
		[textField setClearButtonMode:UITextFieldViewModeWhileEditing];
		textField.borderStyle = UITextBorderStyleRoundedRect;
		textField.keyboardType = UIKeyboardTypeDecimalPad;
		textField.textAlignment = NSTextAlignmentRight;
		textField.font = [UIFont fontWithName:GLOBALFONTNAME2 size:17.0];
		textField.delegate = self;

		NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setMaximumFractionDigits:2];
		[numberFormatter setMinimumFractionDigits:2];
		textField.text = [numberFormatter stringFromNumber:projectEntry.duration];
		[view addSubview:textField];
		UILabel *label = [UILabel new];
		label.frame = CGRectMake(85, 0, 20, 35);
		label.font = [UIFont fontWithName:GLOBALFONTNAME2 size:17.0];
		label.textColor = GLOBALFONTCOLOR;
		label.text = NSLS_HOUR_SHORT;
		[view addSubview:label];
		UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
		button.frame = CGRectMake(105, 3, 28, 28);
		[button addTarget:self action:@selector(noteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[button setImage:[UIImage imageNamed:@"note_fine.png"] forState:UIControlStateNormal];
		[button setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
		button.clipsToBounds = YES;
		button.layer.cornerRadius = button.frame.size.width / 2;
		button.layer.borderColor = SELECTIONCOLOR.CGColor;
		button.layer.borderWidth = 1.0f;
		button.backgroundColor = GLOBALBACKGROUNDCOLOR;
		[button setTintColor:SELECTIONCOLOR];
		[view addSubview:button];
		cell.accessoryView = viewContainer;
//		cell.accessoryView.backgroundColor = [UIColor greenColor];
	} else {
		cell.accessoryView = nil;
	}
	cell.detailTextLabel.text = @"";
	[cell.textLabel setText:tempProject.name];

	//	cell.detailTextLabel.text = [tempProject getLatestHourlyWageDisplayValue];
}

- (ProjectEntry *)projectEntryOfDayEntry:(DayEntry *)dayEntry forProject:(Project *)project {
	NSSet *projectEntries = [dayEntry projectEntries];

	for (ProjectEntry *projectEntry in projectEntries) {
		if (projectEntry.project == project) {
			return projectEntry;
		}
	}
	return nil;
}

- (void)noteButtonClicked:(id)sender {
	if ([sender isKindOfClass:[UIButton class]]) {
		UIButton *button = sender;
		ProjectEntry *projectEntry = [self projectEntryForUIView:button];
		[self.utility showNoteControllerWithTextToDisplay:projectEntry.comment onCompletion:^(NSString *textViewString) {
			 projectEntry.comment =  textViewString;
		 } withViewController:self];
	}
}

- (ProjectEntry *)projectEntryForUIView:(UIView *)view {
	CGRect frame = [view convertRect:[view bounds] toView:self.activeTableViewCenter];
	CGPoint topLeft = CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame));
	NSIndexPath *indexPath = [self.activeTableViewCenter indexPathForRowAtPoint:topLeft];
	Project *tempProject = [self.fetchedResultsController objectAtIndexPath:indexPath];

	return [self projectEntryOfDayEntry:self.currentDayEntry forProject:tempProject];
}

- (void)dismissKeyboard {
	if (self.activeKeyboardObject != nil) {
		[self.activeKeyboardObject resignFirstResponder];
		[self.view removeGestureRecognizer:self.tapGestureRecognizer];
		self.tapGestureRecognizer = nil;
	}
}

//- (void)dismissPicker:(AXPickerViewController *)picker {
//	if (picker != nil && [self.utility isViewOnScreen:picker]) {
//		[self.utility hidePicker:picker withTable:self.tableView withOriginalFrame:self.originalTableViewFrame];
//		self.activePickerViewController = nil;
//		[self.tableView reloadData];
//	}
//}

#pragma mark - ax calendar protocol methods
- (void)navigateForward:(BOOL)forward {
	[self dismissDatePicker];
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [cal components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSTimeZoneCalendarUnit) fromDate:[[AXDateManager sharedInstance] currentDate]];

	CGRect finalPositionForNewTable =  self.activeTableViewCenter.frame;
	UITableView *newTable = [self getNonActiveTableView];

	if (forward) {
		CGRect finalPositionForNewRightTable =  self.activeTableViewCenter.frame;
		finalPositionForNewRightTable.origin.x = finalPositionForNewRightTable.origin.x + finalPositionForNewRightTable.size.width;

		CGRect finalPositonForOldTable =  self.activeTableViewCenter.frame;
		finalPositonForOldTable.origin.x = finalPositonForOldTable.origin.x - finalPositonForOldTable.size.width;

		newTable.frame = finalPositionForNewRightTable;
		[self getConstraint:newTable].constant = 320;

		self.activeTableViewCenter = newTable;
		newTable.delegate = self;
		newTable.dataSource = self;

		[components setDay:components.day + 1];
		[self setupWithDate:[cal dateFromComponents:components]];

		[UIView animateWithDuration:ANIMATIONDURATION
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
			 self.activeTableViewCenter.frame = finalPositionForNewTable;
			 [self getConstraint:self.activeTableViewCenter].constant = 0;

			 [[self getNonActiveTableView] setFrame:finalPositonForOldTable];
			 [self getConstraint:[self getNonActiveTableView]].constant = -320;
		 } completion:^(BOOL finished) {
			 UITableView *nonactive = [self getNonActiveTableView];
			 nonactive.delegate = nil;
			 nonactive.dataSource = nil;
		 }];
	} else {
		CGRect finalPositionForNewLeftTable =  self.activeTableViewCenter.frame;
		finalPositionForNewLeftTable.origin.x = finalPositionForNewLeftTable.origin.x - finalPositionForNewLeftTable.size.width;

		CGRect finalPositonForOldTable =  self.activeTableViewCenter.frame;
		finalPositonForOldTable.origin.x = finalPositonForOldTable.origin.x + finalPositonForOldTable.size.width;

		newTable.frame = finalPositionForNewLeftTable;
		[self getConstraint:newTable].constant = -320;

		self.activeTableViewCenter = newTable;
		newTable.delegate = self;
		newTable.dataSource = self;

		[components setDay:components.day - 1];
		[self setupWithDate:[cal dateFromComponents:components]];

		[UIView animateWithDuration:ANIMATIONDURATION
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
			 self.activeTableViewCenter.frame = finalPositionForNewTable;
			 [self getConstraint:self.activeTableViewCenter].constant = 0;

			 [[self getNonActiveTableView] setFrame:finalPositonForOldTable];
			 [self getConstraint:[self getNonActiveTableView]].constant = 320;
		 } completion:^(BOOL finished) {
			 UITableView *nonactive = [self getNonActiveTableView];
			 nonactive.delegate = nil;
			 nonactive.dataSource = nil;
		 }];
	}
}

- (void)goToToday {
	NSDate *nowDate = [NSDate date];

	if (![nowDate isSameDay:[[AXDateManager sharedInstance]currentDate]]) {
		[self dismissDatePicker];
	}
	[self setupWithDate:nowDate];
}

#pragma mark - outlet user actions
- (IBAction)clearAction:(id)sender {
	MEAlertView *alertView = [[MEAlertView alloc] initWithTitle:NSLS_WARNINGPOPUP message:NSLocalizedString(@"Do you wish to clear the whole day?", "Clear dayentry alert view content: Do you wish to clear the whole day?")];

	[alertView setCancelButtonWithTitle:NSLocalizedString(@"No", "Alert view deny answer: No.")];

	// Example with block. addOtherButtonWithTitle:target:action:withObject: and its variants are also available.
	[alertView addOtherButtonWithTitle:NSLocalizedString(@"Yes", "Alert view accept answer: Yes.") onTapped:^{
		 if (self.currentDayEntry != nil) {
			 [[AXDataStore sharedInstance] deleteObject:self.currentDayEntry];
			 self.currentDayEntry = nil;
			 [self.activeTableViewCenter reloadData];
		 }
	 }];
	[alertView show];
}

- (IBAction)noteAction:(id)sender {
	__weak DayEntry *dayEntry = self.currentDayEntry;

	[self.utility showNoteControllerWithTextToDisplay:self.currentDayEntry.comment  onCompletion:^(NSString *textViewString) { dayEntry.comment =  textViewString; } withViewController:self];
}

- (IBAction)copyAction:(id)sender {
	//    if (![self.utility isViewOnScreen:self.timePickerViewController]) {
	self.originalTableViewFrame = self.activeTableViewCenter.frame;
	[self.utility showPicker:self.cpyPickerViewController withTable:self.activeTableViewCenter];
	//    }

	if (self.currentDayEntry != nil && self.currentDayEntry.checkInTime != nil) {
		[self.cpyPickerViewController.datePicker setDate:self.currentDayEntry.checkInTime];
	} else {
		[self.cpyPickerViewController.datePicker setDate:[[AXDateManager sharedInstance] currentDate]];
	}
}

#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController {
	if (__fetchedResultsController != nil) {
		return __fetchedResultsController;
	}

	self.fetchedResultsController = [[AXDataStore sharedInstance] getAllActiveProjects];
	self.fetchedResultsController.delegate = self;

	return __fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.activeTableViewCenter beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//	switch (type) {
//		case NSFetchedResultsChangeInsert :
//			[self.activeTableViewCenter insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//			break;
//
//		case NSFetchedResultsChangeDelete :
//			[self.activeTableViewCenter deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//			break;
//	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *tableView = self.activeTableViewCenter;

	switch (type) {
		case NSFetchedResultsChangeInsert :
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;

		case NSFetchedResultsChangeDelete :
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;

		case NSFetchedResultsChangeUpdate :
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
		case NSFetchedResultsChangeMove :
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.activeTableViewCenter endUpdates];
}

#pragma mark - textfield delegate methods
- (void)textFieldDidEndEditing:(UITextField *)textField {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];

	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	ProjectEntry *projectEntry = [self projectEntryForUIView:textField];

	if ([[textField.text trim] isEqualToString:@""]) {
		[projectEntry setDuration:[NSNumber numberWithInt:0]];
	} else {
		NSNumber *hours = [numberFormatter numberFromString:textField.text];
		[projectEntry setDuration:hours];
	}

	[self dismissKeyboard];
	[self.tableView reloadData];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
//	[self cancelActionPicker];
	self.activeKeyboardObject = textField;

	if (self.tapGestureRecognizer == nil) {
		self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
		[self.view addGestureRecognizer:self.tapGestureRecognizer];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - AXPickerViewControllerProtocol delegate methods
//- (void)cancelActionPicker {
//	if ([self.utility isViewOnScreen:self.activePickerViewController]) {
//		[self dismissPicker:self.activePickerViewController];
//		[self.tableView reloadData];
//	}
//}
//
//- (void)doneActionPicker {
//	[self dismissPicker:self.activePickerViewController];
//}

@end
