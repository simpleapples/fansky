//
//  SAUserHeaderView.m
//  fansky
//
//  Created by Zzy on 9/15/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAUserHeaderView.h"
#import "SAUser.h"
#import "SADataManager+User.h"
#import "SAAPIService.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAUserHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (strong, nonatomic) SAUser *user;

@end

@implementation SAUserHeaderView

- (void)configWithUserID:(NSString *)userID
{
    if (!userID) {
        self.user = [SADataManager sharedManager].currentUser;
    } else {
        self.user = [[SADataManager sharedManager] userWithID:userID];
    }
    if (self.user) {
        [self updateInterface];
    }
    [[SAAPIService sharedSingleton] userWithID:userID success:^(id data) {
        self.user = [[SADataManager sharedManager] insertOrUpdateUserWithExtendObject:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateInterface];
        });
    } failure:^(NSString *error) {
        
    }];
}

- (void)updateInterface
{
    self.nameLabel.text = self.user.name;
    self.userIDLabel.text = [NSString stringWithFormat:@"@%@", self.user.userID];
    self.descLabel.text = [NSString stringWithFormat:@"%@关注者 %@关注", self.user.followersCount, self.user.friendsCount];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.user.profileImageURL]];
    [self.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:self.user.profileImageURL]];
    if (self.user.following) {
        [self.followButton setTitle:@"取消关注" forState:UIControlStateNormal];
        self.followButton.enabled = NO;
    } else {
        [self.followButton setTitle:@"+关注" forState:UIControlStateNormal];
        self.followButton.enabled = YES;
    }
}

- (IBAction)followButtonTouchUp:(id)sender
{
}

@end
