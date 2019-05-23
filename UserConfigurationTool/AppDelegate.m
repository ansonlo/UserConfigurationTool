//
//  AppDelegate.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/19.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "AppDelegate.h"

NSNotificationName NSApplicationOpenUrls = @"NSApplicationOpenUrls";

NSString * const NSApplicationOpenUrlsKey = @"NSApplicationOpenUrlsKey";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return true;
}

- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NSApplicationOpenUrls object:application userInfo:@{NSApplicationOpenUrlsKey:urls}];
}


@end
