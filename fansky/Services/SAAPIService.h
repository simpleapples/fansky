//
//  SAAPIService.h
//  fansky
//
//  Created by Zzy on 6/23/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAAPIService : NSObject

+ (SAAPIService *)sharedSingleton;

#pragma mark - User

- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password success:(void(^)(NSString *token, NSString *secret))success failure:(void(^)(NSString *error))failure;

- (void)verifyCredentialsWithToken:(NSString *)token secret:(NSString *)secret success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)userWithID:(NSString *)userID success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)followUserWithID:(NSString *)userID success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)unfollowUserWithID:(NSString *)userID success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

#pragma mark - Status

- (void)timeLineWithUserID:(NSString *)userID sinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)userTimeLineWithUserID:(NSString *)userID sinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)sendStatus:(NSString *)status replyToStatusID:(NSString *)replyToStatusID repostStatusID:(NSString *)repostStatusID image:(NSData *)image success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)userPhotoTimeLineWithUserID:(NSString *)userID sinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)deleteStatusWithID:(NSString *)statusID success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)mentionStatusWithSinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

#pragma mark - Message

- (void)conversationListWithCount:(NSInteger)count success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)conversationWithUserID:(NSString *)userID sinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)sendMessageWithUserID:(NSString *)userID text:(NSString *)text replyToMessageID:(NSString *)replyToMessageID success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

@end
