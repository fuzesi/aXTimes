//
//  AXCommetTableViewCell.m
//  aXTimes
//
//  Created by fuesec on 2/25/14.
//  Copyright (c) 2014 aXimilate. All rights reserved.
//

#import "AXCommentTableViewCell.h"

@interface AXCommentTableViewCell ()

@end

@implementation AXCommentTableViewCell
@synthesize customTextLabel;
@synthesize commentLabel;

- (void)awakeFromNib {
    [super awakeFromNib];

    if ([self.contentView respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.contentView.preservesSuperviewLayoutMargins = YES;
    }
    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.preservesSuperviewLayoutMargins = YES;
    }
}

@end
