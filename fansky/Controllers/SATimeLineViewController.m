
//
//  TimeLineViewController.m
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SATimeLineViewController.h"
#import "SADataManager+User.h"
#import "SAUser.h"
#import "SAAPIService.h"

@interface SATimeLineViewController ()

@end

@implementation SATimeLineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    [[SAAPIService sharedSingleton] timelineWithUserID:currentUser.userID sinceID:nil maxID:nil count:60 success:^(id data) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
