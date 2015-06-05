//
//  NTFSApplication.m
//  NTFS-OSX
//
//  Created by Jeevanandam Madanagopal on 6/3/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import "NTFSApplication.h"

@implementation NTFSApplication

@synthesize statusItem;

- (void)initNtfsApp {
	// Initializing Status Bar and Menus
	[self initStatusBar];


}

#pragma mark - NTFSApplication private methods

- (void)initStatusBar {
	NSMenu *statusMenu = [[NSMenu alloc] init];

	NSMenuItem *prefMenuItem = [[NSMenuItem alloc] initWithTitle:@"Preferences"
	                            action:NULL
	                            keyEquivalent:@""];
	NSMenuItem *donateMenuItem = [[NSMenuItem alloc] initWithTitle:@"Donate"
	                              action:NULL
	                              keyEquivalent:@""];
	NSMenuItem *supportMenuItem = [[NSMenuItem alloc] initWithTitle:@"Support"
	                               action:NULL
	                               keyEquivalent:@""];
	NSMenuItem *quitMenuIteam = [[NSMenuItem alloc] initWithTitle:@"Quit"
	                             action:NULL
	                             keyEquivalent:@""];

	[statusMenu addItem:[NSMenuItem separatorItem]];
	[statusMenu addItem:prefMenuItem];
	[statusMenu addItem:[NSMenuItem separatorItem]];
	[statusMenu addItem:donateMenuItem];
	[statusMenu addItem:supportMenuItem];
	[statusMenu addItem:[NSMenuItem separatorItem]];
	[statusMenu addItem:quitMenuIteam];

	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];

	[self.statusItem setImage:[NSImage imageNamed:@"ntfs_osx.png"]];
	[self.statusItem.image setTemplate:YES];
	[self.statusItem setHighlightMode:YES];
	[self.statusItem setMenu:statusMenu];
	[self.statusItem setToolTip:@"Enable native way of NTFS Read and Write on Mac OSX"];
}


@end
