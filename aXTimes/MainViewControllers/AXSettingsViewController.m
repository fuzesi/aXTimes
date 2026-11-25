//
//  AXSettingsViewController.m
//  aXTimes
//
//  Created by fuesec on 4/27/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXSettingsViewController.h"
#import "AXUtility.h"
#import "AXSettingsManager.h"
#import "NSString+AXNSStringCategory.h"
#import <MEAlertView.h>
#import "NSDate+AXNSDateCategory.h"
#import "AXCommentTableViewCell.h"
#import "AXSegmentedControlTableViewCell.h"


// working week + days per day + hourly wage + currency locale + default comment + default pause + time formatting
static const int NUMBEROFROWSINFIRSTSECTION = 7;
// email + language + decimal seperator + incl. income + incl. timezone
static const int NUMBEROFROWSINEXPORTSECTION = 5;
static NSString *commentCellString = @"CommentCell";


@interface AXSettingsViewController ()

@property (nonatomic, strong) UITextField *activeKeyboardObject;
@property (nonatomic, strong) UITextField *hoursPerDayTextField;
@property (nonatomic, strong) UITextField *hourlyWageTextField;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UISwitch *exportWageSwitch;
@property (nonatomic, strong) UISwitch *exportInclTimezone;
@property (nonatomic, strong) UILabel *commentPreviewLabel;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) AXCurrencyPickerViewController *currencyPickerViewController;
@property (strong, nonatomic) AXExportLanguagePickerViewController *exportLanguagePickerViewController;
@property (strong, nonatomic) AXWorkTimeUnitPickerViewController *timeUnitPickerViewController;
@property (strong, nonatomic) AXNetRoundingPickerViewController *netRoundingPickerViewController;
@property (strong, nonatomic) AXExportDecimalSeparatorPickerViewController *exportDecimalSeparatorPickerViewController;
@property (nonatomic, strong) AXUtility *utility;
@property (nonatomic, strong) AXSettingsManager *settingsController;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;
@property (nonatomic) CGRect originalTableViewFrame;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@end

@implementation AXSettingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
	self =  [super initWithCoder:aDecoder];
	if (self) {
		self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"settings_fine_selected.png"];
		self.navigationController.navigationBar.topItem.title = NSLS_TABSETTINGS;
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
		[[NSUserDefaults standardUserDefaults] addObserver:self
												forKeyPath:SETTINGS_DEFAULTCOMMENT options:NSKeyValueObservingOptionNew
												   context:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
													 name:UIKeyboardDidShowNotification object:nil];
	}
	return self;
}

// KVO handler
- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject
						change:(NSDictionary *)aChange context:(void *)aContext {
	if ([aKeyPath isEqualToString:SETTINGS_DEFAULTCOMMENT]) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
		AXCommentTableViewCell *commentCell = (AXCommentTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		commentCell.commentLabel.text = [self.settingsController getDefaultComment];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
//	self.currencyPickerViewController = [AXCurrencyPickerViewController new];
    self.currencyPickerViewController = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([AXCurrencyPickerViewController class]) owner:nil options:nil] objectAtIndex:0];
    self.exportLanguagePickerViewController = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([AXExportLanguagePickerViewController class]) owner:nil options:nil] objectAtIndex:0];
    self.timeUnitPickerViewController = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([AXWorkTimeUnitPickerViewController class]) owner:nil options:nil] objectAtIndex:0];
    self.netRoundingPickerViewController = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([AXNetRoundingPickerViewController class]) owner:nil options:nil] objectAtIndex:0];
    self.exportDecimalSeparatorPickerViewController = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([AXExportDecimalSeparatorPickerViewController class]) owner:nil options:nil] objectAtIndex:0];

	[self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
    //somehow the color is different here than on the other tableviews if not set here
    [self.tableView setBackgroundColor:GLOBALBACKGROUNDCOLOR2];
	self.utility = [AXUtility new];
	self.settingsController = [AXSettingsManager new];
    
    UINib *commentCellNib = [UINib nibWithNibName:NSStringFromClass([AXCommentTableViewCell class]) bundle:nil];
    [self.tableView registerNib:commentCellNib forCellReuseIdentifier:commentCellString];
    
    UINib *segmentedControlCellNib = [UINib nibWithNibName:NSStringFromClass([AXSegmentedControlTableViewCell class]) bundle:nil];
    [self.tableView registerNib:segmentedControlCellNib forCellReuseIdentifier:NSStringFromClass([AXSegmentedControlTableViewCell class])];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [self.tableView reloadData];
	BOOL showWelcomePopup = [[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_SHOWWELCOMEPOPUP];
	if (showWelcomePopup) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:SETTINGS_SHOWWELCOMEPOPUP];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS_WELCOMETITLEALERT message:NSLS_WELCOMEMESSAGE delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLS_OKPOPUP, nil];
		[alert show];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.originalTableViewFrame = self.tableView.frame;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.lastSelectedIndexPath = nil;

