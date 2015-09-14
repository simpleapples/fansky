//
//  SADataManager+Status.m
//  fansky
//
//  Created by Zzy on 9/12/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SADataManager+Status.h"
#import "SAStatus.h"
#import "SADataManager+Photo.h"
#import "SADataManager+User.h"
#import "NSString+Utils.h"

@implementation SADataManager (Status)

static NSString *const ENTITY_NAME = @"SAStatus";

- (void)insertStatusWithObjects:(NSArray *)objects
{
    [objects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        [self insertStatusWithObject:object];
    }];
}

- (SAStatus *)insertStatusWithObject:(id)object
{
    NSString *statusID = [object objectForKey:@"id"];
    NSString *source = [object objectForKey:@"source"];
    NSString *text = [object objectForKey:@"text"];
    NSString *createdAtString = [object objectForKey:@"createdat"];
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
        status.createdAt = createdAt;
        resultStatus = status;
    }];
    return resultStatus;
}

@end
