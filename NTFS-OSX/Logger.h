//
//  Logger.h
//  NTFS-OSX
//
//  Created by Jeevanandam M. on 6/15/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#define LogInfo(s, ...) NSLog(@"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__])
#define LogDebug(s, ...) [Logger logFor:__FILE__ line:__LINE__ format:(s), ##__VA_ARGS__]

@interface Logger : NSObject

+ (void)setDebugLog:(BOOL)debugOn;
+ (void)logFor:(char *)srcFile line:(int)line format:(NSString *)format, ...;

@end
