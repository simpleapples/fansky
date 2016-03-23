//
//  SAStatus.h
//  fansky
//
//  Created by Zzy on 16/3/21.
//  Copyright © 2016年 Zzy. All rights reserved.
//

#import "SAUser.h"
#import <Realm/Realm.h>

typedef NS_ENUM(NSUInteger, SAStatusTypes)
{
    SAStatusTypeTimeLine = 1,
    SAStatusTypeUserStatus = 2,
    SAStatusTypeMentionStatus = 3,
    SAStatusTypeFavoriteStatus = 4
};

RLM_ARRAY_TYPE(NSNumber)

@class SAPhoto;

@interface SAStatus : RLMObject

@property NSString *statusID;
@property NSString *text;
@property NSString *source;
@property NSString *repostStatusID;
@property NSDate *createdAt;
@property NSString *types;
@property BOOL isFavorited;

@property SAUser *user;
@property SAPhoto *photo;
@property RLMArray<SAUser *><SAUser> *localUsers;

@end
