//
//  Volume.m
//  NTFS-OSX
//
//  Created by Jeevanandam M. on 6/5/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import "Disk.h"
#import "Arbitration.h"

@implementation Disk

@synthesize BSDName;
@synthesize volumeUUID;
@synthesize volumeName;
@synthesize volumeURL;
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

# pragma mark - Instance Methods

- (id)initWithDADiskRef:(DADiskRef)diskRef {

	NSAssert(diskRef, @"Disk reference cannot be NULL");

	// using existing reference
	Disk *foundOne = [Disk getDiskForDARef:diskRef];
	if (foundOne) {
		NSLog(@"Already registered: %@", foundOne.BSDName);
		return foundOne;
	}

	self = [self init];
	if (self) {
		_diskRef = CFRetain(diskRef);

		CFDictionaryRef desc = DADiskCopyDescription(diskRef);
		BSDName = [[NSString alloc] initWithUTF8String:DADiskGetBSDName(diskRef)];

		CFUUIDRef uuidRef = CFDictionaryGetValue(desc, kDADiskDescriptionVolumeUUIDKey);
		volumeUUID = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));

		CFStringRef nameRef = CFDictionaryGetValue(desc, kDADiskDescriptionVolumeNameKey);
		volumeName = CFBridgingRelease(nameRef);

		[ntfsDisks addObject:self];
	}

	return self;
}

- (void)dealloc {
	NSLog(@"Deallocting Disk: %@", BSDName);

	if (_diskRef) {
		CFRelease(_diskRef);
		_diskRef = NULL;
	}
}

- (void)logInfo {
	NSLog(@"BSD Name: %@ | Volume UUID: %@ | Volume Name: %@ | Volume URL: %@", BSDName, volumeUUID, volumeName, volumeURL);
}

- (void)disappeared {
	[ntfsDisks removeObject:self];
}


#pragma mark - Properties

- (NSUInteger)hash {
	return CFHash(_diskRef);
}

- (BOOL)isEqual:(id)object {
	return (CFHash(_diskRef) == [object hash]);
}

@end
