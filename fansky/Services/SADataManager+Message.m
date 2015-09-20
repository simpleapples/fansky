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

- (void)insertMessageWithObjects:(id)objects
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    [objects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        [self insertMessageWithObject:object localUser:currentUser];
    }];
}

- (SAMessage *)insertMessageWithObject:(id)object localUser:(SAUser *)localUser
{
    NSString *messageID = [object objectForKey:@"id"];
    NSString *text = [object objectForKey:@"text"];
    NSString *createdAtString = [object objectForKey:@"created_at"];
    NSDate *createdAt = [createdAtString dateWithDefaultFormat];
    
    SAUser *sender = [[SADataManager sharedManager] insertOrUpdateUserWithObject:[object objectForKey:@"sender"] local:NO active:NO token:nil secret:nil];
    SAUser *recipient = [[SADataManager sharedManager] insertOrUpdateUserWithObject:[object objectForKey:@"recipient"] local:NO active:NO token:nil secret:nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"messageID = %@", messageID];
    
    __block NSError *error;
    __block SAMessage *resultMessage;
    [self.managedObjectContext performBlockAndWait:^{
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchResult && fetchResult.count) {
            SAMessage *existMessage = [fetchResult firstObject];
            resultMessage = existMessage;
        } else {
            [self.managedObjectContext performBlockAndWait:^{
                SAMessage *message = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
                message.messageID = messageID;
                message.text = text;
                message.createdAt = createdAt;
                message.sender = sender;
                message.recipient = recipient;
                message.localUser = localUser;
                resultMessage = message;
            }];
        }
    }];
    return resultMessage;
}

@end
