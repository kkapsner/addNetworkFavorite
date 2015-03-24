//
//  main.m
//  addNetworkFavorite
//
//  Created by Kapsner, Korbinian on 23.03.15.
//  Copyright (c) 2015 Kapsner, Korbinian. All rights reserved.
//

#import <Foundation/Foundation.h>
@import NetFS;

int addFavorite(NSString *path, NSString *displayName){
    @autoreleasepool {
        NSLog(@"Adding favorite: %@ (%@)", path, displayName);
        
        LSSharedFileListRef favoriteItems = LSSharedFileListCreate(NULL, kLSSharedFileListFavoriteItems, NULL);
        
        CFURLRef mountURL = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
        
        LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(
            favoriteItems,
            kLSSharedFileListItemLast,
            (__bridge CFStringRef)(displayName),
            NULL,
            mountURL,
            NULL,
            NULL
        );
        
        if (item){
            CFRelease(item);
            return 0;
        }
        else {
            NSLog(@"Unable to add favorite.");
            return 1;
        }
    }
}

int checkDirectoryExists(NSString *dir){
    BOOL isDirectory;
    if ([[NSFileManager defaultManager] fileExistsAtPath: dir isDirectory: &isDirectory] && isDirectory){
        return 0;
    }
    else {
        return 1;
    }
}

void removeFirstPathPart(NSString **path, NSString **part){
    NSRange backPartStartRange = [*path
                                  rangeOfString: @"/"
                                  options: NSLiteralSearch
                                  range: NSMakeRange(1, (*path).length - 1)
                                  ];
    
    if (backPartStartRange.location == NSNotFound && backPartStartRange.length == 0){
        *part = *path;
        *path = @"";
    }
    else {
        *part = [*path substringToIndex: backPartStartRange.location];
        *path = [*path substringFromIndex: backPartStartRange.location];
    }
}

int getPath(NSString *base, NSString *tryPath, NSString **finalPath){
    NSString *backPart = [NSString stringWithFormat: @"%@", tryPath];
    NSString *pathPart = NULL;
    NSString *path = @"";
    NSString *testPath;
    
    while (backPart.length){
        removeFirstPathPart(&backPart, &pathPart);
        testPath = [NSString stringWithFormat:@"%@%@%@/", base, path, pathPart];
        NSLog(@"    checking %@", testPath);
        if (!checkDirectoryExists(testPath)){
            path = [path stringByAppendingString: pathPart];
        }
    }
    if (path.length){
        *finalPath = [NSString stringWithFormat:@"%@%@/", base, path];
        return checkDirectoryExists(*finalPath);
    }
    else {
        return 1;
    }
}
int guessDefaultMountPoint(NSString *sharePath, NSString **mountPoint){
    NSURL *url = [NSURL URLWithString: sharePath];
    return getPath(@"/Volumes", url.path, mountPoint);
}
int getMountPoint(NSString *sharePath, NSString *mountBase, NSString **mountPoint){
    NSURL *url = [NSURL URLWithString: sharePath];
    return getPath(mountBase, url.path, mountPoint);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 3){
            NSLog(@"Two arguments required: shared network path and folder to add to favorites (use \"\" for the root). Third argument (display name) is optional.");
            return 1;
        }
        else {
            NSString *sharePath = [NSString stringWithCString:argv[1] encoding:[NSString defaultCStringEncoding]];
            NSString *sharedFolder = [NSString stringWithCString:argv[2] encoding:[NSString defaultCStringEncoding]];
            NSString *displayName;
            if (argc < 4){
                displayName = NULL;
            }
            else {
                displayName = [NSString stringWithCString:argv[3] encoding:[NSString defaultCStringEncoding]];
            }
            
            NSLog(@"Mounting share: %@", sharePath);
            
            NSURL *shareURL = [NSURL URLWithString: sharePath];
            CFArrayRef mountpoints = NULL;
            UInt32 error = NetFSMountURLSync(
                (__bridge CFURLRef)(shareURL),
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                &mountpoints
            );
            
            if (error){
                NSLog(@"Unable to mount (%d)", error);
                if (error == 17){ // already mounted
                    if (mountpoints && CFArrayGetCount(mountpoints)){
                        NSLog(@"%@", CFArrayGetValueAtIndex(mountpoints, 0));
                    }
                    else {
                        NSLog(@"Already mounted but mount point unknown trying to guess...");
                        NSString *mountPoint;
                        if (guessDefaultMountPoint(sharePath, &mountPoint)){
                            NSLog(@"... unable to guess.");
                            return 1;
                        }
                        else {
                            
                            NSLog(@"... %@", mountPoint);
                            return addFavorite([NSString stringWithFormat: @"%@%@", mountPoint, sharedFolder], displayName);
                        }
                    }
                }
            }
            else {
                NSLog(@"Mounted");
                if (CFArrayGetCount(mountpoints)){
                    NSString *mountPoint = CFArrayGetValueAtIndex(mountpoints, 0);
                    return addFavorite([NSString stringWithFormat: @"%@/%@", mountPoint, sharedFolder], displayName);
                }
                else {
                    NSLog(@"No mount point found.");
                    return 1;
                }
            }
        }
    }
    return 0;
}
