//
//  SAUserHeaderView.m
//  fansky
//
//  Created by Zzy on 9/15/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAUserHeaderView.h"
#import "SAUser+CoreDataProperties.h"
#import "SADataManager+User.h"
#import "SAAPIService.h"
#import "SAMessageDisplayUtils.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAUserHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UIButton *followersCountButton;
@property (weak, nonatomic) IBOutlet UIButton *friendsCountButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *modifyInfoButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;

@property (strong, nonatomic) SAUser *user;
@property (nonatomic, getter = isMineInfo) BOOL mineInfo;

@end

@implementation SAUserHeaderView

- (void)configWithUserID:(NSString *)userID
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    if (!userID) {
        self.user = currentUser;
    } else {
        self.user = [[SADataManager sharedManager] userWithID:userID];
    }
    if ([currentUser.userID isEqualToString:self.user.userID]) {
        self.mineInfo = YES;
    } else {
        self.mineInfo = NO;
    }
    if (self.user) {
        [self updateInterface];
    }
    [[SAAPIService sharedSingleton] userWithID:userID success:^(id data) {
        self.user = [[SADataManager sharedManager] insertOrUpdateUserWithExtendObject:data];
        [self updateInterface];
    } failure:^(NSString *error) {
        
    }];
}

- (void)updateInterface
{
    self.nameLabel.text = self.user.name;
    self.userIDLabel.text = [NSString stringWithFormat:@"@%@", self.user.userID];
    [self.friendsCountButton setTitle:[NSString stringWithFormat:@"%@ 关注", self.user.friendsCount] forState:UIControlStateNormal];
    [self.followersCountButton setTitle:[NSString stringWithFormat:@"%@ 关注我", self.user.followersCount] forState:UIControlStateNormal];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.user.profileImageURL]];
    if (self.isMineInfo) {
        self.followButton.hidden = YES;
        self.modifyInfoButton.hidden = NO;
        self.settingButton.hidden = NO;
    } else {
        self.followButton.hidden = NO;
        self.modifyInfoButton.hidden = YES;
        self.settingButton.hidden = YES;
    }
    if ([self.user.protected isEqualToNumber:@(YES)]) {
        self.lockImageView.hidden = NO;
    } else {
        self.lockImageView.hidden = YES;
    }
    if ([self.user.following isEqualToNumber:@(NO)]) {
        [self.followButton setTitle:@"+关注" forState:UIControlStateNormal];
    } else {
        [self.followButton setTitle:@"取消关注" forState:UIControlStateNormal];
    }
}

- (IBAction)followButtonTouchUp:(id)sender
{
    if ([self.user.following isEqualToNumber:@(NO)]) {
        [[SAAPIService sharedSingleton] followUserWithID:self.user.userID success:^(id data) {
            [SAMessageDisplayUtils showSuccessWithMessage:@"关注成功"];
            self.user.following = @(YES);
            [self updateInterface];
        } failure:^(NSString *error) {
            [SAMessageDisplayUtils showErrorWithMessage:error];
        }];
    } else {
        [[SAAPIService sharedSingleton] unfollowUserWithID:self.user.userID success:^(id data) {
            [SAMessageDisplayUtils showSuccessWithMessage:@"取消关注成功"];
            self.user.following = @(NO);
            [self updateInterface];
        } failure:^(NSString *error) {
            [SAMessageDisplayUtils showErrorWithMessage:error];
        }];
    }
}

- (IBAction)modifyInfoButtonTouchUp:(id)sender
{
}

- (IBAction)settingButtonTouchUp:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(userHeaderView:settingButtonTouchUp:)]) {
        [self.delegate userHeaderView:self settingButtonTouchUp:sender];
    }
}

- (IBAction)friendsCountButtonTouchUp:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(userHeaderView:friendsCountButtonTouchUp:)]) {
        [self.delegate userHeaderView:self friendsCountButtonTouchUp:sender];
    }
}

- (IBAction)followersCountButtonTouchUp:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(userHeaderView:followersCountButtonTouchUp:)]) {
        [self.delegate userHeaderView:self followersCountButtonTouchUp:sender];
    }
}

- (IBAction)detailButtonTouchUp:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(userHeaderView:detailButtonTouchUp:)]) {
        [self.delegate userHeaderView:self detailButtonTouchUp:sender];
    }
}

@end
