//
//  NSNumber+AXNSNumberCategory.h
//  aXTimes
//
//  Created by fuesec on 6/14/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//


@interface NSNumber (AXNSNumberCategory)

- (NSString *)numberAsSecondsToCountdownString;
- (NSString *)numberToTimeString;
- (NSString *)stringValueNumberFormatted;
- (NSString *)timeFormatted;

- (NSString *)stringValueNumberFormatted;
- (NSNumber *)add:(NSNumber *)number;

@end
