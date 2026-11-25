//
//  UITableView+Helper.m
//  GammaCameraApp
//
//  Created by Christopher Füseschi on 25/03/16.
//  Copyright © 2016 Ledian Xhani. All rights reserved.
//

#import "UITableView+Helper.h"

@implementation UITableView (Helper)

- (BOOL)toggleCheckmark:(NSIndexPath *)indexPath {
    BOOL resultedInChange = NO;
    
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    if (cell.accessoryType != UITableViewCellAccessoryCheckmark) {
        resultedInChange = YES;
    }
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    for (int section = 0; section < [self numberOfSections]; section++) {
        for (int row = 0; row < [self numberOfRowsInSection:section]; row++) {
            if (!(row == indexPath.row &&
                section == indexPath.section)) {
                UITableViewCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
    }
    
    return resultedInChange;
}

@end
