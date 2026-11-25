//
//  NSNumber+AXNSNumberCategory.m
//  aXTimes
//
//  Created by fuesec on 6/14/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "NSNumber+AXNSNumberCategory.h"
#import "NSNumberFormatter+AXNSNumberFormatterCategory.h"

@implementation NSNumber (AXNSNumberCategory)

- (NSString *)numberAsSecondsToCountdownString {
	double secondsWorked = [self doubleValue];
	double minutesWorked = secondsWorked / (double)60;
	NSArray *timeArray = [[NSString stringWithFormat:@"%.02lf", minutesWorked] componentsSeparatedByString:@"."];
	int minutes = [timeArray[0] intValue];

	double hoursWorked = (double)minutes / (double)60;

	timeArray =  [[NSString stringWithFormat:@"%.02lf", hoursWorked] componentsSeparatedByString:@"."];
	int hours = [timeArray[0] intValue];

	minutes = minutes - (hours * 60);

	secondsWorked = secondsWorked - (hours * 60 * 60) - (minutes * 60);
	timeArray =  [[NSString stringWithFormat:@"%.02lf", secondsWorked] componentsSeparatedByString:@"."];
	int seconds = [timeArray[0] intValue];

	return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

- (NSString *)numberToTimeString {
    NSDecimalNumber *oneHourDivisor = [NSDecimalNumber
                                       decimalNumberWithDecimal:[[NSNumber numberWithDouble:1.0] decimalValue]];
    NSDecimalNumber *minuteMultiplier = [NSDecimalNumber
                                         decimalNumberWithDecimal:[[NSNumber numberWithDouble:60.0] decimalValue]];
    
    NSDecimalNumber *hoursExactDividend = [NSDecimalNumber
                                           decimalNumberWithDecimal:[self decimalValue]];
    
    NSRoundingMode roundingMode = ([hoursExactDividend compare:[NSDecimalNumber zero]] == NSOrderedAscending) ? NSRoundUp : NSRoundDown;
    NSDecimalNumberHandler *handler = [NSDecimalNumberHandler
                                       decimalNumberHandlerWithRoundingMode:roundingMode
                                       scale:0
                                       raiseOnExactness:NO
                                       raiseOnOverflow:NO
                                       raiseOnUnderflow:NO
                                       raiseOnDivideByZero:NO];
    NSDecimalNumberHandler *secondHandler = [NSDecimalNumberHandler
                                             decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                             scale:0
                                             raiseOnExactness:NO
                                             raiseOnOverflow:NO
                                             raiseOnUnderflow:NO
                                             raiseOnDivideByZero:NO];
    
    NSDecimalNumber *quotient = [hoursExactDividend
                                 decimalNumberByDividingBy:oneHourDivisor
                                 withBehavior:handler];
    NSDecimalNumber *hours = [quotient decimalNumberByMultiplyingBy:oneHourDivisor];
    NSDecimalNumber *hourRemainder = [hoursExactDividend decimalNumberBySubtracting:hours];
    
    if ([hourRemainder compare:[NSDecimalNumber zero]] == NSOrderedAscending){
        // Number is negative. Multiply by -1
        NSDecimalNumber *negativeOne = [NSDecimalNumber decimalNumberWithMantissa:1
                                                                         exponent:0
                                                                       isNegative:YES];
        hourRemainder = [hourRemainder decimalNumberByMultiplyingBy:negativeOne];
    }
    
    NSDecimalNumber *minutesRounded = [hourRemainder
                                       decimalNumberByMultiplyingBy:minuteMultiplier
                                       withBehavior:secondHandler];
    
    return [NSString stringWithFormat:@"%@h %@m",
            [hours stringValue],
            [minutesRounded stringValue]];
}

- (NSString *)stringValueNumberFormatted {
    return [[NSNumberFormatter defaultNumberFormatter_Static:YES] stringFromNumber:self];
}

- (NSNumber *)add:(NSNumber *)number {
    return [[self decimalNumber] decimalNumberByAdding:[number decimalNumber]];
}

@end
