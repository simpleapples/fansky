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

- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password success:(void(^)(NSString *token))success failure:(void(^)(NSError *error))failure;

- (void)userInfoWithToken:(NSString *)token success:(void(^)(NSString *userInfo))success failure:(void(^)(NSError *error))failure;

@end
