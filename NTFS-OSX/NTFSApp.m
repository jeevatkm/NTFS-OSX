/*
 * The MIT License (MIT)
 *
 * Application: NTFS OS X
 * Copyright (c) 2015 Jeevanandam M. (jeeva@myjeeva.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

//
//  NTFSApp.m
//  NTFS-OSX
//
//  Created by Jeevanandam M. on 6/3/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import "NTFSApp.h"
#import "Arbitration.h"
#import "Disk.h"
#import "LaunchService.h"
#import "ProgressController.h"

@import ServiceManagement;

@implementation NTFSApp

@synthesize statusItem;

- (id)init {
	if (self = [super init]) {
		// Initializing Status Bar and Menus
		[self initStatusBar];

		// Disk Arbitration
		RegisterDA();

		// App & Workspace Notification
		[self registerSession];

		//progressWindow = [ProgressController new];

		[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];

		NSLog(@"Is NTFS OS X App launch on login: %@", IsAppLaunchOnLogin() ? @"YES" : @"NO");
	}

	return self;
}

- (void)dealloc {
	// Disk Arbitration
	UnregisterDA();

	// App & Workspace Notification
	[self unregisterSession];
}


#pragma mark - Status Menu Methods

- (void)launchAtLoginMenuClicked:(id)sender {
	NSMenuItem *clickMenu = (NSMenuItem *)sender;

	if ([clickMenu state]) {
		NSLog(@"True sender state %ld", [clickMenu state]);
	} else {
		NSLog(@"False sender state %ld", [clickMenu state]);
	}
}

- (void)btcMenuClicked:(id)sender {
	NSString *btcAddress = @"1KaNKjmAFRhM5Q8aP5QWb1QTEYdGH11mZg";

	[[NSPasteboard generalPasteboard] clearContents];
	[[NSPasteboard generalPasteboard] setString:btcAddress forType:NSStringPboardType];

	if (floor(NSAppKitVersionNumber) >= NSAppKitVersionNumber10_8) {
		NSUserNotification *userNotify = [NSUserNotification new];
		userNotify.title = AppDisplayName;
		userNotify.informativeText = @"BTC address copied.";
		userNotify.soundName = NSUserNotificationDefaultSoundName;
		[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:userNotify];
	} else {
		NSAlert *userNotify = [NSAlert new];
		[userNotify addButtonWithTitle:@"Okay"];
		[userNotify setMessageText:AppDisplayName];
		[userNotify setInformativeText:[NSString stringWithFormat:@"BTC address '%@' copied.", btcAddress]];
		[userNotify setAlertStyle:NSInformationalAlertStyle];
		[userNotify setIcon:[NSApp applicationIconImage]];

		[self bringToFront];
		[userNotify runModal];
	}
}

- (void)paypalMenuClicked:(id)sender {
	OpenUrl(@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=QWMZG74FW4QYC&lc=US&item_name=Jeevanandam%20M%2e&item_number=NTFS%20OS%20X&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted");
}

- (void)supportMenuClicked:(id)sender {
	OpenUrl(@"https://github.com/jeevatkm/NTFS-OSX/issues");
}

- (void)quitMenuClicked:(id)sender {
	[[NSApplication sharedApplication] terminate:self];
}


#pragma mark - Notification Center Methods

- (void)ntfsDiskAppeared:(NSNotification *)notification {
	Disk *disk = notification.object;

	NSLog(@"ntfsDiskAppeared called - %@", disk.BSDName);
	NSLog(@"NTFS Disks Count: %lu", (unsigned long)[ntfsDisks count]);

	if (disk.isNTFSWritable) {
		NSLog(@"NTFS write mode already enabled for '%@'", disk.volumeName);
	} else {
		NSString *msgText = [NSString stringWithFormat:@"Disk detected: %@", disk.volumeName];
		//NSString *infoText = [NSString stringWithFormat:@"Would you like to enable NTFS write mode for disk '%@'", disk.volumeName];

		NSAlert *confirm = [NSAlert new];
		[confirm addButtonWithTitle:@"Enable"];
		[confirm addButtonWithTitle:@"Not Required"];
		[confirm setMessageText:msgText];
		[confirm setInformativeText:@"Would you like to enable NTFS write mode for this disk?"];
		[confirm setAlertStyle:NSWarningAlertStyle];
		[confirm setIcon:[NSApp applicationIconImage]];

		[self bringToFront];
		if ([confirm runModal] == NSAlertFirstButtonReturn) {
			//[progressWindow show];

			//[progressWindow statusText:[NSString stringWithFormat:@"Disk '%@' unmounting...", disk.volumeName]];
			[disk unmount];
			//[progressWindow incrementProgressBar:30.0];

			//[progressWindow statusText:@"Enabling Write mode..."];
			[disk enableNTFSWrite];
			//[progressWindow incrementProgressBar:30.0];

			//[progressWindow statusText:[NSString stringWithFormat:@"Disk '%@' mounting...", disk.volumeName]];
			[disk mount];
			//[progressWindow incrementProgressBar:30.0];
		}
	}

	//[progressWindow statusText:@"Opening mounted volume!"];
	//[progressWindow close];

	NSString *volumePath = disk.volumePath;
	BOOL isExits = [[NSFileManager defaultManager] fileExistsAtPath:volumePath];
	if (isExits) {
		NSLog(@"Opening mounted NTFS Volume '%@'", volumePath);
		[[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:volumePath]];
	}
}

- (void)ntfsDiskDisappeared:(NSNotification *)notification {
	Disk *disk = notification.object;

	NSLog(@"ntfsDiskDisappeared called - %@", disk.BSDName);

	[disk disappeared];
}

- (void)volumeMountNotification:(NSNotification *) notification {
	Disk *disk = [Disk getDiskForUserInfo:notification.userInfo];

	if (disk) {
		NSLog(@"NTFS Disk: '%@' mounted at '%@'", disk.BSDName, disk.volumePath);

		disk.favoriteItem = AddPathToFinderFavorites(disk.volumePath);
		NSLog(@"Added path to favorties");
	}

}

- (void)volumeUnmountNotification:(NSNotification *) notification {
	Disk *disk = [Disk getDiskForUserInfo:notification.userInfo];

	if (disk) {
		NSLog(@"NTFS Disk: '%@' unmounted from '%@'", disk.BSDName, disk.volumePath);

		if (disk.favoriteItem) {
			RemoveItemFromFinderFavorties((LSSharedFileListItemRef)disk.favoriteItem);
			NSLog(@"Removed path from favorties");
		}
	}
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
	return YES;
}



#pragma mark - Private Methods

- (void)initStatusBar {
	NSMenu *statusMenu = [[NSMenu alloc] init];

	//[[statusMenu addItemWithTitle:@"Preferences" action:@selector(prefMenuClicked:) keyEquivalent:@""] setTarget:self];

	NSMenuItem *prefsMenuItem = [NSMenuItem new];
	[prefsMenuItem setTitle:@"Preferences"];

	NSMenu *prefSubmenu = [NSMenu new];
	[[prefSubmenu addItemWithTitle:@"Launch at Login" action:@selector(launchAtLoginMenuClicked:) keyEquivalent:@""] setTarget:self];

	[prefsMenuItem setSubmenu:prefSubmenu];
	[statusMenu addItem:prefsMenuItem];

	[statusMenu addItem:[NSMenuItem separatorItem]];

	NSMenuItem *donateMenuItem = [NSMenuItem new];
	[donateMenuItem setTitle:@"Donate"];

	NSMenu *donateSubmenu = [NSMenu new];
	[[donateSubmenu addItemWithTitle:@"Paypal" action:@selector(paypalMenuClicked:) keyEquivalent:@""] setTarget:self];
	[[donateSubmenu addItemWithTitle:@"BTC 1KaNKjmAFRhM5Q8aP5QWb1QTEYdGH11mZg" action:@selector(btcMenuClicked:) keyEquivalent:@""]  setTarget:self];
	[donateMenuItem setSubmenu:donateSubmenu];
	[statusMenu addItem:donateMenuItem];

	[[statusMenu addItemWithTitle:@"Support" action:@selector(supportMenuClicked:) keyEquivalent:@""] setTarget:self];
	[statusMenu addItem:[NSMenuItem separatorItem]];
	[[statusMenu addItemWithTitle:@"Quit" action:@selector(quitMenuClicked:) keyEquivalent:@""] setTarget:self];

	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	statusItem.highlightMode = YES;
	statusItem.image = [NSImage imageNamed:AppStatusBarIconName];
	statusItem.toolTip = @"Enable native option of NTFS Write on Mac OSX";
	statusItem.menu = statusMenu;
	statusItem.title = @"";
	[statusItem.image setTemplate:YES];
}

- (void)registerSession {
	// App Level Notification
	NSNotificationCenter *acenter = [NSNotificationCenter defaultCenter];

	[acenter addObserver:self selector:@selector(ntfsDiskAppeared:) name:NTFSDiskAppearedNotification object:nil];
	[acenter addObserver:self selector:@selector(ntfsDiskDisappeared:) name:NTFSDiskDisappearedNotification object:nil];

	// Workspace Level Notification
	NSNotificationCenter *wcenter = [[NSWorkspace sharedWorkspace] notificationCenter];

	[wcenter addObserver:self selector:@selector(volumeMountNotification:) name:NSWorkspaceDidMountNotification object:nil];
	[wcenter addObserver:self selector:@selector(volumeUnmountNotification:) name:NSWorkspaceDidUnmountNotification object:nil];
}

- (void)unregisterSession {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (void)bringToFront {
	[[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

@end
