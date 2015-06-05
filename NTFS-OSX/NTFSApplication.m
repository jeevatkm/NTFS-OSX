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

	[statusMenu addItem:[NSMenuItem separatorItem]];
	[statusMenu addItem:prefMenuItem];
	[statusMenu addItem:[NSMenuItem separatorItem]];
	[statusMenu addItem:donateMenuItem];
	[statusMenu addItem:supportMenuItem];
	[statusMenu addItem:[NSMenuItem separatorItem]];
	[statusMenu addItem:quitMenuIteam];

	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	statusItem.highlightMode = YES;
	statusItem.image = [NSImage imageNamed:@"ntfs_osx.png"];
	statusItem.toolTip = @"Enable native way of NTFS Read and Write on Mac OSX";
	statusItem.menu = statusMenu;
	statusItem.title = @"";
	[statusItem.image setTemplate:YES];
}

@end
