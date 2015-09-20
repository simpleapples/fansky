//
//  SAMessageCell.m
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAMessageCell.h"
#import "SAMessage+CoreDataProperties.h"
#import "SAUser+CoreDataProperties.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAMessageCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@property (strong, nonatomic) SAMessage *message;

@end

@implementation SAMessageCell

- (void)configWithMessage:(SAMessage *)message
{
    self.message = message;
    [self updateInterface];
}

- (void)updateInterface
{
    self.nameLabel.text = self.message.sender.name;
    self.userIDLabel.text = self.message.sender.userID;
}

- (void)loadImage
{
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.message.sender.profileImageURL]];
}

@end
