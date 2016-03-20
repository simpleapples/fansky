//
//  SAConversationCell.h
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAUser;
@class SAConversation;
@class SAConversationCell;

@protocol SAConversationCellDelegate <NSObject>

- (void)conversationCell:(SAConversationCell *)conversationCell avatarImageViewTouchUp:(id)sender;

@end

@interface SAConversationCell : UITableViewCell

@property (weak, nonatomic) id<SAConversationCellDelegate> delegate;
@property (strong, nonatomic) SAUser *otherUser;

- (void)configWithMessage:(SAConversation *)conversation;
- (void)loadImage;

@end
