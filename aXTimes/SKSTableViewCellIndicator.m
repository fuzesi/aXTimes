//
//  SKSTableViewCellExpandedIndicatorView.m
//  SKSTableView
//
//  Created by Sakkaras on 04/01/14.
//  Copyright (c) 2014 Sakkaras. All rights reserved.
//

#import "SKSTableViewCellIndicator.h"

@interface SKSTableViewCellIndicator()
@end

@implementation SKSTableViewCellIndicator

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context,
                         CGRectGetMinX(rect),
                         CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context,
                            CGRectGetMidX(rect),
                            CGRectGetMinY(rect));
    CGContextAddLineToPoint(context,
                            CGRectGetMaxX(rect),
                            CGRectGetMaxY(rect));
    CGContextClosePath(context);
    
    CGContextSetFillColorWithColor(context,
                                   [self.indicatorColor CGColor]);
    CGContextFillPath(context);
}


@end
