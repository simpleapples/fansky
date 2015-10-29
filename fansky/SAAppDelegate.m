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
    
    [self updateAppearance];
    [self initPasscodeViewController];
    [self showPasscodeViewController];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[SANotificationManager sharedManager] stopFetchNotificationCount];
    [self showPasscodeViewController];
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[SADataManager sharedManager] saveContext];
}

- (void)initPasscodeViewController
{
    [LTHPasscodeViewController useKeychain:NO];
    [LTHPasscodeViewController sharedUser].allowUnlockWithTouchID = NO;
    [LTHPasscodeViewController sharedUser].hidesCancelButton = NO;
    [LTHPasscodeViewController sharedUser].turnOffPasscodeString = @"关闭密码";
    [LTHPasscodeViewController sharedUser].enablePasscodeString = @"设置密码";
    [LTHPasscodeViewController sharedUser].reenterPasscodeString = @"再次输入密码";
    [LTHPasscodeViewController sharedUser].enterPasscodeString = @"输入密码";
}

- (void)showPasscodeViewController
{
    if ([LTHPasscodeViewController doesPasscodeExist]) {
        if ([LTHPasscodeViewController didPasscodeTimerEnd]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[LTHPasscodeViewController sharedUser] showLockScreenWithAnimation:YES withLogout:NO andLogoutTitle:nil];
            });
        }
    }
}

- (void)updateAppearance
{
    NSDictionary *textAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]};
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    [[UIBarButtonItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [UITableView appearance].separatorInset = UIEdgeInsetsZero;
}

@end
