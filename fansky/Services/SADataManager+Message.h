//
//  SADataManager+Message.h
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SADataManager.h"

@class SAMessage;
@class SAUser;
@class RLMResults;

@interface SADataManager (Message)

- (void)insertOrUpdateMessageWithObjects:(id)objects;
- (SAMessage *)insertOrUpdateMessageWithObject:(id)object localUser:(SAUser *)localUser;
- (RLMResults *)currentMessagesWithUserID:(NSString *)userID localUserID:(NSString *)localUserID;

@end
