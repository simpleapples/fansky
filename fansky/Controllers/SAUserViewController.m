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
#import "SAFavoriteTimeLineViewController.h"
#import "SAComposeViewController.h"
#import "SAUserInfoViewController.h"
#import "SAPresentationAnimator.h"
#import "SADismissAnimator.h"
#import "UIColor+Utils.h"
#import "ARSegmentView.h"

@interface SAUserViewController () <SAUserHeaderViewDelegate, UIViewControllerTransitioningDelegate>

@end

@implementation SAUserViewController

- (void)viewDidLoad
{
    if (!self.userID) {
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        self.userID = currentUser.userID;
    }
    
    [self updateController];
    
    [super viewDidLoad];
}

- (void)updateController
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
            SAUser *user = [[SADataManager sharedManager] insertOrUpdateUserWithObject:data local:NO active:NO token:nil secret:nil];
            self.title = user.name;
            self.userID = user.userID;
            [self updateInterface];
            ARSegmentView *segmentView = [self valueForKey:@"segmentView"];
            [super performSelector:@selector(segmentControlDidChangedValue:) withObject:segmentView.segmentControl];
        } failure:nil];
    }
    
    [self updateInterface];
}

- (void)updateInterface
{
    ARSegmentView *segmentView = [self valueForKey:@"segmentView"];
    segmentView.segmentControl.tintColor = [UIColor fanskyBlue];
    
    self.headerHeight = 200;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SAMain" bundle:[NSBundle mainBundle]];
    SATimeLineViewController *timeLineViewController = [storyboard instantiateViewControllerWithIdentifier:@"SATimeLineViewController"];
    timeLineViewController.userID = self.userID;
    
    SAPhotoTimeLineViewController *photoTimeLineViewController = [storyboard instantiateViewControllerWithIdentifier:@"SAPhotoTimeLineViewController"];
    photoTimeLineViewController.userID = self.userID;
    
    SAFavoriteTimeLineViewController *favoriteTimeLineViewController = [storyboard instantiateViewControllerWithIdentifier:@"SAFavoriteTimeLineViewController"];
    favoriteTimeLineViewController.userID = self.userID;
    
    [self setViewControllers:@[timeLineViewController, photoTimeLineViewController, favoriteTimeLineViewController]];
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
    NSString *userID = self.userID;
    if (!userID) {
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        userID = currentUser.userID;
    }
    if ([segue.destinationViewController isKindOfClass:[SAFriendListViewController class]]) {
        NSNumber *senderValue = (NSNumber *)sender;
        SAFriendListViewController *friendListViewController = (SAFriendListViewController *)segue.destinationViewController;
        friendListViewController.userID = userID;
        friendListViewController.type = senderValue.integerValue;
    } else if ([segue.destinationViewController isKindOfClass:[SAUserInfoViewController class]]) {
        SAUserInfoViewController *userInfoViewController = (SAUserInfoViewController *)segue.destinationViewController;
        userInfoViewController.userID = userID;
        userInfoViewController.providesPresentationContextTransitionStyle = YES;
        userInfoViewController.definesPresentationContext = YES;
        userInfoViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        userInfoViewController.transitioningDelegate = self;
    } else if ([segue.destinationViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        if ([navigationController.viewControllers.firstObject isKindOfClass:[SAComposeViewController class]]) {
            SAComposeViewController *composeViewController = (SAComposeViewController *)navigationController.viewControllers.firstObject;
            composeViewController.userID = userID;
        }
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

- (void)userHeaderView:(SAUserHeaderView *)userHeaderView userInfoButtonTouchUp:(id)sender
{
    [self performSegueWithIdentifier:@"UserToUserInfoSegue" sender:nil];
}

- (void)userHeaderView:(SAUserHeaderView *)userHeaderView modifyInfoButtonTouchUp:(id)sender
{
    [self performSegueWithIdentifier:@"UserToModifyInfoSegue" sender:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - Transition

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    return [SAPresentationAnimator new];
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [SADismissAnimator new];
}

@end
