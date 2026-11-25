//
//  SKSIndexPath.h
//  aXTimes
//
//  Created by Christopher Füseschi on 31/07/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKSIndexPath : NSObject

@property (nonatomic) NSInteger section;
@property (nonatomic) NSInteger row;
@property (nonatomic) NSInteger subRow;
@property (nonatomic) NSInteger subSubRow;
@property (nonatomic, retain) NSIndexPath *indexPath;


@end
