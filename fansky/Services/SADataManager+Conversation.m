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

- (void)insertOrUpdateConversationsWithObjects:(id)objects
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    [objects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        [self insertOrUpdateConversationWithObject:object localUser:currentUser];
    }];
}

- (SAConversation *)insertOrUpdateConversationWithObject:(id)object localUser:(SAUser *)localUser
{
    NSString *otherUserID = [object objectForKey:@"otherid"];
    NSNumber *count = [object objectForKey:@"msg_num"];
    NSNumber *isNew = [object objectForKey:@"new_conv"];
 
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
            existConversation.isNew = isNew;
            existConversation.message = message;
            existConversation.localUser = localUser;
            resultConversation = existConversation;
        } else {
            [self.managedObjectContext performBlockAndWait:^{
                SAConversation *conversation = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
                conversation.otherUserID = otherUserID;
                conversation.count = count;
                conversation.isNew = isNew;
                conversation.message = message;
                conversation.localUser = localUser;
                resultConversation = conversation;
            }];
        }
    }];
    return resultConversation;
}

- (NSArray *)currentConversationListWithUserID:(NSString *)userID limit:(NSUInteger)limit
{
    NSSortDescriptor *otherUserIDSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"otherUserID" ascending:NO];
    NSArray *sortArray = [[NSArray alloc] initWithObjects: otherUserIDSortDescriptor, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"localUser.userID = %@", userID];
    fetchRequest.sortDescriptors = sortArray;
    fetchRequest.returnsObjectsAsFaults = NO;
    fetchRequest.fetchBatchSize = 6;
    fetchRequest.fetchLimit = limit;
    
    __block NSError *error;
    __block NSArray *resultArray = [[NSArray alloc] init];
    [self.managedObjectContext performBlockAndWait:^{
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchResult && fetchResult.count) {
            resultArray = fetchResult;
        }
    }];
    return resultArray;
}

@end
