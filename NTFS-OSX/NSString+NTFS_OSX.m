//
//  NSString+NTFS_OSX.m
//  NTFS-OSX
//
//  Created by Jeevanandam Madanagopal on 6/7/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import "NSString+NTFS_OSX.h"

@implementation NSString (NTFS_OSX)

- (BOOL)isBlank
{
	if([[self trim] isEqualToString:@""])
		return YES;
	return NO;
}

- (NSString *)trim
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
