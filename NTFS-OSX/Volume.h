//
//  Volume.h
//  NTFS-OSX
//
//  Created by Jeevanandam M. on 6/5/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//


@interface Volume : NSObject {
	CFTypeRef volume;
	NSString *_BSDName;
	CFDictionaryRef description;
}

@property (copy) NSString *BSDName;
@property CFDictionaryRef description;
@property (readonly) BOOL isNTFSWritable;
@property (readonly) BOOL isMounted;
@property (readonly) BOOL isNetworkVolume;

- (void)mount;
- (void)mountWithOptions:(NSUInteger)options;
- (void)unmountWithOptions:(NSUInteger)options;
- (void)eject;

@end
