//
//  DDCalendarView.m
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import "DDCalendarSingleDayView.h"
#import "DDCalendarView.h"
#import "DDCalendarHourLinesView.h"
#import "DDCalendarEventProtocol.h"
#import "DDCalendarEventView.h"
#import "DDCalendarHeaderView.h"
#import "NSDate+DDCalendar.h"
#import "DDCalendarViewConstants.h"
#import "OBDragDrop.h"

#import "PureLayout.h"

@interface DDCalendarSingleDayView () <OBOvumSource, OBDropZone>
@property(nonatomic,weak) DDCalendarHourLinesView *bg;
@property(nonatomic,weak) UIView *container;
@property(nonatomic,strong) NSArray *eventViews;
@property(nonatomic,weak) DDCalendarEventView *activeEventView;
@property(nonatomic,strong) UIView *upperHandle;
@property(nonatomic, weak) UIView *timeMarkerLine;
@property(nonatomic,strong) NSLayoutConstraint *hourLinesViewHeightConstraint;
@end

@interface DDCalendarEventView (private)
@property(nonatomic, weak) DDCalendarSingleDayView *calendar;
@end

@implementation DDCalendarSingleDayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        //add our hours view that draws the background

        DDCalendarHourLinesView *hourLines = [DDCalendarHourLinesView new];
        hourLines.backgroundColor = [UIColor brownColor];
        [hourLines sizeToFit];
        [self addSubview:hourLines];
        self.bg = hourLines;
        [self.bg autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
        [self.bg autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
        [self.bg autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
        self.hourLinesViewHeightConstraint = [self.bg autoSetDimension:ALDimensionHeight toSize:hourLines.totalHeight];
        
        //add a container for the events
        UIView *container = [UIView new];
        container.backgroundColor = [UIColor orangeColor];
        container.opaque = NO;
        [self.bg addSubview:container];
        self.container = container;
        [self.container autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:HEIGHT_CELL_MIN/2];
        [self.container autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:TIME_LABEL_WIDTH + 5];
        NSLayoutConstraint *constraint = [self.container autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:5];
        [self.container autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:HEIGHT_CELL_MIN/2];
        //weird contraint warning made this necessary
        constraint.priority = 1;
        
        _showsTimeLabels = YES;
        [self setShowsDayHeader:NO];

        self.dropZoneHandler = self;
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    OBDragDropManager *manager = [OBDragDropManager sharedManager];
    [manager prepareOverlayWindowUsingMainWindow:self.window];
}

- (void)setEvents:(NSArray * _Nullable)events {
    _events = events;
    
    //rm all events
    for (UIView *view in self.eventViews) {
        [view removeFromSuperview];
    }
    
    self.eventViews = nil;
    
    id<DDCalendarViewDataSource> dataSource = self.calendar.dataSource;

    CGFloat maxX = 0;
    
    if (events.count) {
        //add event view for all events from left to right.
        NSMutableArray *newEventViews = [NSMutableArray array];
        
        for (id<DDCalendarEventProtocol> event in events) {
            
            CGRect frame = [self frameForEvent:event];
            frame = [self adjustAvoidOverlapForFrame:frame forPastEvents:newEventViews];
            
            DDCalendarEventView *eventView = nil;
            
            if([dataSource respondsToSelector:@selector(calendarView:viewForEvent:)]) {
                eventView = [dataSource calendarView:self.calendar
                                        viewForEvent:event];
            }
            
            if(!eventView) {
                eventView = [[DDCalendarEventView alloc] initWithEvent:event];
            }
            
            //fuesec
            frame.origin.x = 0;
            eventView.frame = frame;
            eventView.calendar = self;
            eventView.backgroundColor = [UIColor blueColor];
            
            [self.container addSubview:eventView];
            [eventView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
            [eventView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
            [eventView autoSetDimension:ALDimensionHeight toSize:frame.size.height];
            [eventView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:frame.origin.y];

            [newEventViews addObject:eventView];

            //get taps and pressed
            UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                         initWithTarget:self
                                                         action:@selector(handleTapOnEvent:)];
            [eventView addGestureRecognizer:tapGestureRecognizer];
            
            // Drag drop with long press gesture
//            OBDragDropManager *dragDropManager = [OBDragDropManager sharedManager];
//            UIGestureRecognizer *recognizer = [dragDropManager createLongPressDragDropGestureRecognizerWithSource:self];
//            [ev addGestureRecognizer:recognizer];
//            
            UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                                   initWithTarget:self
                                                                   action:@selector(handleLongPress:)];
            [eventView addGestureRecognizer:longGestureRecognizer];

            
            //get the rightmost coordinate
            maxX = MAX(maxX, CGRectGetMaxX(frame));
        }
        self.eventViews = newEventViews;
    }

    //check if gotta scale to fit on screen
    if(maxX > self.container.frame.size.width) {
        CGFloat factor = self.container.frame.size.width/maxX;
        [self compressAllEventViewsByFactor:factor];
    }
}

- (void)setDate:(NSDate * _Nonnull)date {
    _date = date;
    [self setEvents:self.events];
}

- (void)setShowsDayHeader:(BOOL)showsDayHeader {
    _showsDayHeader = showsDayHeader;
    
    CGRect f = self.bg.frame;

    DDCalendarHeaderView *label = (DDCalendarHeaderView*)[self viewWithTag:HEADER_LABEL_TAG];
    if(_showsDayHeader) {
        CGRect r = self.bounds;
        r.size.height = HEADER_LABEL_HEIGHT;

        if(!label) {
            label = [[DDCalendarHeaderView alloc] initWithFrame:r calendar:self];
            label.tag = HEADER_LABEL_TAG;
            
            [self addSubview:label];
        }
        else {
            label.calendar = self;
            label.frame = r;
        }
        
        f.origin.y = HEADER_LABEL_HEIGHT;
    }
    else {
        [label removeFromSuperview];
        
        f.origin.y = 0;
    }

    self.bg.frame = f;
}

- (void)setShowsTomorrow:(BOOL)showsTomorrow {
//    _showsTomorrow = showsTomorrow;
//    [self.bg sizeToFit];
//    CGFloat height = self.bg.totalHeight;
//    if(!_showsTomorrow) {
//        height /= 2;
//    }
//    
//    self.hourLinesViewHeightConstraint.constant = height;
//    
//    [self needsUpdateConstraints];
//    [self updateConstraints];
    
    CGFloat height = self.bg.frame.size.height;
    if(!_showsTomorrow) {
        height /= 2;
    }
    
    CGRect f = self.frame;
    f.size = CGSizeMake(self.bounds.size.width, height);
    self.frame = f;
}

- (void)setShowsTimeLabels:(BOOL)showsTimeLabels {
    _showsTimeLabels = showsTimeLabels;
    
    CGRect f = CGRectInset(self.bg.frame, 5, 5);
    if(_showsTimeLabels) {
        f.origin.x += TIME_LABEL_WIDTH;
        f.size.width -= TIME_LABEL_WIDTH;
    }
    self.container.frame = f;
    self.bg.showTimeLabels = _showsTimeLabels;
}

- (void)setShowsTimeMarker:(BOOL)showsTimeMarker {
    _showsTimeMarker = showsTimeMarker;
    
    if(_showsTimeMarker) {
        if(!self.timeMarkerLine) {
            UIView *timeMarkerLine = [[UIView alloc] initWithFrame:CGRectZero];
            timeMarkerLine.backgroundColor = [UIColor redColor];
            [self insertSubview:timeMarkerLine aboveSubview:self.container];
            self.timeMarkerLine = timeMarkerLine;
        }
        
        NSDateComponents *now = [NSDate date].currentCalendarDateComponents;
        NSInteger days = [self.date daysFromDate:[NSDate date]];
        NSDate *date = [NSDate dateWithHour:now.hour min:now.minute inDays:days];
        CGPoint datePoint = [self pointForDate:date];
        datePoint.y += HEIGHT_CELL_MIN/2;
        datePoint.y += 2; //;)
        
        CGRect f = self.bounds;
        f.origin.y = datePoint.y;
        f.size.height = 2;
        self.timeMarkerLine.frame = f;
    }
    else {
        [self.timeMarkerLine removeFromSuperview];
    }
}

#pragma mark event frame helpers

- (CGRect)frameForEvent:(id<DDCalendarEventProtocol>)event {
    CGFloat yBegin = [self pointForDate:event.dateBegin].y;
    CGFloat yEnd = [self pointForDate:event.dateEnd].y;
    
    return CGRectMake(0, yBegin, self.container.frame.size.width, yEnd - yBegin);
}

- (CGRect)adjustAvoidOverlapForFrame:(CGRect)frame forPastEvents:(NSArray*)eventViews {
    BOOL satisified;
    
    do {
        satisified = YES;
        
        for (DDCalendarEventView *ev in eventViews) {
            if(CGRectIntersectsRect(frame, ev.frame)) {
                //if it intersects, move it and retry!
                frame.origin.x += self.container.frame.size.width+5;
                satisified = NO;
            }
        }
    } while (!satisified);
    
    return frame;
}

- (void)compressAllEventViewsByFactor:(CGFloat)factor {
    for (DDCalendarEventView *ev in self.eventViews) {
        CGRect f = ev.frame;
        f.origin.x *= factor;
        f.size.width *= factor;
        ev.frame = f;
    }
}

#pragma mark convert points <> dates

- (CGPoint)pointForDate:(NSDate*)date {
    NSDateComponents *compsNow = self.date.currentCalendarDateComponents;
    NSDateComponents *compsOfBegin = date.currentCalendarDateComponents;
    
    //hours
    NSInteger beginInHoursSinceMidnightToday = compsOfBegin.hour;
    
    //we only encompass prev and next day.. we dont care about 2 or more days
    if(compsOfBegin.day > compsNow.day) beginInHoursSinceMidnightToday += 24;
    else if(compsOfBegin.day < compsNow.day) beginInHoursSinceMidnightToday -= 24;
    
    //pixels
    CGFloat yBegin = beginInHoursSinceMidnightToday * HEIGHT_CELL_HOUR;
    yBegin += compsOfBegin.minute * PIXELS_PER_MIN;
    yBegin += HEIGHT_CELL_MIN/2;
    
    if(self.showsDayHeader)
        yBegin -= HEADER_LABEL_HEIGHT;
    
    yBegin -= 5;// ;)
    
    return CGPointMake(0, yBegin);
}

- (NSDate*)dateForPoint:(CGPoint)pt {
    CGFloat y = pt.y; //we only care about y
    y -= HEIGHT_CELL_MIN/2;
    
    if(self.showsDayHeader)
        y -= HEADER_LABEL_HEIGHT;

    //determine how many hours fit
    int beginInHoursSinceMidnightToday = floor(pt.y / HEIGHT_CELL_HOUR);
    y = y - (beginInHoursSinceMidnightToday * HEIGHT_CELL_HOUR);
    assert(y < HEIGHT_CELL_HOUR);
    int minutesSinceLastHour = floor(y / PIXELS_PER_MIN);
    
    NSInteger daysMod = [self.date daysFromDate:[NSDate date]];
    NSDate *date = [NSDate dateWithHour:beginInHoursSinceMidnightToday min:minutesSinceLastHour inDays:daysMod];
    
    return date;
}

#pragma mark tap recognizer

- (void)handleTapOnEvent:(UIGestureRecognizer*)gestureRecognizer {
    DDCalendarEventView *activeEventView = self.activeEventView;
    DDCalendarEventView *eventView = (DDCalendarEventView*)gestureRecognizer.view;
    
    if(activeEventView != eventView) {
        activeEventView.active = NO;
        eventView.active = YES;
        self.activeEventView = eventView;
    } else if(activeEventView == eventView) {
        activeEventView.active = NO;
        self.activeEventView = nil;
    }
    
    id<DDCalendarViewDelegate> delegate = self.calendar.delegate;
    
    //tell click to delegate
    if([delegate respondsToSelector:@selector(calendarView:didSelectEvent:)]) {
        [delegate calendarView:self.calendar didSelectEvent:eventView.event];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (!self.upperHandle) {
        DDCalendarEventView *eventView = (DDCalendarEventView*)gestureRecognizer.view;
        self.activeEventView = eventView;

        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        view.backgroundColor = [UIColor yellowColor];
        
        UIGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(handlePan:)];
        [view addGestureRecognizer:panGestureRecognizer];
        [eventView addSubview:view];
        [eventView removeGestureRecognizer:gestureRecognizer];
        self.upperHandle = view;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:self.activeEventView];
    NSLog(@"ASDF %@", NSStringFromCGPoint(translation));
    
    [gestureRecognizer setTranslation:CGPointZero inView:self.activeEventView];
    
    // if you want to drag something along the pan gesture use:
//    self.activeEventView.center = CGPointMake(self.activeEventView.center.x,
//                                              self.activeEventView.center.y - translation.y);
    
    self.activeEventView.frame = CGRectMake(self.activeEventView.frame.origin.x,
                                            self.activeEventView.frame.origin.y + translation.y,
                                            self.activeEventView.frame.size.width,
                                            self.activeEventView.frame.size.height - translation.y);
}

#pragma mark d&d

- (BOOL)shouldCreateOvumFromView:(UIView*)sourceView {
    BOOL editable = NO;
    id<DDCalendarViewDelegate> del = self.calendar.delegate;
    DDCalendarEventView *ev = (DDCalendarEventView*)sourceView;
    
    if([del respondsToSelector:@selector(calendarView:allowEditingEvent:)]) {
        editable = [del calendarView:self.calendar allowEditingEvent:ev.event];
    }
    
    if(editable) {
        //activate it
        self.activeEventView.active = NO;
        ev.active = YES;
        self.activeEventView = ev;
    }
    return editable;
}

-(OBOvum *) createOvumFromView:(UIView*)sourceView {
    assert([sourceView isKindOfClass:[DDCalendarEventView class]]);
    
    OBOvum *ovum = [[OBOvum alloc] init];
    ovum.dataObject = @{@"event": ((DDCalendarEventView*)sourceView).event, @"calendar": ((DDCalendarEventView*)sourceView).calendar};
    ovum.isCentered = YES;
    return ovum;
}

-(UIView *) createDragRepresentationOfSourceView:(UIView *)sourceView inWindow:(UIWindow*)overlay {
    assert([sourceView isKindOfClass:[DDCalendarEventView class]]);

    UIView *dragView = [(DDCalendarEventView*)sourceView draggableView];
    
    // Create a view that represents this source. It will be place on
    // the overlay window and hence the coordinates conversion to make
    // sure user doesn't see a jump in object location
    CGRect f = dragView.frame;
    f = [self.container convertRect:f toView:self.window];
    f = [self.window convertRect:f toView:overlay];
    dragView.frame = f;
    
    return dragView;
}

-(OBDropAction) ovumEntered:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location {
    return OBDropActionMove;
}

- (void)ovumExited:(OBOvum *)ovum inView:(UIView *)view atLocation:(CGPoint)location {
    //noop
}

-(void) ovumDropped:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location {
    assert(view == self);

    // Handle the drop action
    NSDictionary *dict = ovum.dataObject;
    id<DDCalendarEventProtocol> event = dict[@"event"];
    DDCalendarSingleDayView *oldCalendar = dict[@"calendar"];
    
    //to get the top of the event
    location.y -= CGRectGetHeight(ovum.dragView.frame)/2;
    
    //the new time
    NSTimeInterval duration = [event.dateEnd timeIntervalSinceDate:event.dateBegin];
    NSDate *newStartDate = [self dateForPoint:location];
    NSDate *newEndDate = [newStartDate dateByAddingTimeInterval:duration];
    event.dateBegin = newStartDate;
    event.dateEnd  = newEndDate;
    
    // if we moved between cals, we need to move the event between arrays
    // else we only need to trigger ONE redraw
    if(oldCalendar != self) {
        NSMutableArray *newOldEvents = [oldCalendar->_events mutableCopy];
        [newOldEvents removeObject:event];
        
        NSMutableArray *newNewEvents = [_events mutableCopy];
        [newNewEvents addObject:event];

        oldCalendar.events = newOldEvents;
        self.events = newNewEvents;
    }
    else {
        self.events = self.events;
    }
    
    //commit it
    id<DDCalendarViewDelegate> del = self.calendar.delegate;
    if([del respondsToSelector:@selector(calendarView:commitEditEvent:)]) {
        [del calendarView:self.calendar commitEditEvent:event];
    }
}

@end
