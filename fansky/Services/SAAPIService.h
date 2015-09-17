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

- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password success:(void(^)(NSString *token, NSString *secret))success failure:(void(^)(NSString *error))failure;

- (void)verifyCredentialsWithToken:(NSString *)token secret:(NSString *)secret success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)timeLineWithUserID:(NSString *)userID sinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)userTimeLineWithUserID:(NSString *)userID sinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)sendStatus:(NSString *)status replyToStatusID:(NSString *)replayToStatusID repostStatusID:(NSString *)repostStatusID success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)userWithID:(NSString *)userID success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

- (void)userPhotoTimeLineWithUserID:(NSString *)userID sinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void(^)(id data))success failure:(void(^)(NSString *error))failure;

@end
