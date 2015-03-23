//
//  main.m
//  addNetworkFavorite
//
//  Created by Kapsner, Korbinian on 23.03.15.
//  Copyright (c) 2015 Kapsner, Korbinian. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2){
            NSLog(@"One arguments required: mounted volume path. Second argument (display name) optional.");
            return 1;
        }
        else {
            NSString *mountPath = [NSString stringWithCString:argv[1] encoding:[NSString defaultCStringEncoding]];
            NSString *displayName;
            if (argc < 3){
                displayName = NULL;
            }
            else {
                displayName = [NSString stringWithCString:argv[2] encoding:[NSString defaultCStringEncoding]];
            }
            NSLog(@"Adding favorite: %@ (%@)", mountPath, displayName);
            
            LSSharedFileListRef favoriteItems = LSSharedFileListCreate(NULL, kLSSharedFileListFavoriteItems, NULL);
            
            
            CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:mountPath];
            
            
            LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(favoriteItems, kLSSharedFileListItemLast, (__bridge CFStringRef)(displayName), NULL, url, NULL, NULL);
            
            if (item){
                CFRelease(item);
            }
        }
    }
    return 0;
}
