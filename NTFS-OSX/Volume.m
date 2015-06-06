//
//  Volume.m
//  NTFS-OSX
//
//  Created by Jeevanandam M. on 6/5/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import "Volume.h"

@implementation Volume

@synthesize BSDName;
@synthesize description;


- (void)mount {

}

- (void)mountWithOptions:(NSUInteger)options {

}

- (void)unmountWithOptions:(NSUInteger)options {

}

- (void)eject {

}


#pragma mark - Properties

- (BOOL)isMounted
{
	CFStringRef value = description ? CFDictionaryGetValue(description, kDADiskDescriptionVolumePathKey) : NULL;

	return value ? YES : NO;
}

- (BOOL)isNetworkVolume
{
	CFBooleanRef value = description ? CFDictionaryGetValue(description, kDADiskDescriptionVolumeNetworkKey) : NULL;

	return value ? CFBooleanGetValue(value) : NO;
}

- (BOOL)isNTFSWritable
{
	CFBooleanRef value = description ? CFDictionaryGetValue(description, kDADiskDescriptionMediaWritableKey) : NULL;

	return value ? CFBooleanGetValue(value) : NO;
}

@end
