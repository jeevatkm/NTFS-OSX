//
//  Arbitration.m
//  NTFS-OSX
//
//  Created by Jeevanandam Madanagopal on 6/5/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import "Arbitration.h"
#import "Volume.h"

DASessionRef session;

NSString * const DADiskDescriptionVolumeKindKey = @"ntfs";

void InitArbitration(void) {
	static BOOL isInitialized = NO;

	if (isInitialized) {
		return;
	}

	isInitialized = YES;

	session = DASessionCreate(kCFAllocatorDefault);
	if (!session) {
		[NSException raise:NSGenericException format:@"Unable to create Disk Arbitration session."];
		return;
	}

	DASessionScheduleWithRunLoop(session, CFRunLoopGetMain(), kCFRunLoopCommonModes);

	CFMutableDictionaryRef match = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

	// Device matching criteria
	// 1. Of-course it shouldn't be internal device since
	CFDictionaryAddValue(match, kDADiskDescriptionDeviceInternalKey, kCFBooleanFalse);

	// Volume matching criteria
	// It should statisfy following
	CFDictionaryAddValue(match, kDADiskDescriptionVolumeKindKey, (__bridge CFStringRef)DADiskDescriptionVolumeKindKey);
	CFDictionaryAddValue(match, kDADiskDescriptionVolumeMountableKey, kCFBooleanTrue);
	CFDictionaryAddValue(match, kDADiskDescriptionVolumeNetworkKey, kCFBooleanFalse);

	//CFDictionaryAddValue(match, kDADiskDescriptionDeviceProtocolKey, CFSTR(kIOPropertyPhysicalInterconnectTypeUSB));

	// Registring callbacks
	DARegisterDiskAppearedCallback(session, match, DiskAppearedCallback, (__bridge void *)[Volume class]);
	DARegisterDiskDisappearedCallback(session, match, DiskDisappearedCallback, (__bridge void *)[Volume class]);
	DARegisterDiskMountApprovalCallback(session, match, DiskMountApprovalCallback, (__bridge void *)[Volume class]);
	DARegisterDiskUnmountApprovalCallback(session, match, DiskUnmountApprovalCallback, (__bridge void *)[Volume class]);

	CFRelease(match);
}

BOOL Validate(DADiskRef diskRef) {

	return YES;
}

void DiskAppearedCallback(DADiskRef diskRef, void *context) {
	NSLog(@"-- DiskAppearedCallback ---");

	if (context != (__bridge void *)[Volume class]) {
		return;
	}

	NSString *BSDName = [[NSString alloc] initWithUTF8String:DADiskGetBSDName(diskRef)];
	CFDictionaryRef description = DADiskCopyDescription(diskRef);

	NSDictionary *dict = (__bridge NSDictionary *)description;
	NSLog(@"BSD Name:: %@ \n Description:: %@", BSDName, dict);

	CFRelease(description);
}

void DiskDisappearedCallback(DADiskRef diskRef, void *context) {
	NSLog(@"-- DiskDisappearedCallback ---");

	if (context != (__bridge void *)[Volume class]) {
		return;
	}

	NSString *BSDName = [[NSString alloc] initWithUTF8String:DADiskGetBSDName(diskRef)];
	CFDictionaryRef description = DADiskCopyDescription(diskRef);

	NSDictionary *dict = (__bridge NSDictionary *)description;
	NSLog(@"BSD Name:: %@ \n Description:: %@", BSDName, dict);

	CFRelease(description);
}

DADissenterRef DiskMountApprovalCallback(DADiskRef diskRef, void *context) {
	NSLog(@"-- DiskMountApprovalCallback ---");

	/*if (context != (__bridge void *)[Volume class]) {
	   return;
	   } */

	NSString *BSDName = [[NSString alloc] initWithUTF8String:DADiskGetBSDName(diskRef)];
	CFDictionaryRef description = DADiskCopyDescription(diskRef);

	NSDictionary *dict = (__bridge NSDictionary *)description;
	NSLog(@"BSD Name:: %@ \n Description:: %@", BSDName, dict);

	CFRelease(description);

	return NULL;
}

DADissenterRef DiskUnmountApprovalCallback(DADiskRef diskRef, void *context) {
	NSLog(@"-- DiskUnmountApprovalCallback ---");

	/*if (context != (__bridge void *)[Volume class]) {
	        return;
	   }*/

	NSString *BSDName = [[NSString alloc] initWithUTF8String:DADiskGetBSDName(diskRef)];
	CFDictionaryRef description = DADiskCopyDescription(diskRef);

	NSDictionary *dict = (__bridge NSDictionary *)description;
	NSLog(@"BSD Name:: %@ \n Description:: %@", BSDName, dict);

	CFRelease(description);

	//DADissenterRef ref = DADissenterCreate(kCFAllocatorDefault, kDAReturnNotPermitted, NULL);
	//return ref;

	return NULL;
}

