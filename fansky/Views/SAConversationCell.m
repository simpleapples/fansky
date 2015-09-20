//
//  SAConversationCell.m
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAConversationCell.h"
#import "SADataManager+User.h"
#import "SAUser+CoreDataProperties.h"
#import "SAConversation+CoreDataProperties.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAConversationCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@property (strong, nonatomic) SAConversation *conversation;
@property (strong, nonatomic) SAUser *otherUser;

@end

@implementation SAConversationCell

- (void)configWithMessage:(SAConversation *)conversation
{
    self.conversation = conversation;
    [self updateInterface];
}

- (void)updateInterface
{
    self.otherUser = [[SADataManager sharedManager] userWithID:self.conversation.otherUserID];
    self.nameLabel.text = self.otherUser.name;
    self.userIDLabel.text = [NSString stringWithFormat:@"@%@", self.otherUser.userID];
}

- (void)loadImage
{
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.otherUser.profileImageURL]];
}

@end
