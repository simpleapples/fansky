//
//  SATabBarViewController.m
//  fansky
//
//  Created by Zzy on 9/14/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SATabBarViewController.h"
#import "SAUserListViewController.h"
#import "SANotificationManager.h"

@interface SATabBarViewController ()

@end

@implementation SATabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[SANotificationManager sharedManager] addObserver:self forKeyPath:@"timeLineCount" options:(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew) context:nil];
    [[SANotificationManager sharedManager] addObserver:self forKeyPath:@"mentionCount" options:(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew) context:nil];
    [[SANotificationManager sharedManager] addObserver:self forKeyPath:@"messageCount" options:(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew) context:nil];
}

- (void)dealloc
{
    [[SANotificationManager sharedManager] removeObserver:self forKeyPath:@"timeLineCount"];
    [[SANotificationManager sharedManager] removeObserver:self forKeyPath:@"mentionCount"];
    [[SANotificationManager sharedManager] removeObserver:self forKeyPath:@"messageCount"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)exitToTabBar:(UIStoryboardSegue *)segue
{
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"timeLineCount"]) {
        if ([SANotificationManager sharedManager].timeLineCount) {
            NSString *badgeString = @"...";
            if ([SANotificationManager sharedManager].timeLineCount < 60) {
                badgeString = [NSString stringWithFormat:@"%zd", [SANotificationManager sharedManager].timeLineCount];
            }
            UITabBarItem *mentionItem = [self.tabBar.items objectAtIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                mentionItem.badgeValue = badgeString;
            });
        }
    } else if ([keyPath isEqualToString:@"mentionCount"]) {
        if ([SANotificationManager sharedManager].mentionCount) {
            NSString *badgeString = [NSString stringWithFormat:@"%zd", [SANotificationManager sharedManager].mentionCount];
            UITabBarItem *mentionItem = [self.tabBar.items objectAtIndex:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                mentionItem.badgeValue = badgeString;
            });
        }
    } else if ([keyPath isEqualToString:@"messageCount"]) {
        if ([SANotificationManager sharedManager].messageCount) {
            NSString *badgeString = [NSString stringWithFormat:@"%zd", [SANotificationManager sharedManager].messageCount];
            UITabBarItem *messageItem = [self.tabBar.items objectAtIndex:2];
            dispatch_async(dispatch_get_main_queue(), ^{
                messageItem.badgeValue = badgeString;
            });
        }
    }
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    self.navigationItem.title = item.title;
    item.badgeValue = nil;
}

#pragma mark - EventHandler

- (IBAction)accountButtonTouchUp:(id)sender
{
    NSUInteger length = self.navigationController.viewControllers.count;
    id viewController = [self.navigationController.viewControllers objectAtIndex:length - 2];
    if (![viewController isKindOfClass:[SAUserListViewController class]]) {
        NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
        SAUserListViewController *userListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SAUserListViewController"];
        [viewControllers insertObject:userListViewController atIndex:length - 1];
        self.navigationController.viewControllers = viewControllers;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
