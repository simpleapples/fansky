//
//  SATabBarViewController.m
//  fansky
//
//  Created by Zzy on 9/14/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SATabBarViewController.h"

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

@end
