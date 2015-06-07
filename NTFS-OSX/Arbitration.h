//
//  Arbitration.h
//  NTFS-OSX
//
//  Created by Jeevanandam Madanagopal on 6/5/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

@import DiskArbitration;

void RegisterDA(void);
void UnregisterDA(void);
BOOL Validate(DADiskRef diskRef);
void DiskAppearedCallback(DADiskRef diskRef, void *context);
void DiskDisappearedCallback(DADiskRef diskRef, void *context);
void DiskDescriptionChangedCallback(DADiskRef diskRef, CFArrayRef keys, void *context);
DADissenterRef DiskMountApprovalCallback(DADiskRef diskRef, void *context);
DADissenterRef DiskUnmountApprovalCallback(DADiskRef diskRef, void *context);

extern NSString * const DADiskDescriptionVolumeKindValue;
extern NSString * const NTFSDiskAppearedNotification;
extern NSString * const NTFSDiskDisappearedNotification;
extern NSString * const AppName;

extern NSMutableSet *ntfsDisks;

