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


#pragma mark - Public Methods

+ (Disk *)getDiskForDARef:(DADiskRef)diskRef {
	for (Disk *disk in ntfsDisks) {
		if (disk.hash == CFHash(diskRef)) {
			return disk;
		}
	}

	return nil;
}

+ (Disk *)getDiskForDevicePath:(NSString *)devicePath {
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
	if (desc) {
		CFRetain(desc);
	}

	if (_diskRef) {
		CFRelease(_diskRef);
	}
}

- (void)disappeared {
	[ntfsDisks removeObject:self];
}

- (void)enableNTFSWrite {
	NSString *cmd = [NSString stringWithFormat:@"echo \"%@\" | tee -a /etc/fstab", [self ntfsConfig]];

	[STPrivilegedTask launchedPrivilegedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects: @"-c", cmd, nil]];
}

- (void)mount {
	NSString *cmd = [NSString stringWithFormat:@"diskutil mount /dev/%@", self.BSDName];
	[CommandLine run:cmd];
}

- (void)unmount {
	NSString *cmd = [NSString stringWithFormat:@"diskutil unmount /dev/%@", self.BSDName];
	[CommandLine run:cmd];
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
		CFRelease(desc);
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
	NSString *cmd = [NSString stringWithFormat:@"grep \"%@\" /etc/fstab", volumeUUID];
	NSString *output = [CommandLine run:cmd];

	NSLog(@"output: %@", output);

	return [[self ntfsConfig] isEqualToString:output];
}


#pragma mark - Private Methods

- (NSString *)ntfsConfig {
	return [NSString stringWithFormat:@"UUID=%@ none ntfs rw,auto,nobrowse", self.volumeUUID];
}

@end
