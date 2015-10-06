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
#import "SAAPIService.h"
#import "SAFriendListViewController.h"
#import <ARSegmentPager/ARSegmentControllerDelegate.h>
#import <ARSegmentPager/ARSegmentView.h>

@interface SAUserViewController () <SAUserHeaderViewDelegate>

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
    if (user) {
        if ([currentUser.userID isEqualToString:user.userID]) {
            self.title = @"我";
        } else {
            self.title = user.name;
        }
    } else {
        [[SAAPIService sharedSingleton] userWithID:self.userID success:^(id data) {
            SAUser *user = [[SADataManager sharedManager] insertOrUpdateUserWithExtendObject:data];
            self.title = user.name;
        } failure:^(NSString *error) {
            
        }];
    }
    
    ARSegmentView *segmentView = [self valueForKey:@"segmentView"];
    segmentView.segmentControl.tintColor = [UIColor colorWithRed:85 / 255.0 green:172 / 255.0 blue:238 / 255.0 alpha:1];
    
    self.headerHeight = 195;
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
    userHeaderView.delegate = self;
    [userHeaderView configWithUserID:self.userID];
    return userHeaderView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SAFriendListViewController class]]) {
        NSString *userID = self.userID;
        if (!userID) {
            SAUser *currentUser = [SADataManager sharedManager].currentUser;
            userID = currentUser.userID;
        }
        NSNumber *senderValue = (NSNumber *)sender;
        SAFriendListViewController *friendListViewController = (SAFriendListViewController *)segue.destinationViewController;
        friendListViewController.userID = userID;
        friendListViewController.type = senderValue.integerValue;
    }
}

#pragma mark - SAUserHeaderViewDelegate

- (void)userHeaderView:(SAUserHeaderView *)userHeaderView settingButtonTouchUp:(id)sender
{
    [self performSegueWithIdentifier:@"UserToSettingNavigationSegue" sender:nil];
}

- (void)userHeaderView:(SAUserHeaderView *)userHeaderView friendsCountButtonTouchUp:(id)sender
{
    [self performSegueWithIdentifier:@"UserToFriendListSegue" sender:@(SAFriendListTypeFriend)];
}

- (void)userHeaderView:(SAUserHeaderView *)userHeaderView followersCountButtonTouchUp:(id)sender
{
    [self performSegueWithIdentifier:@"UserToFriendListSegue" sender:@(SAFriendListTypeFollow)];
}

- (void)userHeaderView:(SAUserHeaderView *)userHeaderView detailButtonTouchUp:(id)sender
{
    
}

@end
