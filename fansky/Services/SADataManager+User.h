//
//  SADataManager+User.h
//  fansky
//
//  Created by Zzy on 9/10/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SADataManager.h"

@class SAUser;

@interface SADataManager (User)

- (SAUser *)currentUser;
- (SAUser *)insertOrUpdateUserWithObject:(id)userObject local:(BOOL)local active:(BOOL)active token:(NSString *)token secret:(NSString *)secret;
- (SAUser *)userWithID:(NSString *)userID;
- (SAUser *)userWithObject:(id)object;

- (BOOL)isLocalUserExist;
- (void)setCurrentUserWithUserID:(NSString *)userID;
- (void)deleteUserWithUserID:(NSString *)userID;

@end
