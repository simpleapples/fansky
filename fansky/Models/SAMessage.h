//
//  SAMessage.h
//  fansky
//
//  Created by Zzy on 16/3/21.
//  Copyright © 2016年 Zzy. All rights reserved.
//

#import <Realm/Realm.h>

@class SAUser;
@class SAConversation;

@interface SAMessage : RLMObject

@property NSString *messageID;
@property NSString *text;
@property NSDate *createdAt;

@property SAUser *sender;
@property SAUser *recipient;
@property SAUser *localUser;

@end
