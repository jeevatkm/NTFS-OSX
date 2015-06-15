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

@import ServiceManagement;

@implementation NTFSApp

@synthesize statusItem;

- (id)init {
	if (self = [super init]) {
        // registering default preferences
        [self registarDefaults];
        
        BOOL debugEnabled = GetDefaultBool(PrefsDebugMode);
        [Logger setDebugLog:debugEnabled];
        
        LogInfo(@"Debug enabled - %@", debugEnabled ? Yes : No);
        LogInfo(@"Launch on login - %@", GetDefaultBool(PrefsLaunchAtLogin) ? Yes : No);
        
		// Initializing Status Bar and Menus
		[self initStatusBar];

		// Disk Arbitration
		RegisterDA();

		// App & Workspace Notification
		[self registerSession];

		[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
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
	NSMenuItem *launchAtLoginMenu = (NSMenuItem *)sender;

	if ([launchAtLoginMenu state]) {
		[launchAtLoginMenu setState:NSOffState];
		SetDefaultBool(NO, PrefsLaunchAtLogin);
	} else {
		[launchAtLoginMenu setState:NSOnState];
		SetDefaultBool(YES, PrefsLaunchAtLogin);
	}
}

- (void)btcMenuClicked:(id)sender {
	[[NSPasteboard generalPasteboard] clearContents];
	[[NSPasteboard generalPasteboard] setString:BTCAddress forType:NSStringPboardType];

    [self notifyUser:@"BTC address copied."];
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

	LogInfo(@"DiskAppeared - %@", disk.BSDName);
	LogDebug(@"Disks Count - %lu", (unsigned long)[ntfsDisks count]);

	if (disk.isNTFSWritable) {
		LogInfo(@"Write mode already enabled for '%@'", disk.volumeName);
	} else {
		NSString *msgText = [NSString stringWithFormat:@"Disk detected: %@", disk.volumeName];

		NSAlert *confirm = [NSAlert new];
		[confirm addButtonWithTitle:@"Enable"];
		[confirm addButtonWithTitle:@"Not Required"];
		[confirm setMessageText:msgText];
		[confirm setInformativeText:@"Would you like to enable NTFS write mode for this disk?"];
		[confirm setAlertStyle:NSWarningAlertStyle];
		[confirm setIcon:[NSApp applicationIconImage]];

		[self bringToFront];
		if ([confirm runModal] == NSAlertFirstButtonReturn) {
			[disk unmount];
			[disk enableNTFSWrite];
			[disk mount];
		}
	}

	NSString *volumePath = disk.volumePath;
	BOOL isExits = [[NSFileManager defaultManager] fileExistsAtPath:volumePath];
	if (isExits) {
		LogDebug(@"Opening mounted NTFS Volume '%@'", volumePath);
		[[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:volumePath]];
        
        [self notifyUser:[NSString stringWithFormat:@"NTFS write enabled for '%@'.", disk.volumeName]];
	}
}

- (void)ntfsDiskDisappeared:(NSNotification *)notification {
	Disk *disk = notification.object;

	LogInfo(@"DiskDisappeared - %@", disk.BSDName);

	[disk disappeared];
}

- (void)volumeMountNotification:(NSNotification *) notification {
	Disk *disk = [Disk getDiskForUserInfo:notification.userInfo];

	if (disk) {
		LogDebug(@"NTFS Disk: '%@' mounted at '%@'", disk.BSDName, disk.volumePath);

		disk.favoriteItem = AddPathToFinderFavorites(disk.volumePath);
		LogDebug(@"Added path to favorties");
	}

}

- (void)volumeUnmountNotification:(NSNotification *) notification {
	Disk *disk = [Disk getDiskForUserInfo:notification.userInfo];

	if (disk) {
		LogDebug(@"NTFS Disk: '%@' unmounted from '%@'", disk.BSDName, disk.volumePath);

		if (disk.favoriteItem) {
			RemoveItemFromFinderFavorties((LSSharedFileListItemRef)disk.favoriteItem);
			LogDebug(@"Removed path from favorties");
		}
	}
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
	return YES;
}



#pragma mark - Private Methods

- (void)initStatusBar {
	NSMenu *statusMenu = [NSMenu new];

	NSMenuItem *prefsMenuItem = [NSMenuItem new];
	[prefsMenuItem setTitle:@"Preferences"];

	NSMenu *prefSubmenu = [NSMenu new];
	NSMenuItem *launchAtLogin = [[NSMenuItem alloc] initWithTitle:@"Launch at Login" action:@selector(launchAtLoginMenuClicked:) keyEquivalent:@""];
	[launchAtLogin setTarget:self];

	if (GetDefaultBool(PrefsLaunchAtLogin)) {
		[launchAtLogin setState:NSOnState];
	} else {
		[launchAtLogin setState:NSOffState];
	}

	[prefSubmenu addItem:launchAtLogin];

	[prefsMenuItem setSubmenu:prefSubmenu];
	[statusMenu addItem:prefsMenuItem];

	[statusMenu addItem:[NSMenuItem separatorItem]];

	NSMenuItem *donateMenuItem = [NSMenuItem new];
	[donateMenuItem setTitle:@"Donate"];

	NSMenu *donateSubmenu = [NSMenu new];
	[[donateSubmenu addItemWithTitle:@"PayPal" action:@selector(paypalMenuClicked:) keyEquivalent:@""] setTarget:self];
	[[donateSubmenu addItemWithTitle:@"BTC" action:@selector(btcMenuClicked:) keyEquivalent:@""]  setTarget:self];
	[donateMenuItem setSubmenu:donateSubmenu];
	[statusMenu addItem:donateMenuItem];

	[[statusMenu addItemWithTitle:@"Support" action:@selector(supportMenuClicked:) keyEquivalent:@""] setTarget:self];
	[statusMenu addItem:[NSMenuItem separatorItem]];
	[[statusMenu addItemWithTitle:@"Quit" action:@selector(quitMenuClicked:) keyEquivalent:@""] setTarget:self];

	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	statusItem.highlightMode = YES;
	statusItem.image = [NSImage imageNamed:AppStatusBarIconName];
	statusItem.toolTip = @"Enable native option of NTFS Write on Mac OS X";
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

- (void)registarDefaults {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
	                      [NSNumber numberWithBool:YES], PrefsLaunchAtLogin,
                          [NSNumber numberWithBool:NO], PrefsDebugMode,
	                      nil];

	[[NSUserDefaults standardUserDefaults] registerDefaults:dict];
}

- (void)notifyUser:(NSString *)infoText {
    if (floor(NSAppKitVersionNumber) >= NSAppKitVersionNumber10_8) {
        NSUserNotification *userNotify = [NSUserNotification new];
        userNotify.title = AppDisplayName;
        userNotify.informativeText = infoText;
        userNotify.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:userNotify];
    } else {
        NSAlert *userNotify = [NSAlert new];
        [userNotify addButtonWithTitle:@"Okay"];
        [userNotify setMessageText:AppDisplayName];
        [userNotify setInformativeText:infoText];
        [userNotify setAlertStyle:NSInformationalAlertStyle];
        [userNotify setIcon:[NSApp applicationIconImage]];
        
        [self bringToFront];
        [userNotify runModal];
    }
}

@end
