//
//  UIImage+AXUIImageCategory.m
//  aXTimes
//
//  Created by fuesec on 6/16/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#import "UIImage+AXUIImageCategory.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (AXUIImageCategory)

+ (UIImage *)imageWithSolidColor:(UIColor *)color withWidth:(CGFloat)with andHeight:(CGFloat)height {
	CGSize size = CGSizeMake(20, 20);

	UIGraphicsBeginImageContext(size);
	UIBezierPath *rPath = [UIBezierPath bezierPathWithRect:CGRectMake(0., 0., size.width, size.height)];
	[color setFill];
	[rPath fill];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

- (UIImage *)imageWithBurnTint:(UIColor *)color {
	UIImage *img = self;

	// lets tint the icon - assumes your icons are black
	UIGraphicsBeginImageContextWithOptions(img.size, NO, 0.0);
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextTranslateCTM(context, 0, img.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);

	CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);

	// draw alpha-mask
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGContextDrawImage(context, rect, img.CGImage);

	// draw tint color, preserving alpha values of original image
	CGContextSetBlendMode(context, kCGBlendModeSourceIn);
	[color setFill];
	CGContextFillRect(context, rect);

	UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return coloredImage;
}

- (UIImage *)imageScaledToSize:(CGSize)newSize {
	UIImage *image = self;

	UIGraphicsBeginImageContext(newSize);
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end
