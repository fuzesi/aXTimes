//
//  AXDatePickerTableViewCell.m
//  aXTimes
//
//  Created by fuesec on 28/06/15.
//  Copyright (c) 2015 aXimilate. All rights reserved.
//

#import "AXSummaryRegularTableViewCell.h"
#import "SKSTableViewCellIndicator.h"

#define kIndicatorViewTag -1

@interface AXSummaryRegularTableViewCell()

@property (retain, nonatomic) UIColor *primaryClr;
@property (retain, nonatomic) UIColor *secondaryClr;

@end

@implementation AXSummaryRegularTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.customImageView.image = nil;
    self.customTextLabel.textColor = GLOBALFONTCOLOR;
    self.customDetailTextLabel.textColor = GLOBALFONTCOLOR;
    if ([self.contentView respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.contentView.preservesSuperviewLayoutMargins = YES;
    }
    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.preservesSuperviewLayoutMargins = YES;
    }
    [self setupTextUI];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        self.customTextLabel.adjustsFontForContentSizeCategory = YES;
        self.customDetailTextLabel.adjustsFontForContentSizeCategory = YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self setupTextUI];
}

- (void)setupTextUI {
    self.customTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.customDetailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSInteger indentPoints = self.indentationLevel * self.indentationWidth;
    
    self.contentView.frame = CGRectMake(indentPoints,
                                        self.contentView.frame.origin.y,
                                        self.contentView.frame.size.width - indentPoints,
                                        self.contentView.frame.size.height
                                        );
    
    if (self.isExpanded) {
        
        if (![self containsIndicatorView])
            [self addIndicatorView];
        else {
            [self removeIndicatorView];
            [self addIndicatorView];
        }
    }
}

static UIImage *_image = nil;
- (UIView *)expandableView
{
    if (!_image) {
        _image = [UIImage imageNamed:@"expandableImage.png"];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, _image.size.width, _image.size.height);
    button.frame = frame;
    
    [button setBackgroundImage:_image forState:UIControlStateNormal];
    
    return button;
}

- (void)setExpandable:(BOOL)isExpandable
{
    if (!_image) {
        _image = [UIImage imageNamed:@"expandableImage.png"];
    }
    
    if (isExpandable) {
        [self setAccessoryView:[self expandableView]];
    } else {
        [self setAccessoryView:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _image.size.width, _image.size.height)]];
    }
    
    _expandable = isExpandable;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)addIndicatorView
{
    if ([self containsIndicatorView]) return;
    
    CGPoint point = self.accessoryView.center;
    CGRect bounds = self.accessoryView.bounds;
    
    CGRect frame = CGRectMake((point.x - CGRectGetWidth(bounds) * 1.5), point.y * 1.4, CGRectGetWidth(bounds) * 3.0, CGRectGetHeight(self.bounds) - point.y * 1.4);
    SKSTableViewCellIndicator *indicatorView = [[SKSTableViewCellIndicator alloc] initWithFrame:frame];
    indicatorView.indicatorColor = self.secondaryClr;
    indicatorView.tag = kIndicatorViewTag;
    [self.contentView addSubview:indicatorView];
}

- (void)removeIndicatorView
{
    id indicatorView = [self.contentView viewWithTag:kIndicatorViewTag];
    if (indicatorView)
    {
        [indicatorView removeFromSuperview];
        indicatorView = nil;
    }
}

- (BOOL)containsIndicatorView
{
    return [self.contentView viewWithTag:kIndicatorViewTag] ? YES : NO;
}

- (void)expandButtonAnimation;
{
    [UIView animateWithDuration:0.2 animations:^{
        if (self.isExpanded) {
            self.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
        }
        else
        {
            self.accessoryView.transform = CGAffineTransformMakeRotation(0);
        }
    } completion:^(BOOL finished) {
        if (!self.isExpanded) [self removeIndicatorView];
    }];
}

- (UIButton *)getExpandButton
{
    return (UIButton *)self.accessoryView;
}

- (void)setPrimaryColor:(UIColor *)color
{
    self.primaryClr = color;
}

- (void)setSecondaryColor:(UIColor *)color
{
    self.secondaryClr = color;
}
@end
