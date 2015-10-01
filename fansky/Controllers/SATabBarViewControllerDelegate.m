//
//  SATabBarViewControllerDelegate.m
//  fansky
//
//  Created by Zzy on 10/1/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SATabBarViewControllerDelegate.h"
#import "SATimeLineViewController.h"
#import "SAMentionListViewController.h"
#import "SAConversationViewController.h"

@implementation SATabBarViewControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([tabBarController.selectedViewController isEqual:viewController]) {
        if (tabBarController.selectedIndex == 0) {
            SATimeLineViewController *timeLineViewController = (SATimeLineViewController *)viewController;
            [timeLineViewController refreshData];
        } else if (tabBarController.selectedIndex == 1) {
            SAMentionListViewController *mentionListViewController = (SAMentionListViewController *)viewController;
            [mentionListViewController refreshData];
        } else if (tabBarController.selectedIndex == 2) {
            SAConversationViewController *conversationViewController = (SAConversationViewController *)viewController;
            [conversationViewController refreshData];
        }
        return NO;
    }
    return YES;
}

@end
