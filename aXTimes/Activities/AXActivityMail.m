//
//  AXActivityMail.m
//  aXTimes
//
//  Created by fuesec on 10/23/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXActivityMail.h"
#import "AXActivityMailItem.h"
#import "AXAppDelegate.h"

@interface AXActivityMail ()

@property (nonatomic, strong) AXActivityMailItem *activityItem;
@property (weak) MFMailComposeViewController *mailController;

@end

@interface AXActivityMail ()
@end

@implementation AXActivityMail
- (NSString *)activityType {
	return NSStringFromClass([self class]);
}

- (NSString *)activityTitle {
	return NSLS_MAILACTIVITY;
}

- (UIImage *)activityImage {
	return [UIImage imageNamed:@"mail_activity.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	if (![MFMailComposeViewController canSendMail]) {
		return NO;
	}

	for (id item in activityItems) {
		if ([item isKindOfClass:[AXActivityMailItem class]]) {
			return YES;
		}
	}

	return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
	for (id item in activityItems) {
		if ([item isKindOfClass:[AXActivityMailItem class]]) {
			self.activityItem = item;
		}
	}
}

/**
 * DESCRIPTION:
 * Performs the service when no custom view controller is provided.
 * The default implementation of this method does nothing. If your service does not provide any custom UI using the activityViewController method, override this method and use it to perform the activity. Your activity must operate on the data items received in the prepareWithActivityItems: method.
 * This method is called on your app’s main thread. If your app can complete the activity quickly on the main thread, do so and call the activityDidFinish: method when it is done. If performing the activity might take some time, use this method to start the work in the background and then exit without calling activityDidFinish: from this method. Instead, call activityDidFinish: from your background thread after the actual work has been completed.
 */
- (void)performActivity {
	MFMailComposeViewController *composeController = [MFMailComposeViewController new];
//    MFMailComposeViewController *composeController = [((AXAppDelegate *)[UIApplication sharedApplication].delegate) getMailController];

	UIViewController *activityViewController = nil;

	if (self.activityItem.mailActivitySelected) {
		activityViewController = self.activityItem.mailActivitySelected(composeController);
	}

	composeController.mailComposeDelegate = self;
	self.mailController = composeController;
    
	[activityViewController presentViewController:self.mailController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

// - (UIViewController *)activityViewController {
//	MFMailComposeViewController *composeController = [MFMailComposeViewController new];
//
//	if (self.activityItem.mailActivitySelected) {
//		self.activityItem.mailActivitySelected(composeController);
//	}
//
//	self.mailController = composeController;
//	self.mailController.mailComposeDelegate = self;
////	[ self.mailController setValue:    ^{       [[UIApplication sharedApplication] setStatusBarSt   yle:UIStatusBarStyleLightContent]; } forKey:@"animation" ];
//
//	return self.mailController;
// }

 #pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self.mailController.presentingViewController dismissViewControllerAnimated:YES completion:^{
		 [self activityDidFinish:YES];
	 }];


//	if (result != MFMailComposeResultCancelled || result != MFMailComposeResultFailed) {
//		[self activityDidFinish:YES];
//	} else {
//		[self activityDidFinish:NO];
//	}
}

@end
