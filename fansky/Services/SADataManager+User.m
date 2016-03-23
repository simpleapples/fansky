//
//  SADataManager+User.m
//  fansky
//
//  Created by Zzy on 9/10/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SADataManager+User.h"
#import "SAUser.h"

@implementation SADataManager (User)

- (SAUser *)currentUser
{
    RLMResults<SAUser *> *activeUsers = [SAUser objectsInRealm:self.defaultRealm where:@"isActive == %@", @(YES)];
    return [activeUsers firstObject];
}

- (SAUser *)insertOrUpdateUserWithObject:(id)userObject local:(BOOL)local active:(BOOL)active token:(NSString *)token secret:(NSString *)secret
{
    NSString *userID = (NSString *)[userObject objectForKey:@"id"];
    NSString *name = (NSString *)[userObject objectForKey:@"name"];
    NSString *location = (NSString *)[userObject objectForKey:@"location"];
    NSString *desc = (NSString *)[userObject objectForKey:@"description"];
    NSString *profileImageURL = (NSString *)[userObject objectForKey:@"profile_image_url_large"];
    NSNumber *isFollowing = [userObject objectForKey:@"following"];
    NSNumber *friendsCount = [userObject objectForKey:@"friends_count"];
    NSNumber *followersCount = [userObject objectForKey:@"followers_count"];
    NSNumber *statusCount = [userObject objectForKey:@"statuses_count"];
    NSNumber *isProtected = [userObject objectForKey:@"protected"];
    
    SAUser *user = [SAUser objectInRealm:self.defaultRealm forPrimaryKey:userID];
    [self.defaultRealm beginWriteTransaction];
    if (!user) {
        user = [[SAUser alloc] init];
        user.userID = userID;
        user = [SAUser createInRealm:self.defaultRealm withValue:user];
    }
    user.name = name;
    user.location = location;
    user.desc = desc;
    user.profileImageURL = profileImageURL;
    user.friendsCount = [friendsCount intValue];
    user.followersCount = [followersCount intValue];
    user.statusCount = [statusCount intValue];
    user.isFollowing = [isFollowing boolValue];
    user.isProtected = [isProtected boolValue];
    if (local) {
        user.isLocal = local;
        user.isActive = active;
        user.token = token;
        user.tokenSecret = secret;
    }
    [self.defaultRealm commitWriteTransaction];
    
    return [SAUser objectInRealm:self.defaultRealm forPrimaryKey:userID];
}

- (SAUser *)userWithID:(NSString *)userID
{
    SAUser *user = [SAUser objectInRealm:self.defaultRealm forPrimaryKey:userID];
    return user;
}

- (RLMResults *)localUsers
{
    RLMResults *results = [SAUser objectsInRealm:self.defaultRealm where:@"isLocal = %@", @(YES)];
    results = [results sortedResultsUsingProperty:@"name" ascending:NO];
    return results;
}

- (void)setCurrentUserWithUserID:(NSString *)userID
{
    RLMResults<SAUser *> *users = [SAUser allObjectsInRealm:self.defaultRealm];
    [self.defaultRealm beginWriteTransaction];
    for (SAUser *user in users) {
        if ([user.userID isEqualToString:userID]) {
            user.isActive = YES;
        } else {
            user.isActive = NO;
        }
    }
    [self.defaultRealm commitWriteTransaction];
}

- (void)deleteUserWithUserID:(NSString *)userID
{
    SAUser *user = [SAUser objectInRealm:self.defaultRealm forPrimaryKey:userID];
    [self.defaultRealm beginWriteTransaction];
    user.isLocal = NO;
    user.isActive = NO;
    [self.defaultRealm commitWriteTransaction];
}

@end
