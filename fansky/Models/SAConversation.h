//
//  SAConversation.h
//  fansky
//
//  Created by Zzy on 16/3/21.
//  Copyright © 2016年 Zzy. All rights reserved.
//

#import <Realm/Realm.h>

@class SAUser;
@class SAMessage;

@interface SAConversation : RLMObject

@property NSString *otherUserID;
@property int messageCount;
@property BOOL isNew;

@property SAMessage *message;
@property SAUser *localUser;

@end
