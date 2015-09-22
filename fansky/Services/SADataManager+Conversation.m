//
//  SADataManager+Conversation.m
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SADataManager+Conversation.h"
#import "SADataManager+User.h"
#import "SAUser+CoreDataProperties.h"
#import "SADataManager+Message.h"
#import "SAConversation+CoreDataProperties.h"

@implementation SADataManager (Conversation)

static NSString *const ENTITY_NAME = @"SAConversation";

- (void)insertConversationWithObjects:(id)objects
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    [objects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        [self insertConversationWithObject:object localUser:currentUser];
    }];
}

- (SAConversation *)insertConversationWithObject:(id)object localUser:(SAUser *)localUser
{
    NSString *otherUserID = [object objectForKey:@"otherid"];
    NSNumber *count = [object objectForKey:@"msg_num"];
    NSNumber *newConversation = [object objectForKey:@"new_conv"];
    
    SAMessage *message = [[SADataManager sharedManager] insertOrUpdateMessageWithObject:[object objectForKey:@"dm"] localUser:localUser];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"otherUserID = %@", otherUserID];
    
    __block NSError *error;
    __block SAConversation *resultConversation;
    [self.managedObjectContext performBlockAndWait:^{
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchResult && fetchResult.count) {
            SAConversation *existConversation = [fetchResult firstObject];
            existConversation.otherUserID = otherUserID;
            existConversation.count = count;
            existConversation.newConversation = newConversation;
            existConversation.message = message;
            existConversation.localUser = localUser;
            resultConversation = existConversation;
        } else {
            [self.managedObjectContext performBlockAndWait:^{
                SAConversation *conversation = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
                conversation.otherUserID = otherUserID;
                conversation.count = count;
                conversation.newConversation = newConversation;
                conversation.message = message;
                conversation.localUser = localUser;
                resultConversation = conversation;
            }];
        }
    }];
    return resultConversation;
}

@end
