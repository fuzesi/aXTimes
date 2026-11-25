//
//  AXRoundButton.m
//  aXTimes
//
//  Created by fuesec on 11/6/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "AXRoundButton.h"
#import "UIImage+AXUIImageCategory.h"


@interface AXRoundButton ()

@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImage *notSelectedImage;

@end

@implementation AXRoundButton

- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)color andBackgroudColor:(UIColor *)backgroundColor {
	self = [super initWithFrame:frame];
	if (self) {
		[self setupWithColor:(UIColor *)color andBackgroudColor:(UIColor *)backgroundColor];
	}
	return self;
}

- (void)setupWithColor:(UIColor *)color andBackgroudColor:(UIColor *)backgroundColor {
	self.clipsToBounds = YES;
	self.layer.cornerRadius = self.frame.size.width / 2;
	self.layer.borderWidth = 1.0f;
	self.layer.borderColor = color.CGColor;
	self.backgroundColor = backgroundColor;
	self.signalColor = color;
	self.adjustsImageWhenHighlighted = NO;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	self.layer.cornerRadius = self.frame.size.width / 2;
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];

	if (highlighted) {
		self.layer.borderColor = NOTHIGHLIGHTED.CGColor;
	} else {
		self.layer.borderColor = self.signalColor.CGColor;
	}
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
	[super setImage:[image imageWithBurnTint:self.signalColor] forState:UIControlStateNormal];
	[super setImage:[image imageWithBurnTint:NOTHIGHLIGHTED] forState:UIControlStateHighlighted];
	[super setImage:[image imageWithBurnTint:NOTHIGHLIGHTED] forState:UIControlStateDisabled];
}

- (void)setEnabled:(BOOL)enabled {
	[super setEnabled:enabled];
	if (enabled) {
		self.layer.borderColor = self.signalColor.CGColor;
	} else {
		self.layer.borderColor = NOTHIGHLIGHTED.CGColor;
	}
}

- (void)setSignalColor:(UIColor *)color {
	_signalColor = color;
	self.layer.borderColor = color.CGColor;
}


@end
