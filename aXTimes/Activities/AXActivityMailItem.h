//
//  AXActivityMailItem.h
//  aXTimes
//
//  Created by fuesec on 10/24/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import <MessageUI/MessageUI.h>

typedef UIViewController *  (^MailActivitySelected)(MFMailComposeViewController *mailComposeViewController);

@interface AXActivityMailItem : NSObject

@property (nonatomic, copy) MailActivitySelected mailActivitySelected;

+ (instancetype)mailActivityItemWithSelectionHandler:(MailActivitySelected)mailActivitySelected;

@end
