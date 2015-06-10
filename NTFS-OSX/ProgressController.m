//
//  ProgressWindow.m
//  NTFS-OSX
//
//  Created by Jeevanandam M. on 6/10/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import "ProgressController.h"

@interface ProgressController (NFTSOSX)

@end


@implementation ProgressController

@synthesize progressBar;
@synthesize progressText;

- (id)init {
    self = [super initWithWindowNibName:@"ProgressController" owner:self];
    if(self) {
        // for initialize

    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)show {
    [self startProgressBar];
    [self showWindow:nil];
}

- (void)startProgressBar {
    [progressBar setMinValue:0.0];
    [progressBar setMaxValue:100.0];
    [progressBar setDoubleValue:0.0];
}

- (void)incrementProgressBar:(double)value {
    if([progressBar doubleValue] < 100.0) {
        [progressBar incrementBy:value];
    }
}

- (void)statusText:(NSString *)text {
    progressText.stringValue = text;
}

@end
