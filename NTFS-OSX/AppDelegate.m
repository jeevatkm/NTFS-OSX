//
//  AppDelegate.m
//  NTFS-OSX
//
//  Created by Jeevanandam Madanagopal on 6/3/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import "AppDelegate.h"
#import "NTFSApplication.h"

@interface AppDelegate (NFTSOSX)

//@property(weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	app = [[NTFSApplication alloc] init];
	[app initNtfsApp];

	NSLog(@"NTFS-OSX is loaded successfully.");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	NSLog(@"NTFS-OSX is unloaded successfully.");
}

@end
