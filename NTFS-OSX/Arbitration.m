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

void InitArbitration(void) {
    static BOOL isInitialized = NO;
    
    if (isInitialized) {
        return;
    }
    
    isInitialized = YES;
    
    session = DASessionCreate(kCFAllocatorDefault);
    if (!session) {
        [NSException raise:NSInternalInconsistencyException format:@"Unable to create Disk Arbitration session."];
        return;
    }
    
    DASessionScheduleWithRunLoop(session, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    CFMutableDictionaryRef matchDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(matchDict, kDADiskDescriptionVolumeNetworkKey, kCFBooleanFalse);
    CFDictionaryAddValue(matchDict, kDADiskDescriptionVolumeMountableKey, kCFBooleanTrue);
    //CFDictionaryAddValue(match, kDADiskDescriptionMediaWholeKey, kCFBooleanFalse);
    //CFDictionaryAddValue(match, kDADiskDescriptionDeviceProtocolKey, CFSTR(kIOPropertyPhysicalInterconnectTypeUSB));
    
    DARegisterDiskAppearedCallback(session, matchDict, DiskAppearedCallback, (__bridge void *)([Disk class]));
    DARegisterDiskDisappearedCallback(session, matchDict, DiskDisappearedCallback, (__bridge void *)[Disk class]);
    DARegisterDiskDescriptionChangedCallback(session, matchDict, NULL, DiskDescriptionChangedCallback, (__bridge void *)[Disk class]);
    
    CFRelease(matchDict);
}

BOOL Validate(DADiskRef diskRef) {
    
    return YES;
}

void DiskAppearedCallback(DADiskRef diskRef, void *context) {
    if (context != (__bridge void *)[Disk class]) {
        return;
    }
    
    NSString *BSDName = [[NSString alloc] initWithUTF8String:DADiskGetBSDName(diskRef)];
    CFDictionaryRef description = DADiskCopyDescription(diskRef);
    
    NSDictionary *dict = (__bridge NSDictionary *)description;
    NSLog(@"BSD Name:: %@ \n Description:: %@", BSDName, dict);
    
    CFRelease(description);
}

void DiskDisappearedCallback(DADiskRef diskRef, void *context) {
    if (context != (__bridge void *)[Disk class]) {
        return;
    }
    
    NSString *BSDName = [[NSString alloc] initWithUTF8String:DADiskGetBSDName(diskRef)];
    CFDictionaryRef description = DADiskCopyDescription(diskRef);
    
    NSDictionary *dict = (__bridge NSDictionary *)description;
    NSLog(@"BSD Name:: %@ \n Description:: %@", BSDName, dict);
    
    CFRelease(description);
}

void DiskDescriptionChangedCallback(DADiskRef diskRef, CFArrayRef keys, void *context) {
    if (context != (__bridge void *)[Disk class]) {
        return;
    }
    
    NSLog(@"DiskDescriptionChangedCallback here");
}

