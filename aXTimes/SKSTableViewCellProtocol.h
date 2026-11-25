//
//  SKSTableViewCellProtocol.h
//  aXTimes
//
//  Created by Christopher Füseschi on 08/07/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SKSTableViewCellProtocol <NSObject>
- (BOOL)isExpandable;
- (BOOL)isExpanded;
- (void)setExpanded:(BOOL)expanded;
- (UIButton *)getExpandButton;

- (void)setPrimaryColor:(UIColor *)color;
- (void)setSecondaryColor:(UIColor *)color;


/**
 * Adds an indicator view into the receiver when the relevant cell is expanded.
 */
- (void)addIndicatorView;

/**
 * Removes the indicator view from the receiver when the relevant cell is collapsed.
 */
- (void)removeIndicatorView;

/**
 * Returns a boolean value showing if the receiver contains an indicator view or not.
 *
 *  @return The boolean value for the indicator view.
 */
- (BOOL)containsIndicatorView;

- (void)expandButtonAnimation;

@end
