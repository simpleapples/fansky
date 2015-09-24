//
//  SADataManager+Status.m
//  fansky
//
//  Created by Zzy on 9/12/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SADataManager+Status.h"
#import "SADataManager+Photo.h"
#import "SADataManager+User.h"
#import "NSString+Utils.h"

@implementation SADataManager (Status)

static NSString *const ENTITY_NAME = @"SAStatus";

- (void)insertOrUpdateStatusWithObjects:(NSArray *)objects type:(SAStatusTypes)type
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    
    NSMutableDictionary *statusIDDictionary = [NSMutableDictionary new];
    [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *statusID = [obj objectForKey:@"id"];
        [statusIDDictionary setValue:obj forKey:statusID];
    }];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"statusID IN %@", [statusIDDictionary allKeys]];
    
    __block NSError *error;
    [self.managedObjectContext performBlockAndWait:^{
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchResult) {
            [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                SAStatus *existStatus = (SAStatus *)obj;
                id statusObject = [statusIDDictionary objectForKey:existStatus.statusID];
                [self updateStatusWithObject:statusObject status:existStatus type:type];
                [statusIDDictionary removeObjectForKey:existStatus.statusID];
            }];
        }
    }];
    
    [statusIDDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self insertStatusWithObject:obj localUser:currentUser type:type];
    }];
}

- (SAStatus *)insertOrUpdateStatusWithObject:(id)object localUser:(SAUser *)localUser type:(SAStatusTypes)type
{
    NSString *statusID = [object objectForKey:@"id"];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"statusID = %@", statusID];
    
    __block NSError *error;
    __block SAStatus *resultStatus;
    [self.managedObjectContext performBlockAndWait:^{
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchResult && fetchResult.count) {
            SAStatus *existStatus = [fetchResult firstObject];
            resultStatus = [self updateStatusWithObject:object status:existStatus type:type];
        } else {
            resultStatus = [self insertStatusWithObject:object localUser:localUser type:type];
        }
    }];
    return resultStatus;
}

- (NSArray *)currentTimeLineWithUserID:(NSString *)userID type:(SAStatusTypes)type limit:(NSUInteger)limit
{
    NSSortDescriptor *createdAtSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSArray *sortArray = [[NSArray alloc] initWithObjects: createdAtSortDescriptor, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    if (type == SAStatusTypeTimeLine) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"localUser.userID = %@ AND (type | %d) = type", userID, type];
    } else {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user.userID = %@ AND (type | %d) = type", userID, type];
    }
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

- (NSArray *)currentMentionTimeLineWithUserID:(NSString *)userID limit:(NSUInteger)limit
{
    NSSortDescriptor *createdAtSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSArray *sortArray = [[NSArray alloc] initWithObjects: createdAtSortDescriptor, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"localUser.userID = %@ AND (type | %d) = type", userID, SAStatusTypeMentionStatus];
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

- (NSArray *)currentPhotoTimeLineWithUserID:(NSString *)userID limit:(NSUInteger)limit
{
    NSSortDescriptor *createdAtSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSArray *sortArray = [[NSArray alloc] initWithObjects: createdAtSortDescriptor, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user.userID = %@ AND photo.imageURL != nil AND repostStatusID = nil", userID];
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

- (SAStatus *)insertStatusWithObject:(id)object localUser:(SAUser *)localUser type:(SAStatusTypes)type
{
    NSString *statusID = [object objectForKey:@"id"];
    NSString *source = [object objectForKey:@"source"];
    NSString *text = [object objectForKey:@"text"];
    NSString *createdAtString = [object objectForKey:@"created_at"];
    NSString *repostStatusID = [object objectForKey:@"repost_status_id"];
    NSDate *createdAt = [createdAtString dateWithDefaultFormat];
    
    SAPhoto *photo = [[SADataManager sharedManager] insertPhotoWithObject:[object objectForKey:@"photo"]];
    SAUser *user = [[SADataManager sharedManager] insertOrUpdateUserWithObject:[object objectForKey:@"user"] local:NO active:NO token:nil secret:nil];
    
    __block SAStatus *resultStatus;
    [self.managedObjectContext performBlockAndWait:^{
        SAStatus *status = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
        status.statusID = statusID;
        status.source = source;
        status.text = text;
        status.photo = photo;
        status.user = user;
        status.repostStatusID = repostStatusID;
        status.createdAt = createdAt;
        status.localUser = localUser;
        status.type = @(type | status.type.integerValue);
        resultStatus = status;
    }];
    return resultStatus;
}

- (SAStatus *)updateStatusWithObject:(id)object status:(SAStatus *)status type:(SAStatusTypes)type
{
    status.type = @(type | status.type.integerValue);
    return status;
}

- (SAStatus *)statusWithID:(NSString *)statusID
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"statusID = %@", statusID];
    
    __block NSError *error;
    __block SAStatus *resultStatus;
    [self.managedObjectContext performBlockAndWait:^{
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchResult && fetchResult.count) {
            SAStatus *existStatus = [fetchResult firstObject];
            resultStatus = existStatus;
        }
    }];
    return resultStatus;
}

@end