//	[self dismissPicker:self.activePickerViewController];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0 :
			return NUMBEROFROWSINFIRSTSECTION;

			break;
		case 1 :
			return 2;

			break;
		case 2 :
			return NUMBEROFROWSINEXPORTSECTION;

			break;
		default :
			return 0;

			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = nil;
	AXCommentTableViewCell *commentCell = nil;
    AXSegmentedControlTableViewCell *segmentedControlCell;

	if (indexPath.row == 4 &&
        indexPath.section == 0) {
		commentCell = [tableView dequeueReusableCellWithIdentifier:commentCellString forIndexPath:indexPath];
		commentCell.customTextLabel.text = @" ";
		commentCell.commentLabel.text = @" ";
//		commentCell.textLabel.text = @"";
//		commentCell.detailTextLabel.text = @"";
		commentCell.userInteractionEnabled = YES;
		commentCell.accessoryView = nil;
		commentCell.selectionStyle = UITableViewCellSelectionStyleBlue;
        commentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		commentCell.backgroundColor = GLOBALBACKGROUNDCOLOR;
//		commentCell.detailTextLabel.textColor = GLOBALDETAILFONTCOLOR;
    } else if (indexPath.row == 6 &&
               indexPath.section == 0) {
        segmentedControlCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AXSegmentedControlTableViewCell class]) forIndexPath:indexPath];
        
        segmentedControlCell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		cell.textLabel.text = @" ";
		cell.detailTextLabel.text = @" ";
		cell.accessoryView = nil;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
	}

	if (indexPath.section == 0) {
		switch (indexPath.row) {
//			case 0 : {
//				cell.textLabel.text = NSLocalizedsString(@"Projects", @"Translate the term 'Hours per day' which is diplayed as a label in the settings.");
//				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//				break;
//			}
			case 0 : {
				cell.textLabel.text = NSLS_WORKINGWEEK;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			}
			case 1 : {
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.text = NSLocalizedString(@"Hours per day", @"Translate the term 'Hours per day' which is diplayed as a label in the settings.");
				CGRect textFieldFrame = CGRectMake(0.0f, 0.0f, 110.0f, 30.0f);
				UITextField *textField2 = [[UITextField alloc] initWithFrame:textFieldFrame];
				[textField2 setClearButtonMode:UITextFieldViewModeWhileEditing];
				textField2.borderStyle = UITextBorderStyleNone;
				textField2.keyboardType = UIKeyboardTypeDecimalPad;
				textField2.textAlignment = NSTextAlignmentRight;
				textField2.font = [UIFont fontWithName:GLOBALFONTNAME2 size:17.0];
				textField2.text = [self.settingsController getHoursPerDayDisplayValue];
				self.hoursPerDayTextField = textField2;
				self.hoursPerDayTextField.delegate = self;
				cell.accessoryView = self.hoursPerDayTextField;
//				((UITextField *)cell.accessoryView).text = [self.settingsController getHoursPerDayDisplayValue];
				break;
			}
			case 2 : {
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.text = NSLS_HOURLYWAGE;
				CGRect textFieldFrame = CGRectMake(0.0f, 0.0f, 110.0f, 30.0f);
				UITextField *textField = [[UITextField alloc] initWithFrame:textFieldFrame];
				[textField setClearButtonMode:UITextFieldViewModeWhileEditing];
				textField.borderStyle = UITextBorderStyleNone;
				textField.keyboardType = UIKeyboardTypeDecimalPad;
				textField.textAlignment = NSTextAlignmentRight;
				textField.font = [UIFont fontWithName:GLOBALFONTNAME2 size:17.0];
				textField.text = [self.settingsController getHourlyWageDisplayValue];
				self.hourlyWageTextField = textField;
				self.hourlyWageTextField.delegate = self;
				cell.accessoryView = self.hourlyWageTextField;
				((UITextField *)cell.accessoryView).text = [self.settingsController getHourlyWageDisplayValue];
				break;
			}
			case 3 : {
				cell.textLabel.text = NSLS_WAGECURRENCY_SETTINGS;
				cell.detailTextLabel.text = [self.settingsController getCurrencyIso];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			}
			case 4 : {
				commentCell.customTextLabel.text = NSLS_STANDARDCOMMENT;
                commentCell.customTextLabel.textColor = GLOBALFONTCOLOR;
				commentCell.commentLabel.text = [self.settingsController getDefaultComment];

				return commentCell;

				break;
			}
            case 5 : {
                cell.textLabel.text = NSLS_DEFAULTPAUSE_SETTINGS;
                
                if ([self.settingsController isDefaultPause]) {
                    cell.detailTextLabel.text = NSLS_ON;
                } else {
                    cell.detailTextLabel.text = NSLS_OFF;
                }
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
            case 6 : {
                segmentedControlCell.customTextLabel.text = NSLS_TIMEFORMAT;
                [segmentedControlCell.segmentedControl setSelectedSegmentIndex:[AXSettingsManager timeFormatting]];
                [segmentedControlCell.segmentedControl setTitle:NSLS_TIMEFORMAT_DEFAULT
                                              forSegmentAtIndex:0];
                [segmentedControlCell.segmentedControl setTitle:NSLS_TIMEFORMAT_HOURMINUTE
                                              forSegmentAtIndex:1];
                [segmentedControlCell.segmentedControl addTarget:self
                                                          action:@selector(segmentedControlTapped:)
                                                forControlEvents:UIControlEventValueChanged];
                return segmentedControlCell;
                break;
            }
            default :
				break;
		}
	} else if (indexPath.section == 1) {
		switch (indexPath.row) {
			case 0 : {
				cell.textLabel.text = NSLocalizedString(@"Time unit", @"Translate the term 'Time unit' which is diplayed as a label in the settings.");
				cell.detailTextLabel.text = [self.settingsController getWorkTimeUnitDisplayValue];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			}
			case 1 : {
				cell.textLabel.text = NSLocalizedString(@"Rounding", @"Translate the word 'Rounding' which is diplayed as a label in the settings.");
				cell.detailTextLabel.text = [self.settingsController getNetRoundingDisplayValue];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			}
			default :
				break;
		}
	} else if (indexPath.section == 2) {
		switch (indexPath.row) {
			case 0 : {
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.text = NSLS_EMAIL;
				CGRect textFieldFrame3 = CGRectMake(0.0f, 0.0f, 205.0f, 30.0f);
				UITextField *textField3 = [[UITextField alloc] initWithFrame:textFieldFrame3];
				[textField3 setClearButtonMode:UITextFieldViewModeWhileEditing];
				textField3.borderStyle = UITextBorderStyleNone;
				textField3.keyboardType = UIKeyboardTypeEmailAddress;
				textField3.autocorrectionType = UITextAutocorrectionTypeNo;
				textField3.returnKeyType = UIReturnKeyDefault;
				textField3.textAlignment = NSTextAlignmentRight;
				textField3.font = [UIFont fontWithName:GLOBALFONTNAME2 size:17.0];
				textField3.text = [self.settingsController getExportEmail];
				self.emailTextField = textField3;
				self.emailTextField.delegate = self;
				cell.accessoryView = self.emailTextField;
				break;
			}
			case 1 : {
				cell.textLabel.text = NSLocalizedString(@"Language", @"Translate the word 'Language'");
				cell.detailTextLabel.text = [self.settingsController getExportLanguageLocaleDisplayValue];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			}
			case 2 : {
				cell.textLabel.text = NSLocalizedString(@"Decimal Separator", @"Translate the tern 'Decimal separator' which is diplayed as a label in the settings.");
				cell.detailTextLabel.text = [self.settingsController getExportDecimalSeparatorDisplayValue];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			}
			case 3 : {
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.text = NSLS_INCL_WAGE;
				self.exportWageSwitch = [UISwitch new];
				[self.exportWageSwitch setOnTintColor:C_CLOVER];
				[self.exportWageSwitch addTarget:self
										   action:@selector(exportWageSwitchChanged:)
								 forControlEvents:UIControlEventValueChanged];
				cell.accessoryView = self.exportWageSwitch;
				((UISwitch *)cell.accessoryView).on = [self.settingsController getExportWage];
				break;
			}
			case 4 : {
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.text = NSLS_INCL_TIMEZONE;
				self.exportInclTimezone = [UISwitch new];
				[self.exportInclTimezone setOnTintColor:C_CLOVER];
				[self.exportInclTimezone addTarget:self
											action:@selector(inclTimezoneSwitchChanged:)
								  forControlEvents:UIControlEventValueChanged];
				cell.accessoryView = self.exportInclTimezone;
				((UISwitch *)cell.accessoryView).on = [self.settingsController getInclTimezone];
				break;
			}
			default :
				break;
		}
	}

	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0 :
			return NSLocalizedString(@"General", "'General' section header in settings view");

			break;
		case 1 :
			return NSLocalizedString(@"Report_settings_section_title", @"Translate the tern 'Report' which is diplayed e.g. as a label section header in the settings view for settings like 'Time unit' and 'Rounding'.");

			break;
		case 2 :
			return NSLocalizedString(@"Export", @"Translate the word 'Export' which is displayed e.g in the settings view as a section headder.");

			break;
		default :
			return @"";

			break;
	}
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.lastSelectedIndexPath != nil && self.lastSelectedIndexPath.row == indexPath.row) {
		return;
	}
