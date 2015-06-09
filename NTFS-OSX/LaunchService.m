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
//  LaunchService.m
//  NTFS-OSX
//
//  Created by Jeevanandam M. on 6/8/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//

#import "LaunchService.h"

@implementation LaunchService

LSSharedFileListItemRef AddPathToFinderFavorites(NSString *path) {
	LSSharedFileListRef favoritesRef = GetFileListRef(kLSSharedFileListFavoriteItems);
    
	//UInt32 seed;
	//CFArrayRef items = LSSharedFileListCopySnapshot(favoritesRef, &seed);

	//NSLog(@"Items :: %@", items);
	//BOOL found = FALSE;
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
	/* for(size_t i = 0; i < CFArrayGetCount(items); i++) {
		LSSharedFileListItemRef item = (LSSharedFileListItemRef)CFArrayGetValueAtIndex(items, i);
		if(!item) { continue; }

		CFURLRef outURL = NULL;
		LSSharedFileListItemResolve(item, kLSSharedFileListNoUserInteraction, (CFURLRef *) &outURL, NULL); //kLSSharedFileListDoNotMountVolumes
		if(!outURL) {  continue; }

		// Path string of the favorites item
		//CFStringRef itemPath = CFURLCopyFileSystemPath(outURL, kCFURLPOSIXPathStyle);
		found = CFEqual(url, outURL);

		//NSLog(@"Found: %hhd, itemPath :: %@", found, itemPath);

		CFRelease(outURL);
		//CFRelease(itemPath);

		if (found) {
			break;
		}
	} */

    LSSharedFileListItemRef item = InsertItemURL(favoritesRef, kLSSharedFileListItemLast, url);
	/*if (favoritesRef && !found) {
		item = InsertItemURL(favoritesRef, kLSSharedFileListItemLast, url);
	} */

	RELEASE(favoritesRef);
    
    return item;
}

OSStatus RemoveItemFromFinderFavorties(LSSharedFileListItemRef item) {
    return RemoveItemFromList(GetFileListRef(kLSSharedFileListFavoriteItems), item);
}


LSSharedFileListRef GetFileListRef(CFStringRef fileListRef) {
	return LSSharedFileListCreate(kCFAllocatorDefault, fileListRef, NULL);
}

LSSharedFileListItemRef InsertItemURL(LSSharedFileListRef inList,
                                      LSSharedFileListItemRef insertAfterThisItem,
                                      CFURLRef url) {
	return LSSharedFileListInsertItemURL(inList,
	                                     insertAfterThisItem, NULL, NULL,
	                                     url, NULL, NULL);
}

OSStatus RemoveItemFromList(LSSharedFileListRef inList, LSSharedFileListItemRef item) {
    OSStatus status = LSSharedFileListItemRemove(inList, item);
    NSLog(@"RemoveItemFromList Status: %d", (int)status);
    
    return status;
}

CFArrayRef GetFileListCopy(LSSharedFileListRef list) {
    UInt32 seed;
    return LSSharedFileListCopySnapshot(list, &seed);
}

@end
