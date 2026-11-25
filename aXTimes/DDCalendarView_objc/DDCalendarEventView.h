//
//  DDCalendarEventView.h
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDCalendarEventProtocol.h"

@class DDCalendarSingleDayView;
@class DDCalendarEvent;

@interface DDCalendarEventView : UIView

- (id)initWithEvent:(id<DDCalendarEventProtocol>)event;

@property(nonatomic, strong, readonly) id<DDCalendarEventProtocol> event;
@property(nonatomic, assign) BOOL active;

- (UIView *)draggableView;

@end
