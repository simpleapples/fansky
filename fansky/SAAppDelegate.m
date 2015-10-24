//
//  AppDelegate.m
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAAppDelegate.h"
#import "SADataManager.h"
#import "SANotificationManager.h"
#import <MobClick.h>
#import <LTHPasscodeViewController/LTHPasscodeViewController.h>

@implementation SAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MobClick startWithAppkey:@"560676ece0f55a154f0002d5" reportPolicy:BATCH channelId:@"AppStore"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    
    [LTHPasscodeViewController useKeychain:NO];
    
    [self updateAppearance];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[SANotificationManager sharedManager] stopFetchNotificationCount];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[SADataManager sharedManager] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[SANotificationManager sharedManager] startFetchNotificationCount];
    
    if ([LTHPasscodeViewController doesPasscodeExist]) {
        if ([LTHPasscodeViewController didPasscodeTimerEnd]) {
            [[LTHPasscodeViewController sharedUser] showLockScreenWithAnimation:YES withLogout:NO andLogoutTitle:nil];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[SADataManager sharedManager] saveContext];
}

- (void)updateAppearance
{
    NSDictionary *textAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]};
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    [[UIBarButtonItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
}

@end
