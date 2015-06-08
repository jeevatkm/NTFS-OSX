//
//  Disk.h
//  NTFS-OSX
//
//  Created by Jeevanandam M. on 6/5/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//


@interface Disk : NSObject {
	CFTypeRef _diskRef;
	NSImage *icon;
}

@property (readonly, copy) NSString *BSDName;
@property CFDictionaryRef desc;
@property (readonly, copy) NSString *volumeUUID;
@property (readonly, copy) NSString *volumeName;
@property (nonatomic, copy) NSString *volumePath;
@property (nonatomic) BOOL isNTFSWritable;
@property (readonly, retain) NSImage *icon;

+ (Disk *)getDiskForDARef:(DADiskRef)diskRef;
+ (Disk *)getDiskForUserInfo:(NSDictionary *)userInfo;
- (id)initWithDADiskRef:(DADiskRef)diskRef;
- (void)disappeared;
- (void)enableNTFSWrite;
- (void)mount;
- (void)unmount;

@end
