
//
//  TimeLineViewController.m
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SATimeLineViewController.h"
#import "AFXAuthClient.h"

@interface SATimeLineViewController ()

@end

@implementation SATimeLineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *baseURL = [NSURL URLWithString:@"http://fanfou.com"];
    AFXAuthClient *authClient = [[AFXAuthClient alloc] initWithBaseURL:baseURL key:@"f1a7f5a8dc2faa0342bb8121de2f9b07" secret:@"f1a7f5a8dc2faa0342bb8121de2f9b07"];
    [authClient authorizeUsingXAuthWithAccessTokenPath:@"/oauth/access_token" accessMethod:@"POST" username:@"zangzhiya@gmail.com" password:@"zzy568403" success:^(AFXAuthToken *accessToken) {
    } failure:^(NSError *error) {
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
