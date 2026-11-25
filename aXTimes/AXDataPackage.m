//
//  AXDataPackage.m
//  aXTimes
//
//  Created by Christopher Füseschi on 20/02/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

#import "AXDataPackage.h"

NSString *pasteBoardType = @"com.aximilate.DataSharing.DataPackage";
static NSString *packageDataKey = @"packageDataKey";

static NSString *kAXSourceApplicationNameKey = @"kAXSourceApplicationNameKey";
static NSString *kAXSourceApplicationIdentifierKey = @"kAXSourceApplicationIdentifierKey";
static NSString *kAXSourceApplicationVersionKey = @"kAXSourceApplicationVersionKey";
static NSString *kAXSourceApplicationBuildKey = @"kAXSourceApplicationBuildKey";

static NSString *kAXPayloadKey = @"kAXPayloadKey";

@interface AXDataPackage ()

// Metadata
@property (copy, nonatomic, readwrite) NSString *sourceApplicationName;
@property (copy, nonatomic, readwrite) NSString *sourceApplicationIdentifier;
@property (copy, nonatomic, readwrite) NSString *sourceApplicationVersion;
@property (copy, nonatomic, readwrite) NSString *sourceApplicationBuild;

// Application Data
@property (strong, nonatomic, readwrite) NSData *payload;

@end

@implementation AXDataPackage

- (id)initWithSourceApplicationName:(NSString *)sourceApplicationName
        sourceApplicationIdentifier:(NSString *)sourceApplicationIdentifier
           sourceApplicationVersion:(NSString *)sourceApplicationVersion
             sourceApplicationBuild:(NSString *)sourceApplicationBuild
                            payload:(NSData *)payload {
    self = [super init];
    if (self)
    {
        [self setSourceApplicationName:sourceApplicationName];
        [self setSourceApplicationIdentifier:sourceApplicationIdentifier];
        [self setSourceApplicationVersion:sourceApplicationVersion];
        [self setSourceApplicationBuild:sourceApplicationBuild];
        [self setPayload:payload];
    }
    
    return self;
}

+ (NSData *)jsonDataForMigration {
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *currentApplicationName = [infoPlist valueForKey:@"CFBundleDisplayName"];
    NSString *currentApplicationIdentifier = [infoPlist valueForKey:@"CFBundleIdentifier"];
    NSString *currentApplicationVersion = [infoPlist valueForKey:@"CFBundleShortVersionString"];
    NSString *currentApplicationBuild = [infoPlist valueForKey:@"CFBundleVersion"];

    NSError *error;

    NSDictionary *settings = @{};
    NSDictionary *dayEntries = @{};
    NSDictionary *comments = @{};
    NSDictionary *workingWeekSettings = @{};
    
    NSArray *array = [[AXDataStore sharedInstance] getAllManagedObjectsForClass:[DayType class]];
    NSDictionary *dayTypes = @{};
    NSDictionary *entities = @{};

    NSDictionary *payload = @{@"purpose": @"migration",
                              @"settings": settings,
                              @"dayEntries": dayEntries,
                              @"comments": comments,
                              @"woekingWeekSettings": workingWeekSettings,
                              @"dayTypes": dayTypes,
                              @"entities": entities};
    
    NSDictionary *dict = @{kAXSourceApplicationNameKey: currentApplicationName,
                           kAXSourceApplicationIdentifierKey: currentApplicationIdentifier,
                           kAXSourceApplicationVersionKey: currentApplicationVersion,
                           kAXSourceApplicationBuildKey: currentApplicationBuild,
                           kAXPayloadKey: payload};
    
    if ([NSJSONSerialization isValidJSONObject:dict]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
        if (!error) {
            return data;
        }
    }
    
    return nil;
}

#pragma mark - NSCoding

//- (void)encodeWithCoder:(NSCoder *)encoder {
//    [encoder encodeObject:self.sourceApplicationName forKey:kENHSourceApplicationNameKey];
//    [encoder encodeObject:self.sourceApplicationIdentifier forKey:kENHSourceApplicationIdentifierKey];
//    [encoder encodeObject:self.sourceApplicationVersion forKey:kENHSourceApplicationVersionKey];
//    [encoder encodeObject:self.sourceApplicationBuild forKey:kENHSourceApplicationBuildKey];
//    [encoder encodeObject:self.payload forKey:kENHPayloadKey];
//}
//
//- (id)initWithCoder:(NSCoder *)decoder {
//    NSString *sourceApplicationName = [decoder decodeObjectForKey:kENHSourceApplicationNameKey];
//    NSString *sourceApplicationIdentifier = [decoder decodeObjectForKey:kENHSourceApplicationIdentifierKey];
//    NSString *sourceApplicationVersion = [decoder decodeObjectForKey:kENHSourceApplicationVersionKey];
//    NSString *sourceApplicationBuild = [decoder decodeObjectForKey:kENHSourceApplicationBuildKey];
//    NSData *payload = [decoder decodeObjectForKey:kENHPayloadKey];
//    
//    return [self initWithSourceApplicationName:sourceApplicationName
//                   sourceApplicationIdentifier:sourceApplicationIdentifier
//                      sourceApplicationVersion:sourceApplicationVersion
//                        sourceApplicationBuild:sourceApplicationBuild
//                                       payload:payload];
//}

#pragma mark - Data Helpers

//- (NSData *)dataRepresentation {
//    NSMutableData *data = [[NSMutableData alloc] init];
//    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//    [archiver encodeObject:self forKey:packageDataKey];
//    [archiver finishEncoding];
//    
//    return [NSData dataWithData:data];
//}

+ (AXDataPackage *)unarchivePackageData:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    AXDataPackage *package = [unarchiver decodeObjectForKey:packageDataKey];
    [unarchiver finishDecoding];
    
    return package;
}



@end
