//
//  SADataManager+Status.m
//  fansky
//
//  Created by Zzy on 9/12/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SADataManager+Status.h"
#import "SAStatus.h"

@implementation SADataManager (Status)

static NSString *const ENTITY_NAME = @"SAStatus";

- (SAStatus *)insertStatusWithObject:(id)object
{
    NSString *statusID = [object objectForKey:@"id"];
    
    __block SAStatus *resultStatus;
    [self.managedObjectContext performBlockAndWait:^{
        SAStatus *status = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
        status.statusID = statusID;
        resultStatus = status;
    }];
    return resultStatus;
}

@end
