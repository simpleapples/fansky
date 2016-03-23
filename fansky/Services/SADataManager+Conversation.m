//
//  SADataManager+Conversation.m
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SADataManager+Conversation.h"
#import "SADataManager+User.h"
#import "SAUser.h"
#import "SADataManager+Message.h"
#import "SAConversation.h"

@implementation SADataManager (Conversation)

- (void)insertOrUpdateConversationWithObjects:(id)objects
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    [objects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        [self insertOrUpdateConversationWithObject:object localUser:currentUser];
    }];
}

- (SAConversation *)insertOrUpdateConversationWithObject:(id)object localUser:(SAUser *)localUser
{
    NSString *otherUserID = [object objectForKey:@"otherid"];
    NSNumber *messageCount = [object objectForKey:@"msg_num"];
    NSNumber *isNew = [object objectForKey:@"new_conv"];
    
    SAMessage *message = [[SADataManager sharedManager] insertOrUpdateMessageWithObject:[object objectForKey:@"dm"] localUser:localUser];
    
    SAConversation *conversation = [[SAConversation alloc] init];
    conversation.otherUserID = otherUserID;
    conversation.messageCount = messageCount.intValue;
    conversation.isNew = isNew.boolValue;
    conversation.message = message;
    conversation.localUser = localUser;
    
    [self.defaultRealm beginWriteTransaction];
    SAConversation *resultConversation = [SAConversation createOrUpdateInRealm:self.defaultRealm withValue:conversation];
    [self.defaultRealm commitWriteTransaction];
    return resultConversation;
}

- (RLMResults *)currentConversationListWithUserID:(NSString *)userID
{
    RLMResults *results = [SAConversation objectsInRealm:self.defaultRealm where:@"localUser.userID = %@", userID];
    results = [results sortedResultsUsingProperty:@"otherUserID" ascending:NO];
    return results;
}

@end
