//
//  Volume.h
//  NTFS-OSX
//
//  Created by Jeevanandam M. on 6/5/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//


@interface Disk : NSObject {
	CFTypeRef _diskRef;
}

@property (readonly, copy) NSString *BSDName;
@property (readonly, copy) NSString *volumeUUID;
@property (readonly, copy) NSString *volumeName;
@property (nonatomic, copy) NSURL *volumeURL;
@property (nonatomic, copy) NSString *volumePath;
@property (nonatomic) BOOL isNTFSWritable;
@property (nonatomic) BOOL isMounted;

+ (Disk *)getDiskForDARef:(DADiskRef)diskRef;
- (id)initWithDADiskRef:(DADiskRef)diskRef;
- (void)logInfo;
- (void)disappeared;

@end
