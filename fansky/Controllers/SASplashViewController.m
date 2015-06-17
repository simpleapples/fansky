//
//  SASplashViewController.m
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SASplashViewController.h"

@implementation SASplashViewController

- (void)viewDidLoad
{
    [self performSegueWithIdentifier:@"SplashToLoginNavigationSegue" sender:nil];
}

@end
