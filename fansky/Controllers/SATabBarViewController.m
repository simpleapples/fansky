//
//  SATabBarViewController.m
//  fansky
//
//  Created by Zzy on 9/14/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SATabBarViewController.h"
#import "SAUserListViewController.h"

@interface SATabBarViewController ()

@end

@implementation SATabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)exitToTabBar:(UIStoryboardSegue *)segue
{
    
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    self.navigationItem.title = item.title;
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
