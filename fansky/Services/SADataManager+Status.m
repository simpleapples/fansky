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
                [self updateStatusWithObject:statusObject status:existStatus type:type localUser:currentUser];
                [statusIDDictionary removeObjectForKey:existStatus.statusID];
            }];
        }
    }];
    
    [statusIDDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self insertStatusWithObject:obj localUser:currentUser type:type];
    }];
    
    [self saveContext];
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
            resultStatus = [self updateStatusWithObject:object status:existStatus type:type localUser:localUser];
        } else {
            resultStatus = [self insertStatusWithObject:object localUser:localUser type:type];
        }
    }];
    return resultStatus;
}

- (void)currentTimeLineWithUserID:(NSString *)userID type:(SAStatusTypes)type offset:(NSUInteger)offset limit:(NSUInteger)limit completeHandler:(void (^)(NSArray *))completeHandler
{
    NSSortDescriptor *createdAtSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSArray *sortArray = [[NSArray alloc] initWithObjects: createdAtSortDescriptor, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    if (type == SAStatusTypeTimeLine) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"localUsers.userID CONTAINS %@ AND (type | %d) = type", userID, type];
    } else {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user.userID = %@ AND (type | %d) = type", userID, type];
    }
    fetchRequest.sortDescriptors = sortArray;
    fetchRequest.returnsObjectsAsFaults = NO;
    fetchRequest.fetchBatchSize = 6;
    fetchRequest.fetchOffset = offset;
    fetchRequest.fetchLimit = limit;
    
    [self.managedObjectContext performBlock:^{
        NSError *error;
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (completeHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error && fetchResult && fetchResult.count) {
                    completeHandler(fetchResult);
                } else {
                    completeHandler(nil);
                }
            });
        }
    }];
}

- (void)currentMentionTimeLineWithUserID:(NSString *)userID offset:(NSUInteger)offset limit:(NSUInteger)limit completeHandler:(void (^)(NSArray *))completeHandler
{
    NSSortDescriptor *createdAtSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSArray *sortArray = [[NSArray alloc] initWithObjects: createdAtSortDescriptor, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"localUsers.userID CONTAINS %@ AND (type | %d) = type", userID, SAStatusTypeMentionStatus];
    fetchRequest.sortDescriptors = sortArray;
    fetchRequest.returnsObjectsAsFaults = NO;
    fetchRequest.fetchBatchSize = 6;
    fetchRequest.fetchOffset = offset;
    fetchRequest.fetchLimit = limit;
    
    [self.managedObjectContext performBlock:^{
        NSError *error;
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (completeHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error && fetchResult && fetchResult.count) {
                    completeHandler(fetchResult);
                } else {
                    completeHandler(nil);
                }
            });
        }
    }];
}

- (void)currentPhotoTimeLineWithUserID:(NSString *)userID limit:(NSUInteger)limit completeHandler:(void (^)(NSArray *))completeHandler
{
    NSSortDescriptor *createdAtSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSArray *sortArray = [[NSArray alloc] initWithObjects: createdAtSortDescriptor, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user.userID = %@ AND photo.imageURL != nil AND repostStatusID = nil", userID];
    fetchRequest.sortDescriptors = sortArray;
    fetchRequest.returnsObjectsAsFaults = NO;
    fetchRequest.fetchBatchSize = 6;
    fetchRequest.fetchLimit = limit;
    
    [self.managedObjectContext performBlock:^{
        NSError *error;
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (completeHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error && fetchResult && fetchResult.count) {
                    completeHandler(fetchResult);
                } else {
                    completeHandler(nil);
                }
            });
        }
    }];
}

- (SAStatus *)statusWithObject:(id)object localUsers:(NSSet<SAUser *> *)localUsers type:(SAStatusTypes)type
{
    NSString *statusID = [object objectForKey:@"id"];
    NSString *source = [object objectForKey:@"source"];
    NSString *text = [object objectForKey:@"text"];
    NSNumber *favorited = [object objectForKey:@"favorited"];
    NSString *repostStatusID = [object objectForKey:@"repost_status_id"];
    NSString *createdAtString = [object objectForKey:@"created_at"];
    NSDate *createdAt = [createdAtString dateWithDefaultFormat];
    
    SAPhoto *photo = [[SADataManager sharedManager] photoWithObject:[object objectForKey:@"photo"]];
    SAUser *user = [[SADataManager sharedManager] userWithObject:[object objectForKey:@"user"]];
    
    SAStatus *status = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
    status.statusID = statusID;
    status.source = source;
    status.text = text;
    status.favorited = favorited;
    status.photo = photo;
    status.user = user;
    status.localUsers = localUsers;
    status.repostStatusID = repostStatusID;
    status.createdAt = createdAt;
    status.type = @(type);
    return status;
}

- (SAStatus *)insertStatusWithObject:(id)object localUser:(SAUser *)localUser type:(SAStatusTypes)type
{
    NSString *statusID = [object objectForKey:@"id"];
    NSString *source = [object objectForKey:@"source"];
    NSString *text = [object objectForKey:@"text"];
    NSNumber *favorited = [object objectForKey:@"favorited"];
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
        status.favorited = favorited;
        status.photo = photo;
        status.user = user;
        status.repostStatusID = repostStatusID;
        status.createdAt = createdAt;
        if (![status.localUsers containsObject:localUser]) {
            [status addLocalUsersObject:localUser];
        }
        status.type = @(type | status.type.integerValue);
        resultStatus = status;
    }];
    return resultStatus;
}

- (SAStatus *)updateStatusWithObject:(id)object status:(SAStatus *)status type:(SAStatusTypes)type localUser:(SAUser *)localUser
{
    NSNumber *favorited = [object objectForKey:@"favorited"];
    status.favorited = favorited;
    status.type = @(type | status.type.integerValue);
    if (![status.localUsers containsObject:localUser]) {
        [status addLocalUsersObject:localUser];
    }
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

- (void)deleteStatusWithID:(NSString *)statusID
{
    SAStatus *status = [self statusWithID:statusID];
    [self.managedObjectContext deleteObject:status];
}

@end
