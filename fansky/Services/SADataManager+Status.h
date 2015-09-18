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

- (void)insertStatusWithObjects:(NSArray *)objects isHomeTimeLine:(BOOL)isHomeTimeLine isMention:(BOOL)isMention;
- (SAStatus *)insertStatusWithObject:(id)object localUser:(SAUser *)localUser isHomeTimeLine:(BOOL)isHomeTimeLine isMention:(BOOL)isMention;
- (SAStatus *)statusWithID:(NSString *)statusID;

@end
