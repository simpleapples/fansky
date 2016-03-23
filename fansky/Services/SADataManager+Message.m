//
//  SADataManager+Message.m
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SADataManager+Message.h"
#import "SAMessage.h"
#import "SADataManager+User.h"
#import "NSString+Utils.h"

@implementation SADataManager (Message)

- (void)insertOrUpdateMessageWithObjects:(id)objects
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    
    [objects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        [self insertOrUpdateMessageWithObject:object localUser:currentUser];
    }];
}

- (SAMessage *)insertOrUpdateMessageWithObject:(id)object localUser:(SAUser *)localUser
{
    NSString *messageID = [object objectForKey:@"id"];
    NSString *text = [object objectForKey:@"text"];
    NSString *createdAtString = [object objectForKey:@"created_at"];
    NSDate *createdAt = [createdAtString dateWithDefaultFormat];
    
    SAUser *sender = [[SADataManager sharedManager] insertOrUpdateUserWithObject:[object objectForKey:@"sender"] local:NO active:NO token:nil secret:nil];
    SAUser *recipient = [[SADataManager sharedManager] insertOrUpdateUserWithObject:[object objectForKey:@"recipient"] local:NO active:NO token:nil secret:nil];
        
    SAMessage *message = [[SAMessage alloc] init];
    message.messageID = messageID;
    message.text = text;
    message.sender = sender;
    message.recipient =recipient;
    message.createdAt = createdAt;
    message.localUser = localUser;
    
    [self.defaultRealm beginWriteTransaction];
    SAMessage *resultMessage = [SAMessage createOrUpdateInRealm:self.defaultRealm withValue:message];
    [self.defaultRealm commitWriteTransaction];
    return resultMessage;
}

- (RLMResults *)currentMessagesWithUserID:(NSString *)userID localUserID:(NSString *)localUserID
{
    RLMResults<SAMessage *> *results = [SAMessage objectsInRealm:self.defaultRealm where:@"localUser.userID = %@ AND (sender.userID = %@ OR recipient.userID = %@)", localUserID, userID, userID];
    results = [results sortedResultsUsingProperty:@"createdAt" ascending:NO];
    return results;
}

@end
