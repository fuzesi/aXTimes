//
//  AXActivityMessagesItem.h
//  aXTimes
//
//  Created by fuesec on 10/31/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import <MessageUI/MessageUI.h>

typedef UIViewController *  (^MessageActivitySelected)(MFMessageComposeViewController *messageComposeViewController);

@interface AXActivityMessagesItem : NSObject
@property (nonatomic, copy) MessageActivitySelected messageActivitySelected;

+ (instancetype)messageActivityItemWithSelectionHandler:(MessageActivitySelected)mailActivitySelected;
@end
