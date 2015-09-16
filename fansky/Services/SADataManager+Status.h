//
//  SADataManager+Status.h
//  fansky
//
//  Created by Zzy on 9/12/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SADataManager.h"

@class SAStatus;
@class SAUser;

@interface SADataManager (Status)

- (void)insertStatusWithObjects:(NSArray *)objects;
- (SAStatus *)insertOrUpdateStatusWithObject:(id)object localUser:(SAUser *)localUser;
- (SAStatus *)statusWithID:(NSString *)statusID;

@end
