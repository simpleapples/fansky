//
//  SASplashViewController.m
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SASplashViewController.h"
#import "SAUserManager.h"

@implementation SASplashViewController

- (void)viewDidLoad
{
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self performSegueWithIdentifier:@"SplashToLoginNavigationSegue" sender:nil];
}

- (IBAction)exitToSplash:(UIStoryboardSegue *)segue
{
    
}

@end
