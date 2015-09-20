//
//  SADataManager+Conversation.h
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SADataManager.h"

@class SAUser;
@class SAConversation;

@interface SADataManager (Conversation)

- (void)insertConversationWithObjects:(id)objects;
- (SAConversation *)insertConversationWithObject:(id)object localUser:(SAUser *)localUser;

@end
