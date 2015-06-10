//
//  ProgressWindow.h
//  NTFS-OSX
//
//  Created by Jeevanandam M. on 6/10/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//


@interface ProgressController : NSWindowController

@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSTextField *progressText;

- (void)show;
- (void)startProgressBar;
- (void)incrementProgressBar:(double)value;
- (void)statusText:(NSString *)text;

@end
