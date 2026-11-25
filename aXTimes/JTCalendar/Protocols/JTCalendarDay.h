//
//  JTCalendarDay.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <Foundation/Foundation.h>

@class JTCalendarManager;

@protocol JTCalendarDay <NSObject>

- (void)setManager:(JTCalendarManager * _Nonnull)manager;

- (NSDate * _Nullable)date;
- (void)setDate:(NSDate * _Nonnull)date;

- (BOOL)isFromAnotherMonth;
- (void)setIsFromAnotherMonth:(BOOL)isFromAnotherMonth;

@end
