//
//  SADataManager+Status.h
//  fansky
//
//  Created by Zzy on 9/12/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SADataManager.h"
#import "SAStatus+CoreDataProperties.h"

@class SAStatus;

@interface SADataManager (Status)

- (void)insertOrUpdateStatusWithObjects:(NSArray *)objects type:(SAStatusTypes)type;
- (SAStatus *)insertOrUpdateStatusWithObject:(id)object localUser:(SAUser *)localUser type:(SAStatusTypes)type;
- (NSArray *)currentTimeLineWithUserID:(NSString *)userID type:(SAStatusTypes)type limit:(NSUInteger)limit;
- (NSArray *)currentMentionTimeLineWithUserID:(NSString *)userID limit:(NSUInteger)limit;
- (NSArray *)currentPhotoTimeLineWithUserID:(NSString *)userID limit:(NSUInteger)limit;
- (SAStatus *)statusWithID:(NSString *)statusID;
- (void)deleteStatusWithID:(NSString *)statusID;

@end
