//
//  SAUserViewController.m
//  fansky
//
//  Created by Zzy on 9/15/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAUserViewController.h"
#import "SATimeLineViewController.h"
#import "SAUserHeaderView.h"
#import "SADataManager+User.h"
#import "SAUser+CoreDataProperties.h"
#import "SAPhotoTimeLineViewController.h"
#import <ARSegmentPager/ARSegmentControllerDelegate.h>
#import <ARSegmentPager/ARSegmentView.h>

@interface SAUserViewController ()

@end

@implementation SAUserViewController

- (void)viewDidLoad
{
    if (!self.userID) {
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        self.userID = currentUser.userID;
    }
    
    [self updateInterface];

    [super viewDidLoad];
}

- (void)updateInterface
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    SAUser *user = [[SADataManager sharedManager] userWithID:self.userID];
    if ([currentUser.userID isEqualToString:user.userID]) {
        self.title = @"我";
    } else {
        self.title = user.name;
    }
    
    ARSegmentView *segmentView = [self valueForKey:@"segmentView"];
    segmentView.segmentControl.tintColor = [UIColor colorWithRed:85 / 255.0 green:172 / 255.0 blue:238 / 255.0 alpha:1];
    
    self.headerHeight = 190;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SAMain" bundle:[NSBundle mainBundle]];
    SATimeLineViewController *timeLineViewController = [storyboard instantiateViewControllerWithIdentifier:@"SATimeLineViewController"];
    timeLineViewController.userID = self.userID;
    SAPhotoTimeLineViewController *photoTimeLineViewController = [storyboard instantiateViewControllerWithIdentifier:@"SAPhotoTimeLineViewController"];
    photoTimeLineViewController.userID = self.userID;
    [self setViewControllers:@[timeLineViewController, photoTimeLineViewController]];
}

- (UIView<ARSegmentPageControllerHeaderProtocol> *)customHeaderView
{
    SAUserHeaderView *userHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"SAUserHeaderView" owner:nil options:nil] lastObject];
    [userHeaderView configWithUserID:self.userID];
    return userHeaderView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
