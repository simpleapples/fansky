//
//  SAConversationCell.m
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAConversationCell.h"
#import "SADataManager+User.h"
#import "SAUser.h"
#import "SAConversation.h"
#import "SAMessage.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAConversationCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@property (strong, nonatomic) SAConversation *conversation;

@end

@implementation SAConversationCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.nameLabel.text = nil;
    self.userIDLabel.text = nil;
    [self.avatarImageView setImage:nil];
}

- (void)configWithMessage:(SAConversation *)conversation
{
    self.conversation = conversation;
    if ([self.conversation.otherUserID isEqualToString:self.conversation.message.sender.userID]) {
        self.otherUser = self.conversation.message.sender;
    } else {
        self.otherUser = self.conversation.message.recipient;
    }
    [self updateInterface];
}

- (void)updateInterface
{
    self.avatarImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    self.nameLabel.text = self.otherUser.name;
    self.userIDLabel.text = [NSString stringWithFormat:@"@%@", self.otherUser.userID];
}

- (void)loadImage
{
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.otherUser.profileImageURL] placeholderImage:[UIImage imageNamed:@"BackgroundAvatar"] options:SDWebImageRefreshCached];
}

#pragma mark - EventHandler

- (IBAction)avatarImageTouchUp:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(conversationCell:avatarImageViewTouchUp:)]) {
        [self.delegate conversationCell:self avatarImageViewTouchUp:sender];
    }
}

@end
