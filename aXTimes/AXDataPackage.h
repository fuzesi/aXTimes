//
//  AXDataPackage.h
//  aXTimes
//
//  Created by Christopher Füseschi on 20/02/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *pasteBoardType;

@interface AXDataPackage : NSObject //<NSCoding>

// Metadata
@property (copy, nonatomic, readonly) NSString *sourceApplicationName;
@property (copy, nonatomic, readonly) NSString *sourceApplicationIdentifier;
@property (copy, nonatomic, readonly) NSString *sourceApplicationVersion;
@property (copy, nonatomic, readonly) NSString *sourceApplicationBuild;

// Application Data
@property (strong, nonatomic, readonly) NSData *payload;


- (id)initWithSourceApplicationName:(NSString *)sourceApplicationName
        sourceApplicationIdentifier:(NSString *)sourceApplicationIdentifier
           sourceApplicationVersion:(NSString *)sourceApplicationVersion
             sourceApplicationBuild:(NSString *)sourceApplicationBuild
                            payload:(NSData *)payload;
+ (NSData *)jsonDataForMigration;
//- (NSData *)dataRepresentation;
+ (AXDataPackage *)unarchivePackageData:(NSData *)data;

@end
