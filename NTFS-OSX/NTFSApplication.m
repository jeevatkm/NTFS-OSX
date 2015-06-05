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

	[self registerVolumesObservers];



	//[[NSUserDefaults standardUserDefaults] setObject:@"For Test" forKey:@"NTFSTestPref"];

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

- (void)registerVolumesObservers {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter]; //[[NSWorkspace sharedWorkspace] notificationCenter];

	[center addObserver:self selector: @selector(volumesMountNotification:) name:NSWorkspaceDidMountNotification object: nil];

	[center addObserver:self selector: @selector(volumesUnmountNotification:) name:NSWorkspaceDidUnmountNotification object: nil];
}

- (void)volumesMountNotification:(NSNotification*) notification {

}

- (void)volumesUnmountNotification:(NSNotification*) notification {

}

-(void) volumesChanged: (NSNotification*) notification
{
	NSLog(@"Notification Name:: %@", notification.name);

	NSLog(@"notification object :: %@", notification.object);

	NSLog(@"notification userinfo :: %@", notification.userInfo);

	BOOL isRemovable, isWritable, isUnmountable;
	NSString *description, *type;

	NSString *volUrl = [notification.userInfo objectForKey:NSWorkspaceVolumeURLKey];

	[[NSWorkspace sharedWorkspace] getFileSystemInfoForPath:volUrl
	 isRemovable:&isRemovable
	 isWritable:&isWritable
	 isUnmountable:&isUnmountable
	 description:&description
	 type:&type];

	NSLog(@"Filesystem description:%@ type:%@ removable:%d writable:%d unmountable:%d", description, type, isRemovable, isWritable, isUnmountable);

	//sleep(200);

	/* NSError * __autoreleasing error = nil;

	   BOOL result = [[NSWorkspace sharedWorkspace] unmountAndEjectDeviceAtURL:
	   [NSURL fileURLWithPath:[notification.userInfo objectForKey:@"NSDevicePath"]]
	   error:&error];

	   NSLog(@"Unmount result %hhd", result); */

	/*NSString *cmd = [NSString stringWithFormat:@"diskutil list | grep \"%@\"", [notification.userInfo objectForKey:NSWorkspaceVolumeLocalizedNameKey]];
	   NSString *output = [self runCommand: cmd];

	   NSLog(@"Command output: %@", output);

	   NSArray *wordsAndEmptyStrings = [output componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

	   NSLog(@"wordsAndEmptyStrings output: %@", wordsAndEmptyStrings);

	   NSArray *words = [wordsAndEmptyStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];

	   NSLog(@"words output: %@", words); */

}

- (NSString *) runCommand:(NSString *) commandToRun
{
	NSTask *task = [[NSTask alloc] init];
	NSPipe *pipe = [NSPipe pipe];
	NSFileHandle *file = [pipe fileHandleForReading];

	[task setLaunchPath: @"/bin/sh"];

	NSArray *arguments = [NSArray arrayWithObjects: @"-c",
	                      [NSString stringWithFormat:@"%@", commandToRun],
	                      nil];
	NSLog(@"run command: %@",commandToRun);

	[task setArguments: arguments];
	[task setStandardOutput: pipe];
	[task launch];

	NSData *data = [file readDataToEndOfFile];
	NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];

	return output;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
