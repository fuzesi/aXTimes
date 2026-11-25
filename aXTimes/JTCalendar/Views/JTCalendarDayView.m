//
//  JTCalendarDayView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarDayView.h"

#import "JTCalendarManager.h"

static int maximumColors = 4;


@interface JTCalendarDayView ()

@property (nonatomic, strong) NSMutableArray<UIView *> *dotViews;
@property (nonatomic, strong) UIView *dotViewContainerView;

@end

@implementation JTCalendarDayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    self.clipsToBounds = YES;
    
    _circleRatio = .9;
    _dotRatio = 1. / 9.;
    
    self.dotViews = [NSMutableArray new];
    
    {
        _squareView = [UIView new];
        [self addSubview:_squareView];
        
        _squareView.backgroundColor = [UIColor colorWithRed:0x33/256. green:0xB3/256. blue:0xEC/256. alpha:.5];
        _squareView.hidden = YES;
        
        _squareView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _squareView.layer.shouldRasterize = YES;
        [_squareView.layer setBorderWidth:2];
        [_squareView.layer setBorderColor:[[UIColor clearColor] CGColor]];
        _squareView.layer.cornerRadius = 2;
        
    }
    
    {
        _circleView = [UIView new];
        [self addSubview:_circleView];
        
        _circleView.backgroundColor = [UIColor colorWithRed:0x33/256. green:0xB3/256. blue:0xEC/256. alpha:.5];
        _circleView.hidden = YES;

        _circleView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _circleView.layer.shouldRasterize = YES;
    }
    
    {
        _dotViewContainerView = [UIView new];
        [self addSubview:_dotViewContainerView];
        
        _dotViewContainerView.backgroundColor = [UIColor clearColor];
        _dotViewContainerView.hidden = YES;
        
//        _dotViewContainer.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        _dotViewContainer.layer.shouldRasterize = YES;
    }
    
    {
        _textLabel = [UILabel new];
        [self addSubview:_textLabel];
        
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    
    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch)];
        
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:gesture];
    }
}

- (void)setDotViewColors:(NSArray<UIColor *> *)colors {
    NSMutableArray<UIColor *> *finalColors = [NSMutableArray new];
    
    if (colors.count > maximumColors) {
        for (int i = 0; i < maximumColors; i++) {
            [finalColors addObject:colors[i]];
        }
    } else {
        for (UIColor *color in colors) {
            [finalColors addObject:color];
        }
    }
    
    if (finalColors.count > 0) {
        _dotViewContainerView.hidden = NO;
    } else {
        _dotViewContainerView.hidden = YES;
    }
    
    if (self.dotViews.count == finalColors.count) {
        for (int i = 0; i < finalColors.count; i++) {
            self.dotViews[i].backgroundColor = finalColors[i];
        }
    } else {
        for (UIView *dotView in self.dotViews) {
            [dotView removeFromSuperview];
        }
        
        self.dotViews = [NSMutableArray new];
        
        for (UIColor *color in finalColors) {
            UIView *dotView = [UIView new];
            [self.dotViews addObject:dotView];
            [self.dotViewContainerView addSubview:dotView];
            dotView.backgroundColor = color;
            
            dotView.layer.rasterizationScale = [UIScreen mainScreen].scale;
            dotView.layer.shouldRasterize = YES;
        }
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    _textLabel.frame = bounds;
    _textLabel.center = CGPointMake(self.frame.size.width / 2., (self.frame.size.height / 2.) - 5);
    
    CGFloat sizeCircle = MIN(self.frame.size.width, self.frame.size.height);
    CGFloat sizeDot = sizeCircle;
    
    CGFloat sizeSquare = sizeCircle * .9;
    sizeSquare = roundf(sizeSquare);

    sizeCircle = sizeCircle * _circleRatio;
    sizeDot = sizeDot * _dotRatio;

    // TODO check if good
    sizeCircle = sizeCircle - 1;
    sizeCircle = roundf(sizeCircle);
    sizeDot = roundf(sizeDot);
    
    _circleView.frame = CGRectMake(0, 0, sizeCircle, sizeCircle);
    _circleView.center = CGPointMake(self.frame.size.width / 2., (self.frame.size.height / 2.) - 5);
    _circleView.layer.cornerRadius = sizeCircle / 2.;
    
    _squareView.frame = CGRectMake(0, 0, sizeSquare -10 , sizeSquare -10 );
    _squareView.center = CGPointMake(self.frame.size.width / 2., (self.frame.size.height / 2.) - 5);

    
    _dotViewContainerView.frame = CGRectMake(0,
                                             0, //self.frame.size.height - sizeDot * 1.2,
                                             sizeDot * 1.3 * self.dotViews.count,
                                             sizeDot * 1.3);
//    DebugLog(@"size of tab is %@",NSStringFromCGRect(_dotViewContainerView.frame));
    
    _dotViewContainerView.center = CGPointMake(self.frame.size.width / 2.,
                                               self.frame.size.height - sizeDot // *1.3  // self.frame.size.height / 2.
                                               );
    
    for (int i = 0; i < self.dotViews.count; i++) {
        UIView *dotView = self.dotViews[i];
        dotView.frame = CGRectMake(0, 0, sizeDot, sizeDot);
        //        dotView.center = CGPointMake(self.frame.size.width / 2., (self.frame.size.height / 2.) +sizeDot * 2.5);
        dotView.center = CGPointMake((sizeDot * 1.3 / 2.) + sizeDot * 1.3 * i,
                                     (self.dotViewContainerView.frame.size.height / 2.));
//        DebugLog(@"DOTVIEW %@",NSStringFromCGRect(dotView.frame));
        dotView.layer.cornerRadius = sizeDot / 2.;
    }
}

- (void)setDate:(NSDate *)date
{
    NSAssert(date != nil, @"date cannot be nil");
    NSAssert(_manager != nil, @"manager cannot be nil");
    
    self->_date = date;
    [self reload];
}

- (void)reload
{
    static NSDateFormatter *dateFormatter = nil;
    if(!dateFormatter){
        dateFormatter = [_manager.dateHelper createDateFormatter];
        [dateFormatter setDateFormat:@"dd"];
    }
    
    _textLabel.text = [dateFormatter stringFromDate:_date];
        
    [_manager.delegateManager prepareDayView:self];
}


- (void)didTouch
{
    [_manager.delegateManager didTouchDayView:self];
}

@end
