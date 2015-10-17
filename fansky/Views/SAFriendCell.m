//
//  SAFriendCell.m
//  fansky
//
//  Created by Zzy on 9/25/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAFriendCell.h"
#import "SAFriend.h"
#import "SAAPIService.h"
#import "SAMessageDisplayUtils.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAFriendCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendIDLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (strong, nonatomic) SAFriend *friend;
@property (nonatomic) SAFriendCellType type;

@end

@implementation SAFriendCell

- (void)awakeFromNib
{

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)prepareForReuse
{
    self.nameLabel.text = nil;
    self.friendIDLabel.text = nil;
    [self.avatarImageView setImage:nil];
}

- (void)configWithFriend:(SAFriend *)friend type:(SAFriendCellType)type
{
    self.friend = friend;
    self.type = type;
    [self updateInterface];
}

- (void)updateInterface
{
    self.nameLabel.text = self.friend.name;
    self.friendIDLabel.text = [NSString stringWithFormat:@"@%@", self.friend.friendID];
    if (self.type != SAFriendCellTypeRequest) {
        self.followButton.hidden = NO;
        if ([self.friend.following isEqualToNumber:@(YES)]) {
            self.followButton.titleLabel.text = @"取消关注";
            [self.followButton setTitle:@"取消关注" forState:UIControlStateNormal];
        } else {
            self.followButton.titleLabel.text = @"+关注";
            [self.followButton setTitle:@"+关注" forState:UIControlStateNormal];
        }
    } else {
        self.followButton.hidden = YES;
    }
}

- (void)loadImage
{
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.friend.profileImageURL] placeholderImage:nil options:SDWebImageRefreshCached];
}

#pragma mark - EventHandler

- (IBAction)followButtonTouchUp:(id)sender
{
    if ([self.friend.following isEqualToNumber:@(NO)]) {
        [[SAAPIService sharedSingleton] followUserWithID:self.friend.friendID success:^(id data) {
            self.friend.following = @(YES);
            [SAMessageDisplayUtils showSuccessWithMessage:@"关注成功"];
            [self updateInterface];
        } failure:^(NSString *error) {
            [SAMessageDisplayUtils showInfoWithMessage:error];
        }];
    } else {
        [[SAAPIService sharedSingleton] unfollowUserWithID:self.friend.friendID success:^(id data) {
            self.friend.following = @(NO);
            [SAMessageDisplayUtils showSuccessWithMessage:@"取消关注成功"];
            [self updateInterface];
        } failure:^(NSString *error) {
            [SAMessageDisplayUtils showErrorWithMessage:error];
        }];
    }
}

@end
