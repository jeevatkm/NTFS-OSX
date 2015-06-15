//
//  Logger.m
//  NTFS-OSX
//
//  Created by Jeevanandam M. on 6/15/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//
// Inspried by http://borkware.com/rants/agentm/mlog/


#import "Logger.h"

static BOOL __DebugLogOn = NO;

@implementation Logger

+ (void)setDebugLog:(BOOL)debugOn {
    __DebugLogOn = debugOn;
}

+ (void)logFor:(char *)srcFile line:(int)line format:(NSString *)format, ... {
    if (__DebugLogOn == NO) {
        return;
    }
    
    va_list ap;
    NSString *file;
    NSString *msg;
    
    va_start(ap, format);    
    file = [[NSString stringWithUTF8String:srcFile] lastPathComponent];
    msg = [NSString stringWithFormat:format, ap];
    va_end(ap);
    
    NSLog(@"[%@:%d] %@", file, line, msg);
    
    return;
}

@end
