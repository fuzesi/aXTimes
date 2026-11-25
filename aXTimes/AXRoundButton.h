//
//  AXRoundButton.h
//  aXTimes
//
//  Created by fuesec on 11/6/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

@interface AXRoundButton : UIButton
@property (nonatomic, strong) UIColor *signalColor;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)color andBackgroudColor:(UIColor *)backgroundColor NS_DESIGNATED_INITIALIZER;
@end
