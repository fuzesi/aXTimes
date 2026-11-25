	//
//  AXPasteboardSharingController.m
//  aXTimes
//
//  Created by Christopher Füseschi on 20/02/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

#import "AXPasteboardSharingController.h"

NSString *kReadPasteboardDataQuery = @"readPasteboardData";
NSString *const AppDataSharingErrorDomain = @"AppDataSharingErrorDomain";

@implementation AXPasteboardSharingController

+ (void)sendDataToApplicationWithScheme:(NSString *)scheme
                                   data:(NSData *)data
                      completionHandler:(AXSharingSendDataHandler)completionHandler {
    if (!data) {
        NSLog(@"No data to send");
        NSURL *sendingURL = [[self class] sendPasteboardDataURLForScheme:scheme pasteboardName:@""];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", scheme]]]) {
            completionHandler(sendingURL, nil);
        } else {
            completionHandler(nil, nil);
        }
        return;
    }
    
    NSError *error = nil;
    
    // Setup the Pasteboard
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithUniqueName];
    [pasteboard setPersistent:YES]; // Makes sure the pasteboard lives beyond app termination.
    NSString *pasteboardName = [pasteboard name];
    
    // Write The Data
//    NSData *data = [dataPackage dataRepresentation];
    NSString *pasteboardType = pasteBoardType;
    [pasteboard setData:data forPasteboardType:pasteboardType];

    NSURL *sendingURL = [[self class] sendPasteboardDataURLForScheme:scheme pasteboardName:pasteboardName];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", scheme]]]) {
        completionHandler(sendingURL, nil);
    } else {
        [pasteboard setItems:@[]];
        [pasteboard setPersistent:NO];
        
        NSDictionary *errorInfoDictionary = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"No application was found to handle the url:", nil), sendingURL]};
        error = [NSError errorWithDomain:AppDataSharingErrorDomain
                                    code:ENHAppDataSharingErrorTypeNoApplicationAvailableForScheme
                                userInfo:errorInfoDictionary];
        completionHandler(nil, error);
    }
}

#pragma mark - URLs

+ (NSURL *)sendPasteboardDataURLForScheme:(NSString *)scheme pasteboardName:(NSString *)pasteboardName {
    NSString *urlString = [NSString stringWithFormat:@"%@://?%@#%@", scheme, kReadPasteboardDataQuery, pasteboardName];
    
    return [NSURL URLWithString:urlString];
}

@end
