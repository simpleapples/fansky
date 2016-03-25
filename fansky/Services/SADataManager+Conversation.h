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

- (void)insertOrUpdateConversationsWithObjects:(id)objects;
- (SAConversation *)insertOrUpdateConversationWithObject:(id)object localUser:(SAUser *)localUser;
- (NSArray *)currentConversationListWithUserID:(NSString *)userID limit:(NSUInteger)limit;

@end
