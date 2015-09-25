//
//  SAFriendCell.m
//  fansky
//
//  Created by Zzy on 9/25/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAFriendCell.h"
#import "SAUser+CoreDataProperties.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAFriendCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (strong, nonatomic) SAUser *user;

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
    self.userIDLabel.text = nil;
    [self.avatarImageView setImage:nil];
}

- (void)configWithUser:(SAUser *)user
{
    self.user = user;
    [self updateInterface];
}

- (void)updateInterface
{
    self.nameLabel.text = self.user.name;
    self.userIDLabel.text = [NSString stringWithFormat:@"@%@", self.user.userID];
}

- (void)loadImage
{
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.user.profileImageURL]];
}

#pragma mark - EventHandler

- (IBAction)followButtonTouchUp:(id)sender
{
}

@end
