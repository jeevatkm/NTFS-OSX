//
//  Arbitration.m
//  NTFS-OSX
//
//  Created by Jeevanandam Madanagopal on 6/5/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import "Arbitration.h"
#import "Disk.h"

DASessionRef session;
DASessionRef approvalSession;
NSMutableSet *ntfsDisks;

NSString * const DADiskDescriptionVolumeKindValue = @"ntfs";
NSString * const NTFSDiskAppearedNotification = @"NTFSDiskAppearedNotification";
NSString * const NTFSDiskDisappearedNotification = @"NTFSDiskDisappearedNotification";
NSString * const AppName = @"NTFSApp";

void RegisterDA(void) {

	// Disk Arbitration Session
	session = DASessionCreate(kCFAllocatorDefault);
	if (!session) {
		[NSException raise:NSGenericException format:@"Unable to create Disk Arbitration session."];
		return;
	}

	NSLog(@"Disk Arbitration Session created");

	ntfsDisks = [NSMutableSet new];

	// Matching Conditions
	CFMutableDictionaryRef match = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

	// Device matching criteria
	// 1. Of-course it shouldn't be internal device since
	CFDictionaryAddValue(match, kDADiskDescriptionDeviceInternalKey, kCFBooleanFalse);

	// Volume matching criteria
	// It should statisfy following
	CFDictionaryAddValue(match, kDADiskDescriptionVolumeKindKey, (__bridge CFStringRef)DADiskDescriptionVolumeKindValue);
	CFDictionaryAddValue(match, kDADiskDescriptionVolumeMountableKey, kCFBooleanTrue);
	CFDictionaryAddValue(match, kDADiskDescriptionVolumeNetworkKey, kCFBooleanFalse);

	//CFDictionaryAddValue(match, kDADiskDescriptionDeviceProtocolKey, CFSTR(kIOPropertyPhysicalInterconnectTypeUSB));

	DASessionScheduleWithRunLoop(session, CFRunLoopGetMain(), kCFRunLoopCommonModes);

	// Registring callbacks
	DARegisterDiskAppearedCallback(session, match, DiskAppearedCallback, (__bridge void *)AppName);
	DARegisterDiskDisappearedCallback(session, match, DiskDisappearedCallback, (__bridge void *)AppName);
	DARegisterDiskDescriptionChangedCallback(session, match, NULL, DiskDescriptionChangedCallback, (__bridge void *)AppName);

	// Disk Arbitration Approval Session
	approvalSession = DAApprovalSessionCreate(kCFAllocatorDefault);
	if (!approvalSession) {
		NSLog(@"Unable to create Disk Arbitration approval session.");
		return;
	}

	NSLog(@"Disk Arbitration Approval Session created");
	DAApprovalSessionScheduleWithRunLoop(approvalSession, CFRunLoopGetMain(), kCFRunLoopCommonModes);

	// Same match condition for Approval session too
	DARegisterDiskMountApprovalCallback(approvalSession, match, DiskMountApprovalCallback, (__bridge void *)AppName);

	CFRelease(match);
}

void UnregisterDA(void) {
	// DA Session
	if (session) {
		DAUnregisterCallback(session, DiskAppearedCallback, (__bridge void *)AppName);
		DAUnregisterCallback(session, DiskDisappearedCallback, (__bridge void *)AppName);

		DASessionUnscheduleFromRunLoop(session, CFRunLoopGetMain(), kCFRunLoopCommonModes);
		CFRelease(session);

		NSLog(@"Disk Arbitration Session destoryed");
	}

	// DA Approval Session
	if (approvalSession) {
		DAUnregisterApprovalCallback(approvalSession, DiskMountApprovalCallback, (__bridge void *)AppName);

		DAApprovalSessionUnscheduleFromRunLoop(approvalSession, CFRunLoopGetMain(), kCFRunLoopCommonModes);
		CFRelease(approvalSession);

		NSLog(@"Disk Arbitration Approval Session destoryed");
	}

	[ntfsDisks removeAllObjects];
	ntfsDisks = nil;
}

BOOL Validate(DADiskRef diskRef) {

	return TRUE;
}

void DiskAppearedCallback(DADiskRef diskRef, void *context) {
	NSLog(@"DiskAppearedCallback called: %s", DADiskGetBSDName(diskRef));

	//Disk *disk = [[Disk alloc] initWithDADiskRef:diskRef];
	//NSLog(@"Name: %@ \tUUID: %@", disk.volumeName, disk.volumeUUID);

	//[[NSNotificationCenter defaultCenter] postNotificationName:NTFSDiskAppearedNotification object:disk];
}

void DiskDisappearedCallback(DADiskRef diskRef, void *context) {
	NSLog(@"DiskDisappearedCallback called: %s", DADiskGetBSDName(diskRef));

	Disk *disk = [Disk getDiskForDARef:diskRef];
	NSLog(@"Name: %@ \tUUID: %@", disk.volumeName, disk.volumeUUID);

	[[NSNotificationCenter defaultCenter] postNotificationName:NTFSDiskDisappearedNotification object:disk];
}

void DiskDescriptionChangedCallback(DADiskRef diskRef, CFArrayRef keys, void *context) {
	NSLog(@"DiskDescriptionChangedCallback called: %s", DADiskGetBSDName(diskRef));

	Disk *disk = [Disk getDiskForDARef:diskRef];

	if (disk) {
		CFDictionaryRef newDesc = DADiskCopyDescription(diskRef);
		disk.desc = newDesc;
		CFRelease(newDesc);
	}
}

DADissenterRef DiskMountApprovalCallback(DADiskRef diskRef, void *context) {
	NSLog(@"DiskMountApprovalCallback called: %s", DADiskGetBSDName(diskRef));

	if (context == (__bridge void *)AppName) {
		/*DADissenterRef dissenter = DADissenterCreate(kCFAllocatorDefault,
		                                             kDAReturnNotPermitted,
		                                             CFSTR("NTFS OS X application is in-charge."));
		   return dissenter; */// For all NTFS disk


	}

	Disk *disk = [[Disk alloc] initWithDADiskRef:diskRef];
	NSLog(@"Name: %@ \tUUID: %@", disk.volumeName, disk.volumeUUID);

	[[NSNotificationCenter defaultCenter] postNotificationName:NTFSDiskAppearedNotification object:disk];

	return NULL; // for all disks
}
