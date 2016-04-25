//
//  SADataManager+Message.m
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SADataManager+Message.h"
#import "SAMessage+CoreDataProperties.h"
#import "SADataManager+User.h"
#import "NSString+Utils.h"

@implementation SADataManager (Message)

static NSString *const ENTITY_NAME = @"SAMessage";

- (void)insertOrUpdateMessagesWithObjects:(id)objects
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    
    NSMutableDictionary *messageIDDictionary = [NSMutableDictionary new];
    [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *messageID = [obj objectForKey:@"id"];
        [messageIDDictionary setValue:obj forKey:messageID];
    }];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"messageID IN %@", [messageIDDictionary allKeys]];
    
    __block NSError *error;
    [self.managedObjectContext performBlockAndWait:^{
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchResult) {
            [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                SAMessage *existMessage = (SAMessage *)obj;
                [messageIDDictionary removeObjectForKey:existMessage.messageID];
            }];
        }
    }];
    
    [messageIDDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self insertMessageWithObject:obj localUser:currentUser];
    }];
}

- (SAMessage *)insertOrUpdateMessageWithObject:(id)object localUser:(SAUser *)localUser
{
    NSString *messageID = [object objectForKey:@"id"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"messageID = %@", messageID];
        
    __block NSError *error;
    __block SAMessage *resultMessage;
    [self.managedObjectContext performBlockAndWait:^{
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchResult && fetchResult.count) {
            SAMessage *existMessage = [fetchResult firstObject];
            if (![existMessage.localUsers containsObject:localUser]) {
                [existMessage addLocalUsersObject:localUser];
            }
            resultMessage = existMessage;
        } else {
            resultMessage = [self insertMessageWithObject:object localUser:localUser];
        }
    }];
    return resultMessage;
}

- (SAMessage *)insertMessageWithObject:(id)object localUser:(SAUser *)localUser
{
    NSString *messageID = [object objectForKey:@"id"];
    NSString *text = [object objectForKey:@"text"];
    NSString *senderID = [object objectForKey:@"sender_id"];
    NSString *recipientID = [object objectForKey:@"recipient_id"];
    NSString *createdAtString = [object objectForKey:@"created_at"];
    NSDate *createdAt = [createdAtString dateWithDefaultFormat];
    
    SAUser *sender = [[SADataManager sharedManager] insertOrUpdateUserWithObject:[object objectForKey:@"sender"] local:NO active:NO token:nil secret:nil];
    SAUser *recipient = [[SADataManager sharedManager] insertOrUpdateUserWithObject:[object objectForKey:@"recipient"] local:NO active:NO token:nil secret:nil];
        
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"messageID = %@", messageID];
    
    __block SAMessage *resultMessage;
    [self.managedObjectContext performBlockAndWait:^{
        SAMessage *message = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
        message.messageID = messageID;
        message.text = text;
        message.senderID = senderID;
        message.recipientID = recipientID;
        message.createdAt = createdAt;
        message.sender = sender;
        message.recipient = recipient;
        if (![message.localUsers containsObject:localUser]) {
            [message addLocalUsersObject:localUser];
        }
        resultMessage = message;
    }];
    return resultMessage;
}

- (NSArray *)currentMessageWithUserID:(NSString *)userID localUserID:(NSString *)localUserID limit:(NSUInteger)limit
{
    NSSortDescriptor *createdAtSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSArray *sortArray = [[NSArray alloc] initWithObjects: createdAtSortDescriptor, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"localUsers.userID CONTAINS %@ AND (sender.userID = %@ OR recipient.userID = %@)", localUserID, userID, userID];
    fetchRequest.sortDescriptors = sortArray;
    fetchRequest.returnsObjectsAsFaults = NO;
    fetchRequest.fetchBatchSize = 6;
    fetchRequest.fetchLimit = limit;
    
    __block NSError *error;
    __block NSArray *resultArray = [[NSArray alloc] init];
    [self.managedObjectContext performBlockAndWait:^{
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchResult && fetchResult.count) {
            resultArray = [[fetchResult reverseObjectEnumerator] allObjects];
        }
    }];
    return resultArray;
}

@end
