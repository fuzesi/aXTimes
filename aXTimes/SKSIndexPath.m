//
//  SKSIndexPath.m
//  aXTimes
//
//  Created by Christopher Füseschi on 31/07/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import "SKSIndexPath.h"

@interface SKSIndexPath()

@end

@implementation SKSIndexPath

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy)
    {
        // Copy NSObject subclasses
        [copy setRow:self.row];
        [copy setSection:self.section];
        [copy setSubRow:self.subRow];
        [copy setSubSubRow:self.subSubRow];
        [copy setIndexPath:[self.indexPath copyWithZone:zone]];
    }
    
    return copy;
}

- (NSString *)description
{
    NSLog(@"SKSIndexPath %ld %ld %ld %ld", (long)self.section, (long)self.row, (long)self.subRow, (long)self.subSubRow);
    return [NSString stringWithFormat:@"SKSIndexPath %ld %ld %ld %ld", (long)self.section, (long)self.row, (long)self.subRow, (long)self.subSubRow];
}
@end
