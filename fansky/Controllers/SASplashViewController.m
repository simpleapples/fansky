//
//  SASplashViewController.m
//  fansky
//
//  Created by Zzy on 9/10/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SASplashViewController.h"
#import "SAConstants.h"

@interface SASplashViewController ()

@end

@implementation SASplashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"SplashToUserListSegue" sender:nil];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
