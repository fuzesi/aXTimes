//
//  NSDateFormatter+AXDateFormatters.h
//  aXTimes
//
//  Created by Christopher Füseschi on 01/06/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (AXDateFormatters)

+ (NSDateFormatter *)formatter_HH_mm_Static:(BOOL)shouldBeStatic;
+ (NSDateFormatter *)formatter_HH_mm_d_M_Static:(BOOL)shouldBeStatic;
+ (NSDateFormatter *)formatter_HH_mm_d_M_yy_Static:(BOOL)shouldBeStatic;

+ (NSDateFormatter *)formatter_Month_Year_Static:(BOOL)shouldBeStatic;
+ (NSDateFormatter *)formatter_Day_Month_Year_Static:(BOOL)shouldBeStatic;
+ (NSDateFormatter *)formatter_d_MMM_yyyy_Static:(BOOL)shouldBeStatic;

+ (NSDateFormatter *)formatter_fulltimeStamp:(BOOL)shouldBeStatic;

@end
