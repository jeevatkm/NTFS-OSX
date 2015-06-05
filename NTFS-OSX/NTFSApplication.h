//
//  NTFSApplication.h
//  NTFS-OSX
//
//  Created by Jeevanandam Madanagopal on 6/3/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface NTFSApplication : NSObject {
}

@property(strong, nonatomic) NSStatusItem *statusItem;

- (void)initNtfsApp;

@end