//	[self dismissPicker:self.activePickerViewController];

	self.lastSelectedIndexPath = indexPath;

	if ((indexPath.section == 0 && indexPath.row == 3) ||
        (indexPath.section == 1 && indexPath.row == 0) ||
        (indexPath.section == 1 && indexPath.row == 1) ||
        (indexPath.section == 2 && indexPath.row == 1) ||
        (indexPath.section == 2 && indexPath.row == 2)) {
		// check if picker is already on screen

//		if (self.activePickerViewController != nil && [self.utility isViewOnScreen:self.activePickerViewController]) {
//			return;
//		}

        self.lastSelectedIndexPath = nil;

		if (indexPath.section == 0 && indexPath.row == 3) {
//			self.activePickerViewController = self.currencyPickerViewController;            
            [self.navigationController pushViewController:self.currencyPickerViewController animated:YES];
		}

		if (indexPath.section == 2 && indexPath.row == 1) {
            [self.navigationController pushViewController:self.exportLanguagePickerViewController animated:YES];
		}

		if (indexPath.section == 1 && indexPath.row == 0) {
            [self.navigationController pushViewController:self.timeUnitPickerViewController animated:YES];
		}

		if (indexPath.section == 1 && indexPath.row == 1) {
            [self.navigationController pushViewController:self.netRoundingPickerViewController animated:YES];
		}

		if (indexPath.section == 2 && indexPath.row == 2) {
            [self.navigationController pushViewController:self.exportDecimalSeparatorPickerViewController animated:YES];
		}

		[self.tableView selectRowAtIndexPath:self.lastSelectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
//		[self.utility showPicker:self.activePickerViewController withTable:self.tableView];
	} else if (indexPath.section == 0 && indexPath.row == 4) {
		self.lastSelectedIndexPath = nil;
		[self performSegueWithIdentifier:@"defaultcomment_segue" sender:self];
	} else if (indexPath.section == 0 && indexPath.row == 0) {
		self.lastSelectedIndexPath = nil;
		[self performSegueWithIdentifier:@"workingweek_segue" sender:self];
    } else if (indexPath.section == 0 && indexPath.row == 5) {
        self.lastSelectedIndexPath = nil;
        [self performSegueWithIdentifier:@"defaultpause_segue" sender:self];
    }
}

