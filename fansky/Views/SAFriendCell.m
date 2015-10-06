//
//  SAFriendCell.m
//  fansky
//
//  Created by Zzy on 9/25/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAFriendCell.h"
#import "SAFriend.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAFriendCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendIDLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (strong, nonatomic) SAFriend *friend;

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

- (void)configWithFriend:(SAFriend *)friend
{
    self.friend = friend;
    [self updateInterface];
}

- (void)updateInterface
{
    self.nameLabel.text = self.friend.name;
    self.friendIDLabel.text = [NSString stringWithFormat:@"@%@", self.friend.friendID];
}

- (void)loadImage
{
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.friend.profileImageURL]];
}

#pragma mark - EventHandler

- (IBAction)followButtonTouchUp:(id)sender
{
}

@end
