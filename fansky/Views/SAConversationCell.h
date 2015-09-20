//
//  SAConversationCell.h
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAConversation;

@interface SAConversationCell : UITableViewCell

- (void)configWithMessage:(SAConversation *)conversation;
- (void)loadImage;

@end