#pragma mark - private methods
- (void)segmentedControlTapped:(id)sender {
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
        if (segmentedControl.selectedSegmentIndex == TimeFormattingDefault) {
            [AXSettingsManager setTimeFormatting:TimeFormattingDefault];
        } else {
            [AXSettingsManager setTimeFormatting:TimeFormattingHHMM];
        }
    }
}

- (void)dismissKeyboard {
	if (self.activeKeyboardObject != nil) {
		[self.activeKeyboardObject resignFirstResponder];
		[self.view removeGestureRecognizer:self.tapGestureRecognizer];
		self.tapGestureRecognizer = nil;
		self.activeKeyboardObject = nil;
	}
}

//- (void)dismissPicker:(AXPickerViewController *)picker {
//	if (picker != nil && [self.utility isViewOnScreen:picker]) {
//		[self.utility hidePicker:picker withTable:self.tableView withOriginalFrame:self.originalTableViewFrame];
//		self.lastSelectedIndexPath = nil;
//		self.activePickerViewController = nil;
//		[self.tableView reloadData];
//	}
//}

- (void)keyboardWillHide:(NSNotification *)notification {
	[self resizeViewWithOptions:[notification userInfo] keyboardOnScreen:NO];
}

- (void)keyboardDidShow:(NSNotification *)notification {
	[self resizeViewWithOptions:[notification userInfo] keyboardOnScreen:YES];
}

