//
//  AXNoteViewController.m
//  aXTimes
//
//  Created by fuesec on 5/20/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXNoteViewController.h"
#import "NSString+AXNSStringCategory.h"
#import "AXStandardTableViewCell.h"

@interface AXNoteViewController ()

@property (strong, nonatomic) NSMutableArray *fetchedCommentsAll;
@property (strong, nonatomic) NSMutableArray *fetchedCommentsFrequent;

@property (strong, nonatomic) UIBarButtonItem *clearButton;

@property (nonatomic) NSUInteger fetchedCommentsAllOffset;
@property (nonatomic) NSUInteger fetchedCommentsFrequentOffset;

@property (nonatomic) NSUInteger fetchedCommentsAllCount;
@property (nonatomic) NSUInteger fetchedCommentsFrequentCount;

@property (nonatomic) NSUInteger fetchLimit;

@property (strong, nonatomic) IBOutlet UISegmentedControl *noteSegmentedControl;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AXNoteViewController

#pragma mark - view lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
    self.title = NSLS_COMMENT;
    self.fetchLimit = 30;
    self.fetchedCommentsAllOffset = 0;
    self.fetchedCommentsFrequentOffset = 0;
    self.fetchedCommentsAllCount = [[AXDataStore sharedInstance] getCountCommentsAll];
    self.fetchedCommentsFrequentCount = [[AXDataStore sharedInstance] getCountCommentsFrequent];

	self.noteSegmentedControl.tintColor = SELECTIONCOLOR;
	self.tableView.backgroundColor = GLOBALBACKGROUNDCOLOR;
    self.textView.textContainerInset = UIEdgeInsetsMake(0, 10, 0, 10);
    [self.textView setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    self.view.backgroundColor = GLOBALBACKGROUNDCOLOR;
    
    self.clearButton = [[UIBarButtonItem alloc]
                        initWithImage:[UIImage imageNamed:@"eraser"]
                        style:UIBarButtonItemStylePlain
                        target:self
                        action:@selector(clear)];
    self.navigationItem.rightBarButtonItem = self.clearButton;
    
	self.textView.text = self.textToDisplay;
	[self.textView becomeFirstResponder];

	[self.noteSegmentedControl setTitle:NSLS_NOTE_CURRENT_SEGMENT forSegmentAtIndex:0];
	[self.noteSegmentedControl setTitle:NSLS_NOTE_FREQUENT_SEGMENT forSegmentAtIndex:1];
	[self.noteSegmentedControl setTitle:NSLS_NOTE_All_SEGMENT forSegmentAtIndex:2];
	self.noteSegmentedControl.selectedSegmentIndex = 0;

	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.hidden = YES;
    UINib *commentCellNib = [UINib nibWithNibName:NSStringFromClass([AXStandardTableViewCell class]) bundle:nil];
    [self.tableView registerNib:commentCellNib forCellReuseIdentifier:NSStringFromClass([AXStandardTableViewCell class])];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
    NSString *deviceLanguageLocaleString = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([deviceLanguageLocaleString isEqualToString:@"sv"]) {
        [self.noteSegmentedControl setWidth:132.0 forSegmentAtIndex:1];
    }
    
    if ([deviceLanguageLocaleString isEqualToString:@"ru"]) {
        self.noteSegmentedControl.apportionsSegmentWidthsByContent = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    self.fetchedCommentsAll = [NSMutableArray new];
    self.fetchedCommentsFrequent = [NSMutableArray new];

    self.fetchedCommentsAll = [NSMutableArray arrayWithArray:[[AXDataStore sharedInstance] getCommentsAllWithLimit:self.fetchLimit withOffset:self.fetchedCommentsAllOffset]];

    self.fetchedCommentsAllOffset = self.fetchedCommentsAllOffset + 1;

	self.fetchedCommentsFrequent = [NSMutableArray arrayWithArray:[[AXDataStore sharedInstance] getCommentsFrequentWithLimit:self.fetchLimit withOffset:self.fetchedCommentsFrequentOffset]];
    self.fetchedCommentsFrequentOffset = self.fetchedCommentsFrequentOffset + 1;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self done];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - user outlet actions

- (IBAction)cancelAction:(id)sender {
    [self.view endEditing:YES];
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)done {
    [self.view endEditing:YES];
    
    if ([self.delegate respondsToSelector:@selector(doneChangingComment:)]) {
        [self.delegate doneChangingComment:[self.textView.text trim]];
    }
}

- (IBAction)noteSegmentedControlAction:(id)sender {
	[self updateViewController];
}

#pragma mark - private methods

- (void)updateViewController {
	switch (self.noteSegmentedControl.selectedSegmentIndex) {
		case 0 :
			[self.textView becomeFirstResponder];
			self.textView.hidden = NO;
			self.tableView.hidden = YES;
            self.navigationItem.rightBarButtonItem = self.clearButton;
			break;
		case 1 :
			[self.tableView reloadData];
			[self.textView resignFirstResponder];
			self.tableView.hidden = NO;
			self.textView.hidden = YES;
            self.navigationItem.rightBarButtonItem = nil;
			break;
		case 2 :
			[self.tableView reloadData];
			[self.textView resignFirstResponder];
			self.tableView.hidden = NO;
			self.textView.hidden = YES;
            self.navigationItem.rightBarButtonItem = nil;
			break;
		default :
			break;
	}
}

- (void)clear {
    self.textView.text = @"";
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.noteSegmentedControl.selectedSegmentIndex == 1) {
		return self.fetchedCommentsFrequent.count;
	} else if (self.noteSegmentedControl.selectedSegmentIndex == 2) {
		return self.fetchedCommentsAll.count;
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"AXStandardTableViewCell";
	AXStandardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	cell.backgroundColor = GLOBALBACKGROUNDCOLOR;
	cell.customTextLabel.textColor = GLOBALFONTCOLOR;
    cell.customDetailTextLabel.text = @"";

	if (self.noteSegmentedControl.selectedSegmentIndex == 1) {
		cell.customTextLabel.text = ((Comment *)self.fetchedCommentsFrequent[indexPath.row]).commentText;
	} else if (self.noteSegmentedControl.selectedSegmentIndex == 2) {
		cell.customTextLabel.text = ((Comment *)self.fetchedCommentsAll[indexPath.row]).commentText;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.noteSegmentedControl.selectedSegmentIndex == 1) {
        if((indexPath.row == [self.fetchedCommentsFrequent count] - 1)&& ([self.fetchedCommentsFrequent count] < self.fetchedCommentsFrequentCount)) {

            [self.fetchedCommentsFrequent addObjectsFromArray:[[AXDataStore sharedInstance] getCommentsFrequentWithLimit:self.fetchLimit withOffset:self.fetchedCommentsFrequentOffset * self.fetchLimit]];

            [self.tableView reloadData];
        }
	} else if (self.noteSegmentedControl.selectedSegmentIndex == 2) {
        if((indexPath.row == [self.fetchedCommentsAll count] - 1)&& ([self.fetchedCommentsAll count] < self.fetchedCommentsAllCount)) {
            
            [self.fetchedCommentsAll addObjectsFromArray:[[AXDataStore sharedInstance] getCommentsAllWithLimit:self.fetchLimit withOffset:self.fetchedCommentsAllOffset * self.fetchLimit]];

            [self.tableView reloadData];

        }
	}
}

/**
 *  Method used with plain tableView style to eliminate the empty rows.
 */
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * commentString;
	if (self.noteSegmentedControl.selectedSegmentIndex == 1) {
		commentString = ((Comment *)self.fetchedCommentsFrequent[indexPath.row]).commentText;
	} else if (self.noteSegmentedControl.selectedSegmentIndex == 2) {
		commentString = ((Comment *)self.fetchedCommentsAll[indexPath.row]).commentText;
    }
	self.textToDisplay = commentString;
	self.textView.text = commentString;
	[self.noteSegmentedControl setSelectedSegmentIndex:0];
	[self updateViewController];
}

@end
