//
//  UIImage+AXUIImageCategory.h
//  aXTimes
//
//  Created by fuesec on 6/16/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//


@interface UIImage (AXUIImageCategory)

+ (UIImage *)imageWithSolidColor:(UIColor *)color withWidth:(CGFloat)with andHeight:(CGFloat)height;
- (UIImage *)imageWithBurnTint:(UIColor *)color;
- (UIImage *)imageScaledToSize:(CGSize)newSize;
@end
