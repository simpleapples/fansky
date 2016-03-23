//
//  SADataManager+Status.h
//  fansky
//
//  Created by Zzy on 9/12/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SADataManager.h"
#import "SAStatus.h"

@class SAStatus;

@interface SADataManager (Status)

- (void)insertOrUpdateStatusWithObjects:(NSArray *)objects type:(SAStatusTypes)type;
- (void)insertOrUpdateStatusWithObject:(id)object localUser:(SAUser *)localUser type:(SAStatusTypes)type;

- (RLMResults<SAStatus *> *)currentTimeLineWithUserID:(NSString *)userID type:(SAStatusTypes)type;
- (RLMResults<SAStatus *> *)currentPhotoTimeLineWithUserID:(NSString *)userID;
- (SAStatus *)statusWithObject:(id)object localUsers:(NSSet<SAUser *> *)localUsers type:(SAStatusTypes)type;

- (SAStatus *)statusWithID:(NSString *)statusID;
- (void)deleteStatusWithID:(NSString *)statusID;

@end
