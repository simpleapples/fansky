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
- (void)currentTimeLineWithUserID:(NSString *)userID type:(SAStatusTypes)type offset:(NSUInteger)offset limit:(NSUInteger)limit completeHandler:(void(^)(NSArray *result))completeHandler;
- (void)currentMentionTimeLineWithUserID:(NSString *)userID offset:(NSUInteger)offset limit:(NSUInteger)limit completeHandler:(void(^)(NSArray *result))completeHandler;
- (void)currentPhotoTimeLineWithUserID:(NSString *)userID limit:(NSUInteger)limit completeHandler:(void(^)(NSArray *result))completeHandler;
- (SAStatus *)statusWithObject:(id)object localUsers:(NSSet<SAUser *> *)localUsers type:(SAStatusTypes)type;

- (SAStatus *)statusWithID:(NSString *)statusID;
- (void)deleteStatusWithID:(NSString *)statusID;

@end
