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
@class RLMResults;

@interface SADataManager (Conversation)

- (void)insertOrUpdateConversationWithObjects:(id)objects;
- (SAConversation *)insertOrUpdateConversationWithObject:(id)object localUser:(SAUser *)localUser;
- (RLMResults *)currentConversationListWithUserID:(NSString *)userID;

@end
