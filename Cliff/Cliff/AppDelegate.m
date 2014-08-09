//
//  AppDelegate.m
//  Cliff
//
//  Created by Alex Ryan on 7/27/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
    return YES;
}

- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application{
    [self.window.rootViewController presentViewController:nil animated:NO completion:nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"deviceUnlockedWithAuthentication" object:nil];
    
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"receivedUnlockRequest" object:nil];
  
}

@end
