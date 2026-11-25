//
//  AXActivityMessagesItem.m
//  aXTimes
//
//  Created by fuesec on 10/31/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXActivityMessagesItem.h"

@implementation AXActivityMessagesItem

+ (instancetype)messageActivityItemWithSelectionHandler:(MessageActivitySelected)messageActivitySelected {
	AXActivityMessagesItem *activityItem = [AXActivityMessagesItem new];

	activityItem.messageActivitySelected = messageActivitySelected;

	return activityItem;
}

@end
