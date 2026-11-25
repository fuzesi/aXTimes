//
//  SKSTableViewCell.m
//  SKSTableView
//
//  Created by Sakkaras on 26/12/13.
//  Copyright (c) 2013 Sakkaras. All rights reserved.
//

#import "SKSTableViewCellMulti.h"
#import "SKSTableViewCellIndicator.h"

#define kIndicatorViewTag -1

@interface SKSTableViewCellMulti ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *expandButtonWidthContraint;
@property (retain, nonatomic) UIColor *primaryClr;
@property (retain, nonatomic) UIColor *secondaryClr;
@end

@implementation SKSTableViewCellMulti

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.expandable = YES;
        self.expanded = NO;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([self.contentView respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.contentView.preservesSuperviewLayoutMargins = YES;
    }
    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.preservesSuperviewLayoutMargins = YES;
    }
    [self setupTextUI];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        self.customTextLabel.adjustsFontForContentSizeCategory = YES;
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
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isExpanded)
    {
        if (![self containsIndicatorView])
        {
            [self addIndicatorView];
        }
        else
        {
            [self removeIndicatorView];
            [self addIndicatorView];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *color = self.colorView.backgroundColor;
    [super setSelected:selected animated:animated];
    if (selected) {
        self.colorView.backgroundColor = color;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *color = self.colorView.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.colorView.backgroundColor = color;
    }
}

static UIImage *_image = nil;
- (UIImage *)expandableView
{
    if (!_image)
    {
        _image = [UIImage imageNamed:@"expandableImage.png"];
    }
    
    return _image;
}

- (void)setExpandable:(BOOL)isExpandable
{
    if (isExpandable)
    {
        [self.expandButton setImage:[self expandableView] forState:UIControlStateNormal];
    } else {
        [self.expandButton setImage:nil forState:UIControlStateNormal];
    }
    
    _expandable = isExpandable;
}

- (void)addIndicatorView
{
    if ([self containsIndicatorView]) return;

    CGPoint point = self.expandButton.center;
    
    CGRect frame = CGRectMake((point.x * 0.4), point.y * 1.4, 8 * 3.0, CGRectGetHeight(self.bounds) - point.y * 1.4);
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
        if (self.isExpanded)
        {
            self.expandButton.imageView.transform = CGAffineTransformMakeRotation(M_PI);
            [self addIndicatorView];
        }
        else
        {
            self.expandButton.imageView.transform = CGAffineTransformMakeRotation(0);
        }
    } completion:^(BOOL finished) {
        if (!self.isExpanded)
        {
            [self removeIndicatorView];
        }
    }];
}

- (UIButton *)getExpandButton
{
    return self.expandButton;
}

- (void)hideExpandButton {
    self.expandButtonWidthContraint.constant = 0;
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
