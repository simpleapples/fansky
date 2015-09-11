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

- (SAUser *)insertOrUpdateUserWithObject:(id)userObject
{
    NSString *userID = (NSString *)[userObject objectForKey:@"id"];
    NSString *name = (NSString *)[userObject objectForKey:@"name"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", userID];
    
    __block NSError *error;
    __block SAUser *resultUser;
    [self.managedObjectContext performBlockAndWait:^{
        NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchResult && fetchResult.count) {
            SAUser *existUser = [fetchResult objectAtIndex:0];
            existUser.name = name;
            resultUser = existUser;
        } else {
            [self.managedObjectContext performBlockAndWait:^{
                SAUser *user = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
                user.name = name;
                resultUser = user;
            }];
        }
    }];
    return resultUser;
}

@end