- (void)resizeViewWithOptions:(NSDictionary *)options keyboardOnScreen:(BOOL)appeared {
	CGRect keyboardEndFrame;

	[[options objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];

	CGRect viewFrame = self.tableView.frame;

	CGRect keyboardFrameEndRelative = [self.view convertRect:keyboardEndFrame fromView:nil];

	if (!appeared) {
		// restore original height
		viewFrame.size.height = self.originalTableViewFrame.size.height;
	} else {
		viewFrame.size.height =  keyboardFrameEndRelative.origin.y;
	}
	self.tableView.frame = viewFrame;

	// scroll to active textfield
	[self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForRowAtPoint:[self.tableView convertPoint:self.activeKeyboardObject.center fromView:self.activeKeyboardObject.superview]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)exportWageSwitchChanged:(UISwitch *)switchControl {
	BOOL valueToSet = switchControl.on;

	[self.settingsController setExportWage:valueToSet];
}

- (void)inclTimezoneSwitchChanged:(UISwitch *)switchControl {
	BOOL valueToSet = switchControl.on;

	[self.settingsController setInclTimezone:valueToSet];
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
//
//- (void)pickerViewString:(NSString *)string {
//	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//
//	cell.detailTextLabel.text = string;
//}

#pragma mark - textfield delegate methods
- (void)textFieldDidEndEditing:(UITextField *)textField {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];

	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[numberFormatter setMaximumFractionDigits:2];
	[numberFormatter setMinimumFractionDigits:2];
	[numberFormatter setRoundingIncrement:[NSNumber numberWithDouble:0.01]];
	[numberFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];

	if (textField == self.hoursPerDayTextField) {
		if ([[textField.text trim] isEqualToString:@""]) {
			[self.settingsController setHoursPerDay:(double)0.0];
		} else {
			NSString *stringToParse = textField.text;
			double hoursperday = 0.0;
			NSNumber *tempNumber = [numberFormatter numberFromString:stringToParse];
			if (tempNumber != nil) {
				NSString *tempString = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:tempNumber]];
				NSNumber *numberSetByUser =  [numberFormatter numberFromString:tempString];
				hoursperday = [numberSetByUser doubleValue];
			}
			[self.settingsController setHoursPerDay:hoursperday];
		}
		textField.text = [self.settingsController getHoursPerDayDisplayValue];
	} else if (textField == self.hourlyWageTextField) {
		double oldHourlyWage = [self.settingsController getHourlyWage];

		if ([[textField.text trim] isEqualToString:@""]) {
			[self.settingsController setHourlyWage:(double)0.0];
		} else {
			NSString *stringToParse = textField.text;
			double hourlyWage = 0.0;
			NSNumber *tempNumber = [numberFormatter numberFromString:stringToParse];
			if (tempNumber != nil) {
				NSString *tempString = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:tempNumber]];
				NSNumber *numberSetByUser =  [numberFormatter numberFromString:tempString];
				hourlyWage = [numberSetByUser doubleValue];
			}
			[self.settingsController setHourlyWage:hourlyWage];
		}

		double newValue = [self.settingsController getHourlyWage];
		if (oldHourlyWage != newValue) {
			NSDate *nowDate = [NSDate date];
			DayEntry *dayEntry = [[AXDataStore sharedInstance] getLatestDayEntryForDate:nowDate];

			if (dayEntry && dayEntry.checkOutTime == nil) {
				MEAlertView *alertView = [[MEAlertView alloc] initWithTitle:NSLS_QUESTION_ALERTVIEW_TITLE message:NSLocalizedString(@"Do you wish to take over the changes for the currently active entry?", "'Take over changes' alert view content. Translate 'Do you wish to take over the changes for the currently active entry?'")];
				[alertView setCancelButtonWithTitle:NSLS_NO_ALERTVIEW_ANSWER];

				// Example with block. addOtherButtonWithTitle:target:action:withObject: and its variants are also available.
				[alertView addOtherButtonWithTitle:NSLS_YES_ALERTVIEW_ANSWER onTapped:^{
					 dayEntry.hourlyWage = [NSNumber numberWithDouble:[self.settingsController getHourlyWage]];
				 }];
				[alertView show];
			}
		}
		textField.text = [self.settingsController getHourlyWageDisplayValue];
	} else if (textField == self.emailTextField) {
		[self.settingsController setExportEmail:textField.text];
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//	[self cancelActionPicker];
	self.activeKeyboardObject = textField;
	if (self.tapGestureRecognizer == nil) {
		self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
		[self.view addGestureRecognizer:self.tapGestureRecognizer];
	}
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return YES;
}

@end
