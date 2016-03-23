//
//  SAUser.h
//  fansky
//
//  Created by Zzy on 16/3/21.
//  Copyright © 2016年 Zzy. All rights reserved.
//

#import <Realm/Realm.h>

@interface SAUser : RLMObject

@property NSString *userID;
@property NSString *token;
@property NSString *tokenSecret;
@property NSString *name;
@property NSString *profileImageURL;
@property NSString *location;
@property NSString *desc;
@property BOOL isLocal;
@property BOOL isProtected;
@property BOOL isFollowing;
@property BOOL isActive;
@property int statusCount;
@property int friendsCount;
@property int followersCount;

@end

RLM_ARRAY_TYPE(SAUser)
