//
//  AXActivityMailItem.m
//  aXTimes
//
//  Created by fuesec on 10/24/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXActivityMailItem.h"

@implementation AXActivityMailItem

+ (instancetype)mailActivityItemWithSelectionHandler:(MailActivitySelected)mailActivitySelected {
	AXActivityMailItem *activityItem = [AXActivityMailItem new];

	activityItem.mailActivitySelected = mailActivitySelected;

	return activityItem;
}

@end
