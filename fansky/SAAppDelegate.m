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
#import "UIColor+Utils.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <LTHPasscodeViewController/LTHPasscodeViewController.h>

@implementation SAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[[Crashlytics class]]];
    
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

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[SANotificationManager sharedManager] startFetchNotificationCount];
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
    UIImage *backButtonImage = [UIImage imageNamed:@"IconBackBlack"];
    [UINavigationBar appearance].backIndicatorImage = backButtonImage;
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = backButtonImage;
    NSDictionary *textAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]};
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    [UIActivityIndicatorView appearance].color = [UIColor fanskyBlue];
    [UIRefreshControl appearance].tintColor = [UIColor fanskyBlue];

    [UITableView appearance].separatorInset = UIEdgeInsetsZero;
}

@end
