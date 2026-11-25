//
//  AXActivityMessages.m
//  aXTimes
//
//  Created by fuesec on 10/31/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXActivityMessages.h"
#import "AXActivityMessagesItem.h"
#import "AXAppDelegate.h"
#import "UIImage+AXUIImageCategory.h"

@interface AXActivityMessages ()

@property (nonatomic, strong) AXActivityMessagesItem *activityItem;
@property (weak) MFMessageComposeViewController *messagesController;

@end

@implementation AXActivityMessages
#pragma mark - UIActivity Overrides

- (NSString *)activityType {
	return NSStringFromClass([self class]);
}

- (NSString *)activityTitle {
	return NSLS_MESSAGES;
}

- (UIImage *)activityImage {
	return [UIImage imageNamed:@"messages_activity.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	if (![MFMessageComposeViewController canSendText]) {
		return NO;
	}

	for (id item in activityItems) {
        if ([item isKindOfClass:[AXActivityMessagesItem class]]) {
            return YES;
        }
	}

	return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
	for (id item in activityItems) {
		if ([item isKindOfClass:[AXActivityMessagesItem class]]) {
			self.activityItem = item;
		}
	}
}

- (void)performActivity {
    // https://stackoverflow.com/a/43289676/1113632
    [[UINavigationBar appearance] setBarTintColor:SELECTIONCOLOR];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithSolidColor:SELECTIONCOLOR withWidth:1 andHeight:1] forBarMetrics:UIBarMetricsDefault];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:GLOBALBACKGROUNDCOLOR];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: GLOBALBACKGROUNDCOLOR};
	MFMessageComposeViewController *composeController = [MFMessageComposeViewController new];
//    MFMessageComposeViewController *composeController = [((AXAppDelegate *)[UIApplication sharedApplication].delegate) getMessageController];

	UIViewController *activityViewController = nil;

	if (self.activityItem.messageActivitySelected) {
		activityViewController = self.activityItem.messageActivitySelected(composeController);
	}

	composeController.messageComposeDelegate = self;
	self.messagesController = composeController;

	[activityViewController presentViewController:self.messagesController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

// - (UIViewController *)activityViewController {
//    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
//
//    if (self.activityItem.messageActivitySelected) {
//        self.activityItem.messageActivitySelected(messageController);
//    }
//
//    messageController.messageComposeDelegate = self;
//    return messageController;
// }

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
//    [self activityDidFinish:result == MessageComposeResultSent];
    
	[self.messagesController.presentingViewController dismissViewControllerAnimated:YES completion:^{
		 [self activityDidFinish:YES];
	 }];
}

@end
