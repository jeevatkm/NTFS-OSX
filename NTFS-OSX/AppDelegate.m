//
//  AppDelegate.m
//  NTFS-OSX
//
//  Created by Jeevanandam Madanagopal on 6/3/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (NFTSOSX)

@property(weak) IBOutlet NSWindow *window;
@property(strong, nonatomic) NSStatusItem *ntfsStatusBar;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [self initNtfsApp];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

#pragma mark - NTFS-OSX private methods

- (void)initNtfsApp {
  // Initializing Status Bar and Menus
  [self initStatusBar];

  NSLog(@"NTFS-OSX is loaded successfully.");
}

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
  NSMenuItem *quitMenuIteam =
      [[NSMenuItem alloc] initWithTitle:@"Quit" action:NULL keyEquivalent:@""];

  [statusMenu addItem:[NSMenuItem separatorItem]];
  [statusMenu addItem:prefMenuItem];
  [statusMenu addItem:[NSMenuItem separatorItem]];
  [statusMenu addItem:donateMenuItem];
  [statusMenu addItem:supportMenuItem];
  [statusMenu addItem:[NSMenuItem separatorItem]];
  [statusMenu addItem:quitMenuIteam];

  self.ntfsStatusBar = [[NSStatusBar systemStatusBar]
      statusItemWithLength:NSSquareStatusItemLength];

  [self.ntfsStatusBar setImage:[NSImage imageNamed:@"ntfs_osx.png"]];
  [self.ntfsStatusBar.image setTemplate:YES];
  [self.ntfsStatusBar setHighlightMode:YES];
  [self.ntfsStatusBar setMenu:statusMenu];
  //[self.statusBar
  // setToolTip:@"Enable native way of NTFS Read and Write on Mac OSX"];
}

@end
