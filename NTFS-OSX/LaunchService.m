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


LSSharedFileListItemRef AddPathToFinderFavorites(NSString *path) {
	LSSharedFileListRef favoritesRef = GetFileListRef(kLSSharedFileListFavoriteItems);

	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
	LSSharedFileListItemRef item = InsertItemURL(favoritesRef, kLSSharedFileListItemLast, url);

	Release(favoritesRef);
	Release(url);

	return item;
}

OSStatus RemoveItemFromFinderFavorties(LSSharedFileListItemRef item) {
	return RemoveItemFromList(GetFileListRef(kLSSharedFileListFavoriteItems), item);
}

BOOL IsAppLaunchOnLogin(void) {
	LSSharedFileListRef loginItemsListRef = GetFileListRef(kLSSharedFileListSessionLoginItems);

	CFArrayRef snapshotRef = GetFileListCopy(loginItemsListRef);
	NSArray* loginItems = CFBridgingRelease(snapshotRef);

	NSURL *bundleURL = AppBundleURL;
	for (id item in loginItems) {
		LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
		CFURLRef itemURLRef;
		if (LSSharedFileListItemResolve(itemRef, 0, &itemURLRef, NULL) == noErr) {
			NSURL *itemURL = (__bridge NSURL *)itemURLRef;
			if ([itemURL isEqual:bundleURL]) {
				return YES;
			}
		}
	}
	return NO;
}

void ToggleAppLaunchOnLogin(BOOL launch) {
	NSURL *bundleURL = AppBundleURL;
	LSSharedFileListRef loginItemsListRef = GetFileListRef(kLSSharedFileListSessionLoginItems);

	if (launch) {
		NSDictionary *properties = @{(AppBundleID): @YES};
		LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsListRef,
		                                                                kLSSharedFileListItemLast,
		                                                                NULL, NULL,
		                                                                (__bridge CFURLRef)bundleURL,
		                                                                (__bridge CFDictionaryRef)properties,
		                                                                NULL);
		Release(itemRef);
	} else {
		CFArrayRef snapshotRef = LSSharedFileListCopySnapshot(loginItemsListRef, NULL);
		NSArray* loginItems = CFBridgingRelease(snapshotRef);

		for (id item in loginItems) {
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
			CFURLRef itemURLRef;
			if (LSSharedFileListItemResolve(itemRef, 0, &itemURLRef, NULL) == noErr) {
				NSURL *itemURL = (__bridge NSURL *)itemURLRef;
				if ([itemURL isEqual:bundleURL]) {
					RemoveItemFromList(loginItemsListRef, itemRef);
				}
			}
		}
	}
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
	LogDebug(@"RemoveItemFromList Status: %d", (int)status);

	return status;
}

CFArrayRef GetFileListCopy(LSSharedFileListRef list) {
	return LSSharedFileListCopySnapshot(list, NULL);
}
