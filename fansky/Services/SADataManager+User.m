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

static NSString *const ENTITY_NAME = @"SAUser";

- (SAUser *)currentUser
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"active = %@", @(YES)];
    
    __block NSError *error;
    __block SAUser *resultUser;
    [self.managedObjectContext performBlockAndWait:^{
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchResult && fetchResult.count) {
            SAUser *existUser = [fetchResult objectAtIndex:0];
            resultUser = existUser;
        }
    }];
    return resultUser;
}

- (SAUser *)insertOrUpdateUserWithObject:(id)userObject local:(BOOL)local active:(BOOL)active token:(NSString *)token secret:(NSString *)secret
{
    NSString *userID = (NSString *)[userObject objectForKey:@"id"];
    NSString *name = (NSString *)[userObject objectForKey:@"name"];
    NSString *location = (NSString *)[userObject objectForKey:@"location"];
    NSString *profileImageURL = (NSString *)[userObject objectForKey:@"profile_image_url"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"userID = %@", userID];
    
    __block NSError *error;
    __block SAUser *resultUser;
    [self.managedObjectContext performBlockAndWait:^{
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchResult && fetchResult.count) {
            SAUser *existUser = [fetchResult objectAtIndex:0];
            existUser.userID = userID;
            existUser.name = name;
            existUser.location = location;
            existUser.profileImageURL = profileImageURL;
            existUser.local = @(local);
            existUser.active = @(active);
            if (local) {
                existUser.token = token;
                existUser.tokenSecret = secret;
            }
            resultUser = existUser;
        } else {
            [self.managedObjectContext performBlockAndWait:^{
                SAUser *user = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
                user.userID = userID;
                user.name = name;
                user.location = location;
                user.profileImageURL = profileImageURL;
                user.local = @(local);
                user.active = @(active);
                if (local) {
                    user.token = token;
                    user.tokenSecret = secret;
                }
                resultUser = user;
            }];
        }
    }];
    return resultUser;
}

@end
