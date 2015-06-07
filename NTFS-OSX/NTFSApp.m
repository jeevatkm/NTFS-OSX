//
//  NTFSApp.m
//  NTFS-OSX
//
//  Created by Jeevanandam Madanagopal on 6/3/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import "NTFSApp.h"
#import "Arbitration.h"
#import "Disk.h"

NSString * const NSDevicePath = @"NSDevicePath";

@implementation NTFSApp

@synthesize statusItem;

- (id)init {
	self = [super init];

	if (self) {
		// Initializing Status Bar and Menus
		[self initStatusBar];

		// Disk Arbitration
		RegisterDA();

		// Workspace Notification
		[self registerSession];
	}

	return self;
}

- (void)dealloc {
	// Disk Arbitration
	UnregisterDA();

	// Workspace Notification
	[self unregisterSession];
}


#pragma mark - Status Menu Methods

- (void)prefMenuClicked:(id)sender {
	NSLog(@"prefMenuClicked: %@", sender);
}

- (void)donateMenuClicked:(id)sender {
	NSLog(@"donateMenuClicked: %@", sender);
}

- (void)supportMenuClicked:(id)sender {
	NSLog(@"supportMenuClicked: %@", sender);
}

- (void)quitMenuClicked:(id)sender {
	[[NSApplication sharedApplication] terminate:self];
}

- (void)ntfsDiskAppeared:(NSNotification *)notification {
	Disk *disk = notification.object;

	NSLog(@"ntfsDiskAppeared called - %@", disk.BSDName);
	NSLog(@"NTFS Disks Count: %lu", (unsigned long)[ntfsDisks count]);

	if (disk.isNTFSWritable) {
		NSLog(@"NTFS write mode already enabled for '%@'", disk.volumeName);
	} else {
		NSLog(@"Enabling NTFS write mode for '%@'", disk.volumeName);

		NSString *msgText = [NSString stringWithFormat:@"Disk detected: %@", disk.volumeName];
		//NSString *infoText = [NSString stringWithFormat:@"Would you like to enable NTFS write mode for disk '%@'", disk.volumeName];

		NSAlert *confirm = [[NSAlert alloc] init];
		[confirm addButtonWithTitle:@"Enable"];
		[confirm addButtonWithTitle:@"Not Required"];
		[confirm setMessageText:msgText];
		[confirm setInformativeText:@"Would you like to enable NTFS write mode for this disk?"];
		[confirm setAlertStyle:NSWarningAlertStyle];
		[confirm setIcon:[NSImage imageNamed:@"ntfs_osx.png"]];

		[NSApp activateIgnoringOtherApps:YES];
		if ([confirm runModal] == NSAlertFirstButtonReturn) {
			[disk enableNTFSWrite];
			[disk unmount];
			[disk mount];
		}
	}
}

- (void)ntfsDiskDisappeared:(NSNotification *)notification {
	Disk *disk = notification.object;

	NSLog(@"ntfsDiskDisappeared called - %@", disk.BSDName);

	[disk disappeared];
}


#pragma mark - Private Methods

- (void)initStatusBar {
	NSMenu *statusMenu = [[NSMenu alloc] init];

	NSMenuItem *prefMenuItem = [[NSMenuItem alloc] initWithTitle:@"Preferences"
	                            action:@selector(prefMenuClicked:)
	                            keyEquivalent:@""];
	NSMenuItem *donateMenuItem = [[NSMenuItem alloc] initWithTitle:@"Donate"
	                              action:@selector(donateMenuClicked:)
	                              keyEquivalent:@""];
	NSMenuItem *supportMenuItem = [[NSMenuItem alloc] initWithTitle:@"Support"
	                               action:@selector(supportMenuClicked:)
	                               keyEquivalent:@""];
	NSMenuItem *quitMenuIteam = [[NSMenuItem alloc] initWithTitle:@"Quit"
	                             action:@selector(quitMenuClicked:)
	                             keyEquivalent:@""];
	prefMenuItem.target = self;
	donateMenuItem.target = self;
	supportMenuItem.target = self;
	quitMenuIteam.target = self;

	[statusMenu addItem:prefMenuItem];
	[statusMenu addItem:[NSMenuItem separatorItem]];
	[statusMenu addItem:donateMenuItem];
	[statusMenu addItem:supportMenuItem];
	[statusMenu addItem:[NSMenuItem separatorItem]];
	[statusMenu addItem:quitMenuIteam];

	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	statusItem.highlightMode = YES;
	statusItem.image = [NSImage imageNamed:@"ntfs_osx.png"];
	statusItem.toolTip = @"Enable native option of NTFS Write on Mac OSX";
	statusItem.menu = statusMenu;
	statusItem.title = @"";
	[statusItem.image setTemplate:YES];
}

- (void)registerSession {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

	[center removeObserver:self];
	[center addObserver:self selector:@selector(ntfsDiskAppeared:) name:NTFSDiskAppearedNotification object:nil];
	[center addObserver:self selector:@selector(ntfsDiskDisappeared:) name:NTFSDiskDisappearedNotification object:nil];
}

- (void)unregisterSession {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
