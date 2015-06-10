/*
 * The MIT License (MIT)
 *
 * Application: NTFS OS X
 * Copyright (c) 2015 Jeevanandam M. (jeeva@myjeeva.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

//
//  Disk.m
//  NTFS-OSX
//
//  Created by Jeevanandam M. on 6/5/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//


#import "Disk.h"
#import "Arbitration.h"
#import "CommandLine.h"
#import "STPrivilegedTask.h"


@implementation Disk

@synthesize BSDName;
@synthesize desc;
@synthesize volumeUUID;
@synthesize volumeName;
@synthesize volumePath;
@synthesize favoriteItem;


#pragma mark - Public Methods

+ (Disk *)getDiskForDARef:(DADiskRef)diskRef {
	for (Disk *disk in ntfsDisks) {
		if (disk.hash == CFHash(diskRef)) {
			return disk;
		}
	}

	return nil;
}

+ (Disk *)getDiskForUserInfo:(NSDictionary *)userInfo {
	NSString *devicePath = [userInfo objectForKey:NSDevicePath];

	for (Disk *disk in ntfsDisks) {
		if ([disk.volumePath isEqualToString:devicePath]) {
			return disk;
		}
	}

	return nil;
}


# pragma mark - Instance Methods

- (id)initWithDADiskRef:(DADiskRef)diskRef {

	NSAssert(diskRef, @"Disk reference cannot be NULL");

	// using existing reference
	Disk *foundOne = [Disk getDiskForDARef:diskRef];
	if (foundOne) {
		return foundOne;
	}

	self = [self init];
	if (self) {
		_diskRef = CFRetain(diskRef);

		CFDictionaryRef diskDesc = DADiskCopyDescription(diskRef);
		desc = CFRetain(diskDesc);

		BSDName = [[NSString alloc] initWithUTF8String:DADiskGetBSDName(diskRef)];

		CFUUIDRef uuidRef = CFDictionaryGetValue(diskDesc, kDADiskDescriptionVolumeUUIDKey);
		volumeUUID = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));

		[ntfsDisks addObject:self];
	}

	return self;
}

- (void)dealloc {
	RELEASE(favoriteItem);
	RELEASE(desc);
	RELEASE(_diskRef);
}

- (void)disappeared {
	[ntfsDisks removeObject:self];
}

- (void)enableNTFSWrite {
	NSString *cmd = [NSString stringWithFormat:@"echo \"%@\" | tee -a %@", [self ntfsConfig], FstabFile];

	[STPrivilegedTask launchedPrivilegedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects: @"-c", cmd, nil]];
	NSLog(@"NTFS write mode enabled for disk '%@'", self.volumeName);
}

- (void)mount {
	[CommandLine run:[NSString stringWithFormat:@"diskutil mount /dev/%@", self.BSDName]];
}

- (void)unmount {
	[CommandLine run:[NSString stringWithFormat:@"diskutil unmount /dev/%@", self.BSDName]];
}


#pragma mark - Properties

- (NSUInteger)hash {
	return CFHash(_diskRef);
}

- (BOOL)isEqual:(id)object {
	return (CFHash(_diskRef) == [object hash]);
}

- (void)setDesc:(CFDictionaryRef)descUpdate {
	if (descUpdate && descUpdate != desc) {
		RELEASE(desc);
		desc = CFRetain(descUpdate);
	}
}

- (CFDictionaryRef)desc {
	return desc;
}

- (NSString *)volumeName {
	CFStringRef nameRef = CFDictionaryGetValue(desc, kDADiskDescriptionVolumeNameKey);
	return (__bridge NSString *)nameRef;
}

- (NSString *)volumePath {
	NSString *path = [NSString stringWithFormat:@"/Volumes/%@", self.volumeName];
	return path;
}

- (BOOL)isNTFSWritable {
	BOOL status = [[NSFileManager defaultManager] fileExistsAtPath:FstabFile];
	NSLog(@"File '%@' exists: %@", FstabFile, status ? @"YES" : @"NO");

	if (status) {
		NSString *cmd = [NSString stringWithFormat:@"grep \"%@\" %@", volumeUUID, FstabFile];
		NSString *output = [CommandLine run:cmd];
		NSLog(@"output: %@", output);

		if ([[self ntfsConfig] isEqualToString:output]) {
			return TRUE;
		}
	}

	return FALSE;
}



#pragma mark - Private Methods

- (NSString *)ntfsConfig {
	return [NSString stringWithFormat:@"UUID=%@ none ntfs rw,auto,nobrowse", self.volumeUUID];
}

@end
