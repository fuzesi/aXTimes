//
//  DDCalendarEventProtocol.h
//  aXTimes
//
//  Created by Christopher Füseschi on 11/07/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DDCalendarEventProtocol <NSObject>


- (NSString *)title;
- (NSDate *)dateBegin;
- (NSDate *)dateEnd;

@optional
- (void)setDateBegin:(NSDate *)dateBegin;
- (void)setDateEnd:(NSDate *)dateEnd;
- (void)setTitle:(NSString *)title;

@end
