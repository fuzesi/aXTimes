//
//  AXPasteboardSharingController.h
//  aXTimes
//
//  Created by Christopher Füseschi on 20/02/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXDataPackage.h"

typedef void(^AXSharingSendDataHandler)(NSURL *url, NSError *error);
//typedef void(^ENHAppDataSharingHandler)(ENHAppDataPackage *retrievedPackage, NSError *error);

extern NSString *kReadPasteboardDataQuery;

typedef NS_ENUM(NSInteger, ENHAppDataSharingErrorType)
{
    ENHAppDataSharingErrorTypeNoApplicationAvailableForScheme = 100,
    ENHAppDataSharingErrorTypeNoPasteboardForName = 200,
    ENHAppDataSharingErrorTypeNoDataFound = 300,
};


@interface AXPasteboardSharingController : NSObject

+ (void)sendDataToApplicationWithScheme:(NSString *)scheme
                                   data:(NSData *)data
                      completionHandler:(AXSharingSendDataHandler)completionHandler;

@end
