//
//  AppDelegate.m
//  NTFS-OSX
//
//  Created by Jeevanandam Madanagopal on 6/3/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import "AppDelegate.h"
#import "NTFSApp.h"

@interface AppDelegate (NFTSOSX)

//@property(weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSLog(@"Loading...");

	app = [NTFSApp new];

	NSLog(@"Loaded successfully.");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	NSLog(@"App will terminate.");
}

@end
