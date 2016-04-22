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
#import "SADataManager+User.h"
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

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    if ([shortcutItem.type isEqualToString:@"com.zangzhiya.fansky.compose"]) {
        [self showComposeViewControllerFromApplication:application];
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    if ([url.absoluteString isEqualToString:@"fansky://compose"]) {
        [self showComposeViewControllerFromApplication:app];
    }
    return YES;
}

- (void)showComposeViewControllerFromApplication:(UIApplication *)app
{
    if (![SADataManager sharedManager].currentUser) {
        return;
    }
    UIViewController *rootViewController = app.keyWindow.rootViewController;
    if ([rootViewController isMemberOfClass:[UINavigationController class]]) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SAMain" bundle:[NSBundle mainBundle]];
        UIViewController *composeViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"SAComposeViewController"];
        [rootViewController presentViewController:composeViewController animated:YES completion:nil];
    }
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
