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

- (void)insertOrUpdateStatusWithObjects:(NSArray *)objects type:(SAStatusTypes)type
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    
    [objects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        [self insertOrUpdateStatusWithObject:object localUser:currentUser type:type];
    }];
}

- (void)insertOrUpdateStatusWithObject:(id)object localUser:(SAUser *)localUser type:(SAStatusTypes)type
{
    NSString *statusID = [object objectForKey:@"id"];
    NSString *source = [object objectForKey:@"source"];
    NSString *text = [object objectForKey:@"text"];
    NSNumber *isFavorited = [object objectForKey:@"favorited"];
    NSString *createdAtString = [object objectForKey:@"created_at"];
    NSString *repostStatusID = [object objectForKey:@"repost_status_id"];
    NSDate *createdAt = [createdAtString dateWithDefaultFormat];
    
    SAPhoto *photo = [[SADataManager sharedManager] insertOrUpdatePhotoWithObject:[object objectForKey:@"photo"]];
    SAUser *user = [[SADataManager sharedManager] insertOrUpdateUserWithObject:[object objectForKey:@"user"] local:NO active:NO token:nil secret:nil];
    
    SAStatus *status = [SAStatus objectForPrimaryKey:statusID];
    [self.defaultRealm beginWriteTransaction];
    if (!status) {
        status = [[SAStatus alloc] init];
        status.statusID = statusID;
        status = [SAStatus createOrUpdateInRealm:self.defaultRealm withValue:status];
    }
    status.text = text;
    status.source = source;
    status.repostStatusID = repostStatusID;
    status.isFavorited = [isFavorited boolValue];
    status.createdAt = createdAt;
    status.photo = photo;
    status.user = user;
    NSMutableString *tempTypes;
    if (status.types.length == 4) {
        tempTypes = [status.types mutableCopy];
    } else {
        tempTypes = [[NSMutableString alloc] initWithString:@"0000"];
    }
    [tempTypes replaceCharactersInRange:NSMakeRange(type - 1, 1) withString:[NSString stringWithFormat:@"%lu", type]];
    status.types = tempTypes;
    [status.localUsers addObject:localUser];
    [self.defaultRealm commitWriteTransaction];
}

- (RLMResults<SAStatus *> *)currentTimeLineWithUserID:(NSString *)userID type:(SAStatusTypes)type
{
    NSString *typeString = [NSString stringWithFormat:@"%lu", type];
    RLMResults<SAStatus *> *results = [SAStatus objectsInRealm:self.defaultRealm where:@"%@ IN localUsers.userID AND types CONTAINS %@", userID, typeString];
    results = [results sortedResultsUsingProperty:@"createdAt" ascending:NO];
    return results;
}

- (RLMResults<SAStatus *> *)currentPhotoTimeLineWithUserID:(NSString *)userID
{
    RLMResults<SAStatus *> *results = [SAStatus objectsInRealm:self.defaultRealm where:@"user.userID = %@ AND photo.imageURL != nil AND repostStatusID = nil", userID];
    results = [results sortedResultsUsingProperty:@"createdAt" ascending:NO];
    return results;
}

- (SAStatus *)statusWithObject:(id)object localUsers:(NSSet<SAUser *> *)localUsers type:(SAStatusTypes)type
{
    NSString *statusID = [object objectForKey:@"id"];
    NSString *source = [object objectForKey:@"source"];
    NSString *text = [object objectForKey:@"text"];
    NSNumber *isFavorited = [object objectForKey:@"favorited"];
    NSString *repostStatusID = [object objectForKey:@"repost_status_id"];
    NSString *createdAtString = [object objectForKey:@"created_at"];
    NSDate *createdAt = [createdAtString dateWithDefaultFormat];
    
    SAPhoto *photo = [[SADataManager sharedManager] insertOrUpdatePhotoWithObject:[object objectForKey:@"photo"]];
    SAUser *user = [[SADataManager sharedManager] insertOrUpdateUserWithObject:[object objectForKey:@"user"] local:NO active:NO token:nil secret:nil];
    
    SAStatus *status = [[SAStatus alloc] init];
    status.statusID = statusID;
    status.source = source;
    status.text = text;
    status.isFavorited = [isFavorited boolValue];
    status.photo = photo;
    status.user = user;
    [localUsers enumerateObjectsUsingBlock:^(SAUser * _Nonnull obj, BOOL * _Nonnull stop) {
        [status.localUsers addObject:obj];
    }];
    status.repostStatusID = repostStatusID;
    status.createdAt = createdAt;
//    status.type = type;
    return status;
}

- (SAStatus *)statusWithID:(NSString *)statusID
{
    return [SAStatus objectInRealm:self.defaultRealm forPrimaryKey:statusID];
}

- (void)deleteStatusWithID:(NSString *)statusID
{
    SAStatus *status = [self statusWithID:statusID];
    [self.defaultRealm beginWriteTransaction];
    [self.defaultRealm deleteObject:status];
    [self.defaultRealm commitWriteTransaction];
}

@end
