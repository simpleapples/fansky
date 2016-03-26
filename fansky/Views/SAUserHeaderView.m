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
#import "UIColor+Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAUserHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UIButton *followersCountButton;
@property (weak, nonatomic) IBOutlet UIButton *friendsCountButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *statusCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;
@property (weak, nonatomic) IBOutlet UIButton *userInfoButton;

@property (strong, nonatomic) SAUser *user;
@property (nonatomic, getter = isMineInfo) BOOL mineInfo;

@end

@implementation SAUserHeaderView

- (void)awakeFromNib
{
    self.followButton.layer.borderColor = [UIColor fanskyBlue].CGColor;
}

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
        self.user = [[SADataManager sharedManager] insertOrUpdateUserWithObject:data local:NO active:NO token:nil secret:nil];
        [self updateInterface];
    } failure:nil];
}

- (void)updateInterface
{
    self.avatarImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    if (self.user.desc.length) {
        self.userInfoButton.hidden = NO;
    } else {
        self.userInfoButton.hidden = YES;
    }
    [self.followButton.layer setRasterizationScale:[UIScreen mainScreen].scale];
    self.nameLabel.text = self.user.name;
    self.userIDLabel.text = [NSString stringWithFormat:@"@%@", self.user.userID];

    NSDictionary *boldDictionay = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14], NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    NSDictionary *normalDictionay = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:12], NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    
    NSString *friendsCountString = [NSString stringWithFormat:@"%@", self.user.friendsCount];
    NSMutableAttributedString *friendsString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@关注", friendsCountString] attributes:boldDictionay];
    [friendsString setAttributes:normalDictionay range:NSMakeRange(friendsCountString.length, 2)];
    [self.friendsCountButton setAttributedTitle:friendsString forState:UIControlStateNormal];
    
    NSString *followersCountString = [NSString stringWithFormat:@"%@", self.user.followersCount];
    NSMutableAttributedString *followersString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@关注者", followersCountString] attributes:boldDictionay];
    [followersString setAttributes:normalDictionay range:NSMakeRange(followersCountString.length, 3)];
    [self.followersCountButton setAttributedTitle:followersString forState:UIControlStateNormal];
    
    NSString *statusCountString = [NSString stringWithFormat:@"%@", self.user.statusCount];
    NSMutableAttributedString *statusString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@消息", statusCountString] attributes:boldDictionay];
    [statusString setAttributes:normalDictionay range:NSMakeRange(statusCountString.length, 2)];
    self.statusCountLabel.attributedText = statusString;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.user.profileImageURL] placeholderImage:[UIImage imageNamed:@"BackgroundAvatar"] options:SDWebImageRefreshCached];
    if (self.isMineInfo) {
        self.followButton.hidden = YES;
        self.settingButton.hidden = NO;
    } else {
        self.followButton.hidden = NO;
        self.settingButton.hidden = YES;
    }
    if ([self.user.isProtected isEqualToNumber:@(YES)]) {
        self.lockImageView.hidden = NO;
    } else {
        self.lockImageView.hidden = YES;
    }
    if ([self.user.isFollowing isEqualToNumber:@(NO)]) {
        self.followButton.titleLabel.text = @"+关注";
        [self.followButton setTitle:@"+关注" forState:UIControlStateNormal];
    } else {
        self.followButton.titleLabel.text = @"取消关注";
        [self.followButton setTitle:@"取消关注" forState:UIControlStateNormal];
    }
}

#pragma mark - EventHandler

- (IBAction)followButtonTouchUp:(id)sender
{
    if ([self.user.isFollowing isEqualToNumber:@(NO)]) {
        [[SAAPIService sharedSingleton] followUserWithID:self.user.userID success:^(id data) {
            [SAMessageDisplayUtils showSuccessWithMessage:@"关注成功"];
            self.user.isFollowing = @(YES);
            [self updateInterface];
        } failure:^(NSString *error) {
            [SAMessageDisplayUtils showInfoWithMessage:error];
        }];
    } else {
        [[SAAPIService sharedSingleton] unfollowUserWithID:self.user.userID success:^(id data) {
            [SAMessageDisplayUtils showSuccessWithMessage:@"取消关注成功"];
            self.user.isFollowing = @(NO);
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

- (IBAction)userInfoButtonTouchUp:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(userHeaderView:userInfoButtonTouchUp:)]) {
        [self.delegate userHeaderView:self userInfoButtonTouchUp:sender];
    }
}

@end
