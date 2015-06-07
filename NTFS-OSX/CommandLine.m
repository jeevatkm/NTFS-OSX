//
//  CommandLine.m
//  NTFS-OSX
//
//  Created by Jeevanandam Madanagopal on 6/5/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import "CommandLine.h"

@implementation CommandLine

+ (NSString *)run:(NSString *) command {
	NSTask *task = [[NSTask alloc] init];
	NSPipe *pipe = [NSPipe pipe];
	NSFileHandle *file = [pipe fileHandleForReading];

	[task setLaunchPath: @"/bin/sh"];

	NSArray *arguments = [NSArray arrayWithObjects: @"-c",
	                      [NSString stringWithFormat:@"%@", command],
	                      nil];
	NSLog(@"run command: %@",command);

	[task setArguments: arguments];
	[task setStandardOutput: pipe];
	[task launch];
	[task waitUntilExit];

	NSData *data = [file readDataToEndOfFile];
	NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];

	return output;
}

@end
